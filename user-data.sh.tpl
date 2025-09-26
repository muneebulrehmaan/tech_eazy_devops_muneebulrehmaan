<<<<<<< HEAD
#!/bin/bash
yum update -y
yum install -y aws-cli

BUCKET_NAME="${bucket_name}"

# Create systemd service to upload logs on shutdown
cat <<EOF | sudo tee /etc/systemd/system/upload-logs.service
[Unit]
Description=Upload EC2 logs to S3 on shutdown
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/usr/bin/true
ExecStop=/usr/bin/aws s3 cp /var/log/cloud-init.log s3://$BUCKET_NAME/cloud-init.log

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable upload-logs.service

# Optional: Test run now (comment out if not desired)
#/usr/bin/aws s3 cp /var/log/cloud-init.log s3://$BUCKET_NAME/cloud-init.log
=======
#!/bin/bash
yum update -y
yum install -y aws-cli

BUCKET_NAME="${bucket_name}"

# Create systemd service to upload logs on shutdown
cat <<EOF | sudo tee /etc/systemd/system/upload-logs.service
[Unit]
Description=Upload EC2 logs to S3 on shutdown
DefaultDependencies=no
Before=shutdown.target

[Service]
Type=oneshot
ExecStart=/usr/bin/true
ExecStop=/usr/bin/aws s3 cp /var/log/cloud-init.log s3://$BUCKET_NAME/cloud-init.log

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable upload-logs.service

# Optional: Test run now (comment out if not desired)
#/usr/bin/aws s3 cp /var/log/cloud-init.log s3://$BUCKET_NAME/cloud-init.log
>>>>>>> 049dcd7118c26d6f34811de6e7f6c4c092c07c97
