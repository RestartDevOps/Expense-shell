#!/bin/bash

# Define variables
LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(basename "$0" | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p "$LOGS_FOLDER"

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

# Function to check if the script is run as root
CHECK_ROOT() {
    if [ "$USERID" -ne 0 ]; then
        echo -e "$R Please run this script with root privileges $N" | tee -a "$LOG_FILE"
        exit 1
    fi
}

# Function to validate the success of a command
VALIDATE() {
    if [ "$1" -ne 0 ]; then
        echo -e "$2 is...$R FAILED $N" | tee -a "$LOG_FILE"
        exit 1
    else
        echo -e "$2 is... $G SUCCESS $N" | tee -a "$LOG_FILE"
    fi
}

# Start logging
echo "Script started executing at: $(date)" | tee -a "$LOG_FILE"

# Check if the script is run as root
CHECK_ROOT

# Check if MySQL is installed
if dnf list installed | grep -q mysql; then
    echo "MySQL server is already installed; nothing to do" | tee -a "$LOG_FILE"
else
    echo -e "$R MySQL is not installed $N" | tee -a "$LOG_FILE"
    dnf install mysql-server -y &>> "$LOG_FILE"
    VALIDATE $? "Installing MySQL Server"
fi

# Check if MySQL is enabled
if systemctl is-enabled mysqld &>/dev/null; then
    echo "MySQL server is already enabled; nothing to do" | tee -a "$LOG_FILE"
else
    echo -e "$R MySQL is not enabled $N" | tee -a "$LOG_FILE"
    systemctl enable mysqld &>> "$LOG_FILE"
    VALIDATE $? "Enabling MySQL Server"
fi

# Check if MySQL is running
if systemctl is-active mysqld &>/dev/null; then
    echo "MySQL server is already started; nothing to do" | tee -a "$LOG_FILE"
else
    echo -e "$R MySQL is not started $N" | tee -a "$LOG_FILE"
    systemctl start mysqld &>> "$LOG_FILE"
    VALIDATE $? "Starting MySQL Server"
fi

# Check if MySQL root password is set
mysql -h mysql.daws81s.online -u root -pExpenseApp@1 -e 'show databases;' &>> "$LOG_FILE"
if [ $? -ne 0 ]; then
    echo "MySQL root password is not set up; setting now" | tee -a "$LOG_FILE"
    # Use `mysql_secure_installation` with pre-set root password in a secure way.
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>> "$LOG_FILE"
    VALIDATE $? "Setting Up MySQL Root Password"
else
    echo -e "MySQL root password is already set up...$Y SKIPPING $N" | tee -a "$LOG_FILE"
fi
