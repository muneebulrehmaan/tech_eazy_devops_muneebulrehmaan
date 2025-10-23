#!/bin/bash
set -e

# Variables from Terraform
S3_BUCKET="${S3_BUCKET}"
JAR_FILE="${JAR_FILE}"
APP_NAME="${APP_NAME}"
REGION="${REGION}"

# Install required packages
yum update -y
yum install -y java-11-amazon-corretto-headless aws-cli

# Create application directory
mkdir -p /opt/${APP_NAME}
cd /opt/${APP_NAME}

# Function to download and run JAR
run_application() {
    echo "Downloading JAR from S3..."
    aws s3 cp s3://${S3_BUCKET}/${JAR_FILE} ./app.jar
    
    echo "Starting application..."
    nohup java -jar app.jar --server.port=8080 > app.log 2>&1 &
    echo $! > app.pid
    echo "Application started with PID: $(cat app.pid)"
}

# Initial run
run_application

# Install basic CloudWatch agent for system metrics
yum install -y amazon-cloudwatch-agent

# Start basic CloudWatch agent (uses default config)
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c default

# S3 polling script
cat << 'POLL_EOF' > /opt/${APP_NAME}/poll_s3.sh
#!/bin/bash
while true; do
    CURRENT_ETAG=$(aws s3api head-object --bucket ${S3_BUCKET} --key ${JAR_FILE} --query ETag --output text 2>/dev/null || echo "")
    
    if [ -f "/opt/${APP_NAME}/last_etag.txt" ]; then
        LAST_ETAG=$(cat /opt/${APP_NAME}/last_etag.txt)
    else
        LAST_ETAG=""
    fi
    
    if [ "$CURRENT_ETAG" != "$LAST_ETAG" ] && [ -n "$CURRENT_ETAG" ]; then
        echo "JAR file updated in S3. Current ETag: $CURRENT_ETAG, Last ETag: $LAST_ETAG"
        
        # Stop current application
        cd /opt/${APP_NAME}
        if [ -f app.pid ]; then
            PID=$(cat app.pid)
            if ps -p $PID > /dev/null; then
                kill $PID
                echo "Stopped application with PID: $PID"
            fi
            rm -f app.pid
        fi
        
        # Download and run new JAR
        aws s3 cp s3://${S3_BUCKET}/${JAR_FILE} ./app.jar
        nohup java -jar app.jar --server.port=8080 > app.log 2>&1 &
        echo $! > app.pid
        echo "Started new application with PID: $(cat app.pid)"
        
        # Update ETag
        echo $CURRENT_ETAG > /opt/${APP_NAME}/last_etag.txt
        
        # Log the update
        echo "$(date): Application updated from S3" >> /opt/${APP_NAME}/deployment.log
    fi
    
    sleep 30
done
POLL_EOF

chmod +x /opt/${APP_NAME}/poll_s3.sh

# Start S3 polling in background
nohup /opt/${APP_NAME}/poll_s3.sh > /opt/${APP_NAME}/poll.log 2>&1 &

echo "User data script completed successfully at $(date)" >> /opt/${APP_NAME}/deployment.log