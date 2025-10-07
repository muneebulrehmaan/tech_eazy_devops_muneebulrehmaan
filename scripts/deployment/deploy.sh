#!/bin/bash

APP_BUCKET="${app_bucket_name}"
JAR_NAME="hellomvc-0.0.1-SNAPSHOT.jar"
APP_PATH="/home/ec2-user/${JAR_NAME}"
LOG_PATH="/home/ec2-user/app.log"

# Install Java if not installed
if ! type java >/dev/null 2>&1; then
    sudo yum update -y
    sudo amazon-linux-extras install java-openjdk11 -y
fi

# Install AWS CLI if not installed
if ! type aws >/dev/null 2>&1; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Download JAR file initially
aws s3 cp s3://${APP_BUCKET}/${JAR_NAME} ${APP_PATH}

# Run application initially
nohup java -jar ${APP_PATH} > ${LOG_PATH} 2>&1 &

# Start background polling script
nohup bash /home/ec2-user/poll-update.sh &
