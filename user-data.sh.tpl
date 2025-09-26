#!/bin/bash
yum update -y
yum install -y aws-cli

# Create shutdown script
cat <<EOF > /etc/rc0.d/S99upload-logs.sh
#!/bin/bash
BUCKET_NAME="${bucket_name}"
LOG_FILE="/var/log/cloud-init.log"

/usr/bin/aws s3 cp $LOG_FILE s3://$BUCKET_NAME/cloud-init.log
EOF

chmod +x /etc/rc0.d/S99upload-logs.sh
