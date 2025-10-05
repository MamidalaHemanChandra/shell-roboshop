#!/bin/bash

UserId=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LocScript=$PWD
Host_Mysql=mysql.heman.icu

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

dnf install maven -y &>>$Logs_File
Validation $? "Install Maven"

id roboshop &>>$Logs_File
if [ $? -ne 0 ];then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$Logs_File
    Validation $? "Roboshop System User"
else
    echo -e "$Y Roboshop System User Exists $N"
fi

mkdir -p /app &>>$Logs_File
Validation $? "App Dir"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
Validation $? "Download Shipping"

cd /app
Validation $? "Moving to App Dir" 

rm -rf /app/*
Validation $? "Removing existing code"

unzip /tmp/shipping.zip &>>$Logs_File
Validation $? "Unzip Shipping"
 
mvn clean package &>>$Logs_File
Validation $? "Install Maven Pacakages"

mv target/shipping-1.0.jar shipping.jar &>>$Logs_File
Validation $? "Moving Shipping"

cp $LocScript/shipping.service /etc/systemd/system/shipping.service &>>$Logs_File

systemctl daemon-reload
Validation $? "Daemon Reload"

systemctl enable shipping &>>$Logs_File
Validation $? "Enable Shipping"

systemctl start shipping
Validation $? "Start Shipping"

dnf install mysql -y &>>$Logs_File
Validation $? "Install Mysql"

mysql -h $Host_Mysql -uroot -pRoboShop@1 -e 'use cities' &>>$Logs_File
if [ $? -ne 0 ];then
    mysql -h $Host_Mysql -uroot -pRoboShop@1 < /app/db/schema.sql &>>$Logs_File
    mysql -h $Host_Mysql -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$Logs_File
    mysql -h $Host_Mysql -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$Logs_File
else
    echo "Shipping data already exists"
fi

systemctl restart shipping
Validation $? "Install Mysql"