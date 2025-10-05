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


dnf module disable nginx -y &>>$Logs_File
Validation $? "Disable Nginx"

dnf module enable nginx:1.24 -y &>>$Logs_File
Validation $? "Enable Nginx 1.24"

dnf install nginx -y &>>$Logs_File
Validation $? "Install Nginx"

systemctl enable nginx &>>$Logs_File
Validation $? "Enable Nginx" 

systemctl start nginx 
Validation $? "Start Nginx"

rm -rf /usr/share/nginx/html/* 
Validation $? "Remove Default Html"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$Logs_File
Validation $? "Download Frontend Zip"

cd /usr/share/nginx/html 
Validation $? "Change Dir to /usr/share/nginx/html"

unzip /tmp/frontend.zip &>>$Logs_File
Validation $? "Download Frontend Unzip"

cp $LocScript/nginx.conf /etc/nginx/nginx.conf &>>$Logs_File
Validation $? "Nginx Conf Setup"

systemctl restart nginx &>>$Logs_File
Validation $? "Restart Nginx"