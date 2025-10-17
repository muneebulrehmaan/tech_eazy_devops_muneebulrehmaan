#!/bin/bash
set -euo pipefail

# Variables substituted by templatefile in Terraform launch template
APP_BUCKET_NAME="${app_bucket_name}"
JAR_NAME="${JAR_NAME}"
APP_PATH="${APP_PATH}"
LOG_PATH="${LOG_PATH}"

# Update & install awslogs
yum update -y
yum install -y awslogs aws-cli java-1.8.0-openjdk

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
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
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

# Fetch the latest JAR from S3 (retries to handle eventual consistency)
RETRIES=5
COUNT=0
until [ $${COUNT} -ge $${RETRIES} ]
do
  if aws s3 cp s3://$${APP_BUCKET_NAME}/$${JAR_NAME} $${APP_PATH}; then
    echo "Downloaded $${JAR_NAME} from s3://$${APP_BUCKET_NAME}" >> $${LOG_PATH}
    break
  else
    echo "Failed to download JAR, retrying... ($${COUNT})" >> $${LOG_PATH}
    COUNT=$$((COUNT+1))
    sleep 5
  fi
done


# Start the Java app in background and redirect output to app log
nohup java -jar ${APP_PATH} >> ${LOG_PATH} 2>&1 &

# Write PID & launched time
echo "App started with PID $! at $(date --iso-8601=seconds)" >> ${LOG_PATH}
