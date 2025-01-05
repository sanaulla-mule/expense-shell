#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$( echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){    
 if [ $1 -ne 0 ]
then 
        echo  -e "$2...$R Failure $N" 
        exit 1
else 
        echo  -e " $2 .... $R SUCCESS $N" 
fi
}
CHECK_ROOT(){

if [ $USERID -ne 0 ]
then 
    echo " ERROR:: you must have access the sudo user"
    exit 1 # other then 0
fi 
}
 echo "script execution time at: $TIMESTAMP"  &>>$LOG_FILE_NAME

CHECK_ROOT

 dnf install mysql-server -y &>>$LOG_FILE_NAME
 VALIDATE $? "installing mysql Server"

 systemctl enable mysqld 
 VALIDATE $? "Enabling mysql Server"

 systemctl start mysqld 
 VALIDATE $? "starting mysql Server"

 mysql -h database.sanadevops.online -u root -pExpenseApp@1 -e 'show databases;'
 VALIDATE $? "setting the root password"

    