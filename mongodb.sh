#!/bin/bash

UserId=$(id -u)
Location=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

Logs_Folder="/var/log/shell-roboshop"
Script_Name=$( echo $0 | cut -d "." -f1 )
Logs_File="$Logs_Folder.$Script_Name.log"


mkdir -p $Logs_Folder

echo "Script Started at : $(date)" | tee -a $Logs_File

#Root=0,other than 0 =Normal user
if [ $UserId -ne 0 ];then
    echo -e "$R Take Root Access To run this Shell Script $N" | tee -a $Logs_File
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


cp $Location/mongo.repo /etc/yum.repos.d/mongo.repo 
Validation $? "Mongo Repo Created"

dnf install mongodb-org -y &>>$Logs_File
Validation $? "Installed Mongodb"

systemctl enable mongod &>>$Logs_File
Validation $? "Enabled Mongodb"

systemctl start mongod &>>$Logs_File
Validation $? "Started Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
Validation $? "Mongodb Config Changed"

systemctl restart mongod
Validation $? "Restarted Mongod"