#!/bin/bash

#0=Root, 1=normal user
USERID=$(id -u)

#colours
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#/var/log/script/log.log
FOLDER="/var/log/script"
SCRIPT=$( echo $0 | cut -d "." -f1)
FILE="$FOLDER/$SCRIPT.log"

mkdir -p $FOLDER
echo -e "$G Script Started at $(date)" | tee -a $FILE



if [ $USERID -ne 0 ]
then
    echo -e "$R Take Root Access $N (Use Sudo)" 
    exit 1
fi

Status() {
    #Exit Status Mysql 0-s 1-f
    if [ $1 -ne 0 ]
    then
        echo -e "$R $package Installing $N Failure" | tee -a $FILE
        exit 1
    else
        echo -e "$G $package Installing $N Success" | tee -a $FILE
    fi
}


for package in $@ #nginx mysql 1234
do  
    #list already installed check through Exit status and install 0-S 1-f

    dnf list installed $package &>>$FILE

    if [ $? -ne 0 ]
    then
        dnf install $package -y &>>$FILE
        Status $? "$package"
    else
        echo -e "$Y Already Installed "$package" $N" | tee -a $FILE

    fi
done

dnf install mongodb-org -y 
Status $? "Installed Mongodb"

systemctl enable mongod 

systemctl start mongod 