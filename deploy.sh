#!/bin/bash

# -------------------------------
# Deployment script for TechEazy
# -------------------------------

# 1. Read stage parameter
STAGE=$1
if [ -z "$STAGE" ]; then
    echo "Usage: ./deploy.sh <Dev|Prod>"
    exit 1
fi

# 2. Load config based on stage
CONFIG_FILE="${STAGE,,}_config.sh"  # converts stage to lowercase
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file $CONFIG_FILE not found!"
    exit 1
fi
source $CONFIG_FILE

echo "Deploying to $STAGE environment..."

# 3. Install dependencies
sudo apt update
sudo apt install -y openjdk-$JAVA_VERSION-jdk maven git

# 4. Clone repository if not already present
if [ ! -f pom.xml ]; then
    git clone $REPO_URL
fi
cd test-repo-for-devops

# 5. Build the project with Maven
mvn clean package

# 6. Run the app in background using nohup
sudo nohup java -jar target/hellomvc-0.0.1-SNAPSHOT.jar > app.log 2>&1 &

# 7. Confirm the process is running
echo "Application started. PID:"
ps aux | grep java

# 8. Auto-stop EC2 instance (optional)
if [ ! -z "$STOP_AFTER_MINUTES" ] && [ "$STOP_AFTER_MINUTES" -gt 0 ]; then
    echo "Instance will stop after $STOP_AFTER_MINUTES minutes..."
    sleep $(($STOP_AFTER_MINUTES * 60))
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    aws ec2 stop-instances --instance-ids $INSTANCE_ID
    echo "Instance stopped."
fi
