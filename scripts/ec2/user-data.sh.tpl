#!/bin/bash
set -euo pipefail

# Variables substituted by templatefile in Terraform launch template
APP_BUCKET_NAME="${app_bucket_name}"
JAR_NAME="${JAR_NAME}"
APP_PATH="${APP_PATH}"
LOG_PATH="${LOG_PATH}"
REGION="${REGION}"

# Update & install awslogs
yum update -y
yum install -y awslogs aws-cli java-17-amazon-corretto

# Ensure log file exists
mkdir -p /home/ec2-user
touch ${LOG_PATH}
chown ec2-user:ec2-user ${LOG_PATH}

# CloudWatch Logs agent configuration
cat <<'CWCONF' > /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state

[app_log]
file = /home/ec2-user/app.log
log_group_name = /aws/asg/${app_bucket_name}-logs
log_stream_name = {instance_id}/app
datetime_format = %b %d %H:%M:%S
CWCONF

# Ensure awslogs knows the region
mkdir -p /etc/awslogs
cat <<EOF > /etc/awslogs/awscli.conf
[plugins]
cwlogs = cwlogs
[default]
region = ${REGION}
EOF

# Start awslogs
systemctl enable awslogsd.service || true
systemctl restart awslogsd.service || true

# Record boot time to app log
echo "Instance $(hostname) launched at $(date --iso-8601=seconds)" >> ${LOG_PATH}

# Function to download and start app
start_app() {
    # Kill existing process
    pkill -f "java.*${JAR_NAME}" || true
    sleep 2
    
    # Download JAR
    RETRIES=5
    COUNT=0
    until [ $COUNT -ge $RETRIES ]
    do
        if aws s3 cp s3://${app_bucket_name}/${JAR_NAME} ${APP_PATH}; then
            echo "Downloaded ${JAR_NAME} from s3://${app_bucket_name}" >> ${LOG_PATH}
            break
        else
            echo "Failed to download JAR, retrying... ($COUNT)" >> ${LOG_PATH}
            COUNT=$((COUNT+1))
            sleep 5
        fi
    done
    
    # Start app
    nohup java -jar ${APP_PATH} --server.port=8080 >> ${LOG_PATH} 2>&1 &
    echo "App started with PID $! at $(date --iso-8601=seconds)" >> ${LOG_PATH}
}

# Initial startup
start_app

# Polling loop
while true; do
    sleep 60
    S3_TIME=$(aws s3api head-object --bucket ${app_bucket_name} --key ${JAR_NAME} --query 'LastModified' --output text 2>/dev/null || echo "0")
    if [ -f "${APP_PATH}" ]; then
        LOCAL_TIME=$(aws s3api head-object --bucket ${app_bucket_name} --key ${JAR_NAME} --query 'LastModified' --output text 2>/dev/null || echo "1")
    else
        LOCAL_TIME="1"
    fi
    
    if [ "$S3_TIME" != "$LOCAL_TIME" ] && [ "$S3_TIME" != "0" ]; then
        echo "JAR updated in S3, restarting app..." >> ${LOG_PATH}
        start_app
    fi
done &