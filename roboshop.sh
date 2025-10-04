#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
Security_group_ID="sg-09fdc52c223a46f2c"
Hosted_zone_ID="Z00303221M2EO78HUMVX6"
Domain_Name="heman.icu"

for instance in $@ #mongodb instance,
do
    Instance_Id=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $Security_group_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    if [ $instance != "frontend" ];then
        IP=$(aws ec2 describe-instances --instance-ids $Instance_Id --query "Reservations[0].Instances[0].PrivateIpAddress" --output text)
        Record_Name="$instance.$Domain_Name"
    else
        IP=$(aws ec2 describe-instances --instance-ids $Instance_Id --query "Reservations[0].Instances[0].PublicIpAddress" --output text)
        Record_Name="$instance.$Domain_Name"

    fi

    echo "$instance: $IP"

    # Creates route 53 records based on env name

    aws route53 change-resource-record-sets \
    --hosted-zone-id $Hosted_zone_ID \
    --change-batch '
  {
    "Comment": "Updating a Record"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'$Record_Name'"
        ,"Type"             : "A"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'$IP'"
        }]
      }
    }]
  }
  '
done