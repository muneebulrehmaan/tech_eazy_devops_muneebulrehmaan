#!/bin/bash

APP_BUCKET="${app_bucket_name}"
JAR_NAME="${JAR_NAME}"
APP_PATH="${APP_PATH}"
LOG_PATH="${LOG_PATH}"

# Install Java if not installed
if ! java -version 2>&1 | grep -q "17"; then
  amazon-linux-extras enable corretto17
  yum install -y java-17-amazon-corretto
fi


# Install AWS CLI if not installed
if ! type aws >/dev/null 2>&1; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
fi

# Poll S3 bucket every minute for updated JAR and restart app if changed
while true; do
  echo "$(date): Checking for updates..."

# Download latest JAR
aws s3 cp s3://${app_bucket_name}/${JAR_NAME} ${APP_PATH}.new

# Give ownership to ec2-user
chown ec2-user:ec2-user ${APP_PATH}.new

# Give execution permissions
chmod 755 ${APP_PATH}.new

if [ ! -f "${APP_PATH}" ] || ! cmp -s "${APP_PATH}" "${APP_PATH}.new"; then
    echo "$(date): New JAR detected. Updating..."

    pkill -f "${JAR_NAME}" || true

    mv ${APP_PATH}.new ${APP_PATH}
    nohup java -jar ${APP_PATH} > ${LOG_PATH} 2>&1 &
else
    rm ${APP_PATH}.new
fi


  sleep 60
done
