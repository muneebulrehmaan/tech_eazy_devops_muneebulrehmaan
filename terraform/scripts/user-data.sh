#!/bin/bash
set -e

# Variables from Terraform
S3_BUCKET="${S3_BUCKET}"
JAR_FILE="${JAR_FILE}"
APP_NAME="${APP_NAME}"
REGION="${REGION}"

# Install required packages
yum update -y
yum install -y java-17-amazon-corretto-headless aws-cli

# Create application directory
mkdir -p /opt/${APP_NAME}
cd /opt/${APP_NAME}

# Download JAR file with retry logic
echo "Downloading JAR from S3..."
for i in {1..5}; do
    if aws s3 cp s3://${S3_BUCKET}/${JAR_FILE} ./app.jar; then
        echo "JAR downloaded successfully"
        break
    else
        echo "Download attempt $i failed, retrying in 5 seconds..."
        sleep 5
    fi
done

# Verify JAR file exists and is not empty
if [ ! -f "app.jar" ] || [ ! -s "app.jar" ]; then
    echo "ERROR: JAR file missing or empty! Cannot start application."
    echo "S3 Bucket: ${S3_BUCKET}"
    echo "JAR File: ${JAR_FILE}"
    exit 1
fi

echo "JAR file verified: $(ls -lh app.jar)"

# Start application
echo "Starting Spring Boot application..."
nohup java -jar app.jar --server.port=8080 > app.log 2>&1 &
APP_PID=$!
echo $APP_PID > app.pid
echo "Java process started with PID: $APP_PID"

# Wait for application to start and be healthy
echo "Waiting for application to start..."
MAX_WAIT=30
for i in $(seq 1 $MAX_WAIT); do
    # Check if Java process is still running
    if ! ps -p $APP_PID > /dev/null; then
        echo "ERROR: Java process died! Check app.log for errors:"
        tail -20 app.log
        exit 1
    fi
    
    # Check if application is responding
    if curl -s --connect-timeout 5 http://localhost:8080/hello > /dev/null; then
        echo "✅ Application started successfully and is responding!"
        echo "Startup completed at $(date)" >> deployment.log
        break
    else
        echo "⏳ Waiting for application to start... ($i/$MAX_WAIT)"
        sleep 10
    fi
    
    # If we've waited 5 minutes and still not ready, something is wrong
    if [ $i -eq $MAX_WAIT ]; then
        echo "❌ Application failed to start within 5 minutes"
        echo "=== Last 20 lines of app.log ==="
        tail -20 app.log
        echo "=== Java process status ==="
        ps aux | grep java
        exit 1
    fi
done

# Simple S3 polling (start after app is confirmed working)
cat << 'POLL_EOF' > /opt/${APP_NAME}/poll_s3.sh
#!/bin/bash
while true; do
    sleep 60
done
POLL_EOF

chmod +x /opt/${APP_NAME}/poll_s3.sh
nohup /opt/${APP_NAME}/poll_s3.sh > /opt/${APP_NAME}/poll.log 2>&1 &

echo "Instance setup completed successfully at $(date)"