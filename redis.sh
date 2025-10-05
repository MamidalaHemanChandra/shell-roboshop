#!/bin/bash

UserId=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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


dnf module disable redis -y &>>$Logs_File
Validation $? "Disable Redis"

dnf module enable redis:7 -y &>>$Logs_File
Validation $? "Enable Redis:7"

dnf install redis -y &>>$Logs_File
Validation $? "Install Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/c protected-mode no' /etc/redis/redis.conf &>>$Logs_File
Validation $? "Redis Config to Public"

systemctl enable redis &>>$Logs_File
Validation $? "Enable Redis"

systemctl start redis &>>$Logs_File
Validation $? "Start Redis" 