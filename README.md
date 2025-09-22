# Tech Eazy DevOps Project

## Overview
This project automates the deployment of a Java application from GitHub to an AWS EC2 instance. It supports **Dev** and **Prod** stages using a single deployment script. The application is built with **Maven** and runs on **Java 21**.

---

## Usage Instructions

1. Run the deployment script
```bash
chmod +x deploy.sh
./deploy.sh Dev
```
Note:The repo i cloned did not contain the jar fie mentioned in the PDF " java -jar target/techeazy-devops-0.0.1-SNAPSHOT.jar 
" instead we have"hellomvc-0.0.1-SNAPSHOT.jar "
