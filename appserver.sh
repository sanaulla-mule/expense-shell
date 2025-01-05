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

dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disbling existing nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling the modejs 20"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing the nodejs"

id expense &>>$LOG_FILE_NAME
if [ $? -ne 0 ]
then
  useradd expense
  VALIDATE $? "adding expense user"
else
  echo -e "expense user alredy exists....$Y SKIPPING $N"
fi

mkdir  -p /app &>>$LOG_FILE_NAME
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip

cd /app
unzip /tmp/backend.zip &>>$LOG_FILE_NAME

npm install &>>$LOG_FILE_NAME
VALIDATE $? "npm installing" 
cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "installing mysql clint"

mysql -h database.sanadevops.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE_NAME
VALIDATE $? "setting of the schema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "daemon-reload"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "dstart backend"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "denable backend"

systemctl restart backend

