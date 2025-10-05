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

cp $LocScript/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
Validation $? "Rabbitmq Repo"

dnf install rabbitmq-server -y &>>$Logs_File
Validation $? "Install Rabbitmq Server"

systemctl enable rabbitmq-server &>>$Logs_File
Validation $? "Enable Rabbitmq Server"

systemctl start rabbitmq-server &>>$Logs_File
Validation $? "Start Rabbitmq Server"

rabbitmqctl add_user roboshop roboshop123 &>>$Logs_File
Validation $? "Add User Roboshop"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$Logs_File
Validation $? "Set permissions for Rabbitmq Server"