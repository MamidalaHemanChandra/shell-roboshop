#!/bin/bash

UserId=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LocScript=$PWD

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


dnf install python3 gcc python3-devel -y &>>$Logs_File
Validation $? "Install Python3"

id roboshop &>>$Logs_File
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$Logs_File
    Validation $? "Roboshop System User"
else
    echo -e "$Y Roboshop System User Exists $N"
fi

mkdir /app 
Validation $? "Creating App Dir"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$Logs_File
Validation $? "Download Payment in Tmp "

cd /app 
Validation $? "Moving to App Dir"

rm -rf /app/*
Validation $? "Removing existing code"

unzip /tmp/payment.zip &>>$Logs_File
Validation $? "Unzip Payment"
 
pip3 install -r requirements.txt &>>$Logs_File
Validation $? "Install Python Dependenices"

cp $LocScript/payment.service /etc/systemd/system/payment.service &>>$Logs_File
Validation $? "Creating Payment Service"

systemctl daemon-reload
Validation $? "Daemon Reload"

systemctl enable payment &>>$Logs_File
Validation $? "Enable Payment"

systemctl start payment &>>$Logs_File
Validation $? "Start Payment"
