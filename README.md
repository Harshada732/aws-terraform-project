Enterprise AWS Infrastructure with Terraform

Project Overview

This project demonstrates a production-ready AWS cloud infrastructure built using Terraform (Infrastructure as Code).

The infrastructure automates deployment of networking, compute, storage, monitoring, load balancing, auto scaling, and database services on AWS.

AWS Services Used

- Amazon VPC
- Public Subnets
- Internet Gateway
- Route Tables
- Security Groups
- EC2 Instance
- S3 Bucket
- IAM Role & Instance Profile
- CloudWatch Alarm
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- Amazon RDS (MySQL)

Architecture

User
↓
Application Load Balancer (ALB)
↓
Auto Scaling Group
↓
EC2 Instances
↓
RDS MySQL Database

Additional Services:

- VPC Networking
- IAM Access Management
- S3 Storage
- CloudWatch Monitoring

Features

- Infrastructure as Code using Terraform
- Automated AWS Resource Provisioning
- Highly Available Architecture
- Load Balancing with ALB
- Auto Scaling for High Availability
- Centralized Monitoring with CloudWatch
- Secure IAM Role Integration
- Managed MySQL Database with RDS

Terraform Commands

Initialize Terraform

terraform init

Validate Configuration

terraform validate

Create Execution Plan

terraform plan

Deploy Infrastructure

terraform apply

Destroy Infrastructure

terraform destroy

Project Outcome

Successfully designed and deployed an enterprise AWS infrastructure using Terraform, demonstrating Cloud Engineering and DevOps practices.

Author

Harshada Ghadwaje

AWS Cloud & DevOps Enthusiast