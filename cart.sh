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

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$Logs_File
Validation $? "Download Cart"

cd /app 
Validation $? "Moveing to App Directory"

rm -rf /app/*
Validation $? "Removing existing code"

rm -rf /app/*
Validation $? "Removing existing code"

unzip /tmp/cart.zip &>>$Logs_File
Validation $? "UnZip Cart"


npm install &>>$Logs_File
Validation $? "Downloading Dependencies Nodejs"

cp $LocScript/cart.service /etc/systemd/system/cart.service 
Validation $? "Cart Service"

systemctl daemon-reload 
Validation $? "Daemon Reload"

systemctl enable cart &>>$Logs_File
Validation $? "Enable Cart"

systemctl start cart
Validation $? "Start Cart"

systemctl restart cart
Validation $? "Restart Cart"