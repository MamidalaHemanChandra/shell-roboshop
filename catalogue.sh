#!/bin/bash

UserId=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_Folder="/var/log/shell-roboshop"
Script_Name=$( echo $0 | cut -d "." -f1 )
Logs_File="$Logs_Folder/$Script_Name.log"

Host_Mongodb="mongodb.heman.icu"

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


dnf module disable nodejs -y
Validation $? "Disable Nodejs"

dnf module enable nodejs:20 -y
Validation $? "Enable Nodejs 20"

dnf install nodejs -y
Validation $? "Install Nodejs 20"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
Validation $? "Roboshop System User"

mkdir /app 
Validation $? "Create App Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip
Validation $? "Download Catalogue"

cd /app 
Validation $? "Moveing to App Directory"

unzip /tmp/catalogue.zip
Validation $? "UnZip Catalogue"


npm install 
Validation $? "Downloading Dependencies Nodejs"

cp catalogue.service /etc/systemd/system/catalogue.service
Validation $? "Catalogue Service"

systemctl daemon-reload
Validation $? "Daemon Reload"

systemctl enable catalogue 
Validation $? "Enable Catalogue"

systemctl start catalogue
Validation $? "Start Catalogue"

cp mongo.repo /etc/yum.repos.d/mongo.repo
Validation $? "Creating Mongo Repo"

dnf install mongodb-mongosh -y
Validation $? "Install Mongodb"

mongosh --host $Host_Mongodb </app/db/master-data.js
Validation $? "Enable Nodejs 20"

systemctl restart catalogue
Validation $? "Enable Nodejs 20"