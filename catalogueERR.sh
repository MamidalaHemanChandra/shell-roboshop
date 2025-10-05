#!/bin/bash
set -euo pipefail

trap 'echo "There is an Error in $LINENO, Command is: $BASH_COMMAND"' ERR

UserId=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LocScript=$PWD
Host_Mongodb=mongodb.heman.icu

Logs_Folder="/var/log/shell-roboshop"
Script_Name=$( echo $0 | cut -d "." -f1 )
Logs_File="$Logs_Folder/$Script_Name.log"



mkdir -p $Logs_Folder

echo "Script Started at : $(date)" | tee -a $Logs_File

#Root=0,other than 0 =Normal user
if [ $UserId -ne 0 ];then
    echo -e "$R Take Root Access To run this Shell Script $N"
    exit 1
fi


dnf module disable nodejs -y &>>$Logs_File

dnf module enable nodejs:20 -y &>>$Logs_File

dnf install nodejs -y &>>$Logs_File
echo "Install Nodejs 20"

id roboshop &>>$Logs_File
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$Logs_File
    echo "Roboshop System User Created"
else
    echo -e "$Y Roboshop System User Exists $N"
fi

mkdir -p /app 
echo "App Dir Created"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$Logs_File
echo "Catalogue code moved to Tmp"

cd /app 

rm -rf /app/*

unzip /tmp/catalogue.zip &>>$Logs_File
echo "Cataloue Zip"

npm install &>>$Logs_File

cp $LocScript/catalogue.service /etc/systemd/system/catalogue.service
echo "Catalogue Service Created"

systemctl daemon-reload 

systemctl enable catalogue &>>$Logs_File

systemctl start catalogue

cp  $LocScript/mongo.repo /etc/yum.repos.d/mongo.repo

dnf install mongodb-mongosh -y &>>$Logs_File
echo "Mongodb cilent package Installed"

DB_EXISTS=$(mongosh --quiet --host  $Host_Mongodb --eval "db.getMongo().getDBNames().indexOf('catlogue')")
if [ $DB_EXISTS -le 0 ];then # -1,0 not exists,1 exist mongo database   
    mongosh --host $Host_Mongodb </app/db/master-data.js &>>$Logs_File
else
    echo -e "$Y Mongosh DB EXISTS $N"
fi

systemctl restart catalogue

