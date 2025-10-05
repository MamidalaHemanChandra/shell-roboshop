#!/bin/bash

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

Validation(){
    if [ $1 -ne 0 ];then
        echo -e "$R $2  Failed! $N" | tee -a $Logs_File
        exit 1
    else
        echo -e "$G $2  Successfully! $N" | tee -a  $Logs_File
    fi
}


dnf module disable nodejs -y &>>$Logs_File
Validation $? "Disable Nodejs"

dnf module enable nodejs:20 -y &>>$Logs_File
Validation $? "Enable Nodejs 20"

dnf install nodejs -y &>>$Logs_File
Validation $? "Install Nodejs 20"

id roboshop &>>$Logs_File
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$Logs_File
    Validation $? "Roboshop System User"
else
    echo -e "$Y Roboshop System User Exists $N"
fi

mkdir -p /app 
Validation $? "Create App Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$Logs_File
Validation $? "Download Catalogue"

cd /app 
Validation $? "Moveing to App Directory"

rm -rf /app/*
Validation $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$Logs_File
Validation $? "UnZip Catalogue"


npm install &>>$Logs_File
Validation $? "Downloading Dependencies Nodejs"

cp $LocScript/catalogue.service /etc/systemd/system/catalogue.service
Validation $? "Catalogue Service"

systemctl daemon-reload 
Validation $? "Daemon Reload"

systemctl enable catalogue &>>$Logs_File
Validation $? "Enable Catalogue"

systemctl start catalogue
Validation $? "Start Catalogue"

cp  $LocScript/mongo.repo /etc/yum.repos.d/mongo.repo
Validation $? "Creating Mongo Repo"

dnf install mongodb-mongosh -y &>>$Logs_File
Validation $? "Install Mongodb"

DB_EXISTS=$(mongosh --quiet --host  $Host_Mongodb --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $DB_EXISTS -le 0 ];then # -1,0 not exists,1 exist mongo database   
    mongosh --host $Host_Mongodb </app/db/master-data.js &>>$Logs_File
    Validation $? "Loading Mongodb to catalogue"
else
    echo -e "$Y Mongosh DB EXISTS $N"
fi

systemctl restart catalogue
Validation $? "Enable Nodejs 20"