#!/bin/bash
#Author - Jakeer
#Team - DevOps
LOG_FOLDER="/var/log/expense"
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
TIME_STAMP="$(date +%Y-%m-%d-%H-%M-%S)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p $LOG_FOLDER

USERID="(id -u)"
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m

CHECK_ROOT(){
if [ $USERID -ne 0 ];then
echo -e " $R you don't have root permissions please run sudo command " | tee -a $LOG_FILE
exit 1
else
echo " $G you have root permission to run this command | tee -a $LOG_FILE
fi
}

VALIDATE(){
if [ $1 -ne 0 ];then
echo -e " $2 command is $R .. failed " | tee -a $LOG_FILE
exit 1
else
echo -e " $2 command is $G .. success " | tee -a $LOG_FILE
fi
}
echo "Script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT
dnf list installed mysql 
if [ $? -ne 0 ];then
echo " mysql is not installed " &>>LOG_FILE
dnf install mysql -y
VALIDATE $? " $G installing mysql " &>>LOG_FILE
#if [ $? -ne 0 ];then
#echo -e " $R mysql is not installed " &>>LOG_FILE
#else 
#echo -e " $G mysql install successsfully " &>>LOG_FILE

systemtl enable mysqld --now
VALIDATE $? " $G enable mysql " &>>LOG_FILE

mysql -h mysql.joinaiops.site -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE

if [ $? -ne 0 ];then
echo -e " $R echo "MySQL root password is not setup, setting now" &>>$LOG_FILE
mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setting UP root password"
else
echo -e "MySQL root password is already setup...$Y SKIPPING $N" | tee -a $LOG_FILE
fi