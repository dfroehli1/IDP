# 🚀 IDP Terraform + AWS Infrastructure Pipeline

This project provisions and deploys a serverless AWS-based application using Terraform and GitHub Actions. It follows a multi-stage Infrastructure-as-Code (IaC) pipeline with a bootstrap layer and application infrastructure layers.

---

# 🏗️ Architecture Overview

The system is split into three layers:

## 1. Bootstrap Layer (One-time setup)
Responsible for creating shared Terraform infrastructure:

- S3 bucket (Terraform state backend)
- DynamoDB table (state locking)

> This layer is only run when initializing the environment.

---

## 2. Infrastructure Layer (App Foundation)

Managed via `modules/infra/`

Responsible for application-level infrastructure:

- ECR repository (Docker image storage)
- S3 service bucket (application data)
- IAM roles (future expansion)
- Shared AWS resources for services

---

## 3. Lambda Deployment Layer

Managed via `modules/lambda/`

Responsible for:

- AWS Lambda function
- IAM execution role
- Container-based deployment (ECR image)
- Environment variables (e.g., S3 bucket access)

---

# 🔄 CI/CD Pipeline (GitHub Actions)

The pipeline provision.yml is triggered by a Curl command:

curl -X POST http://localhost:8000/provision \
  -H "Content-Type: application/json" \
  -d '{
    "app_name": "team-deb-service"
  }'

The pipeline runs in three stages:

## 1. Infra Provisioning
- Provisions ECR + supporting infrastructure
- Outputs ECR repository URL

## 2. Build & Push
- Builds Docker image for Lambda
- Pushes image to ECR

## 3. Lambda Deploy
- Deploys Lambda using Terraform
- Injects new image URI

---

# 4. Folder Structure

IDP/
├── CLAUDE.md
├── README.md
├── .github/
│   └── workflows/
│       └── provision.yml        # CI/CD pipeline (3-job GitHub Actions workflow)
├── ai-logs
│   └── claude-session.logs
├── api/
│   ├── main.py                  # FastAPI app — POST /provision endpoint
│   ├── requirements.txt         # Python dependencies (fastapi, uvicorn, requests, python-dotenv)
│   └── .env                     # GITHUB_TOKEN — DO NOT COMMIT (already in .gitignore)
├── bootstrap/
│   ├── main.tf                  # Creates S3 state bucket + DynamoDB lock table
│   ├── variables.tf
│   └── outputs.tf
└── terraform/
    ├── infra/                   # Stack: provisions ECR repo + application S3 bucket
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── lambda/                  # Stack: deploys Lambda + API Gateway + IAM
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── modules/
        ├── infra/               # Reusable module: ECR + S3 resources
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        └── lambda/              # Reusable module: Lambda + API Gateway + IAM role
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── app/
                ├── Dockerfile   # AWS Lambda Python 3.11 base image
                └── handler.py   # Lambda handler: stores event JSON to S3
