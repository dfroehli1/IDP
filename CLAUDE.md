# CLAUDE.md — IDP (Infrastructure Deployment Platform)

## Project Purpose

IDP is a self-service infrastructure provisioning platform. Developers POST an app name to a FastAPI endpoint; the API triggers a GitHub Actions workflow that uses Terraform to create AWS infrastructure (ECR repo + S3 bucket), builds and pushes a Docker container to ECR, and deploys a Lambda function from that image. The Lambda handler stores incoming event payloads as JSON objects in S3.

---

## Architecture

Three layers run in sequence, each managed as a separate Terraform stack:

```
Developer → POST /provision (FastAPI)
              ↓
         GitHub repository_dispatch event
              ↓
    ┌─────────────────────────────────────┐
    │  GitHub Actions: provision.yml      │
    │                                     │
    │  Job 1: infra                       │
    │    terraform/infra/ → ECR + S3      │
    │         ↓ (ecr_repo_url output)     │
    │  Job 2: build                       │
    │    docker build + push to ECR       │
    │         ↓ (image_uri output)        │
    │  Job 3: deploy                      │
    │    terraform/lambda/ → Lambda + IAM │
    └─────────────────────────────────────┘
```

The **bootstrap layer** (`/bootstrap/`) is a one-time manual setup that creates the S3 bucket and DynamoDB table used as the shared Terraform state backend for all other stacks.

---

## Folder Structure

```
IDP/
├── CLAUDE.md
├── README.md
├── .github/
│   └── workflows/
│       └── provision.yml        # CI/CD pipeline (3-job GitHub Actions workflow)
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
    ├── lambda/                  # Stack: deploys Lambda function from ECR image
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── modules/
        ├── infra/               # Reusable module: ECR + S3 resources
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        └── lambda/              # Reusable module: Lambda function + IAM role
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            └── app/
                ├── Dockerfile   # AWS Lambda Python 3.11 base image
                └── handler.py   # Lambda handler: stores event JSON to S3
```

---

## Key Services and Modules

### `api/main.py` — FastAPI Provisioning Server

Exposes a single endpoint:

```
POST /provision
Body: { "app_name": "myapp", "runtime": "python3.12" }
```

Derives resource names (`{app_name}-bucket`, `{app_name}-lambda`, ECR repo `{app_name}`) and fires a `repository_dispatch` event of type `provision` to `dfroehli1/IDP` on GitHub. The `client_payload` carries all resource names into the workflow.

Requires `GITHUB_TOKEN` in `api/.env`.

### `.github/workflows/provision.yml` — CI/CD Pipeline

Triggered by `repository_dispatch` with event type `provision`. Three sequential jobs:

| Job | Directory | What it does |
|-----|-----------|-------------|
| `infra` | `terraform/infra/` | Creates ECR repo + S3 bucket; outputs `ecr_repo` URL |
| `build` | root | Logs into ECR, builds Docker image, pushes with `:latest` tag; outputs `image_uri` |
| `deploy` | `terraform/lambda/` | Creates Lambda function (image-based) + IAM role |

Job outputs are passed downstream via `needs.<job>.outputs.<name>`.

Requires GitHub Actions secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`.

### `terraform/modules/infra/` — Infra Module

Creates:
- `aws_ecr_repository` — named from `var.ecr_repo_name` (default: `idp-lambda`)
- `aws_s3_bucket` — named from `var.bucket_name`

### `terraform/modules/lambda/` — Lambda Module

Creates:
- `aws_lambda_function` — image-based, 512 MB, 30s timeout, Python 3.11 via ECR
- `aws_iam_role` — `{lambda_name}-role`, trust policy for Lambda service principal
- Attaches `AWSLambdaBasicExecutionRole` managed policy (CloudWatch Logs)
- Sets env var `BUCKET_NAME` on the function

### `terraform/modules/lambda/app/handler.py` — Lambda Handler

On each invocation:
1. Generates a UUID event ID and ISO timestamp
2. Serializes `{"event_id", "timestamp", "event"}` to JSON
3. Uploads to `s3://{BUCKET_NAME}/events/{event_id}.json`
4. Returns HTTP 200 with the S3 key

### `bootstrap/` — State Backend Setup

One-time Terraform run that creates:
- S3 bucket `team-deb-terraform-state` (versioning + AES256 encryption)
- DynamoDB table `idp-terraform-locks` (on-demand billing, `LockID` hash key)

---

## Build and Run Instructions

### Prerequisites

- AWS credentials with permissions for ECR, S3, Lambda, IAM, DynamoDB
- Terraform CLI
- Docker
- Python 3.12+
- A GitHub personal access token with `repo` scope

### 1. Bootstrap (One-time, manual)

```bash
cd bootstrap
terraform init
terraform apply \
  -var="state_bucket_name=team-deb-terraform-state" \
  -var="dynamodb_table_name=idp-terraform-locks"
```

Do this only once per environment. The state for this layer is stored locally in `bootstrap/terraform.tfstate`.

### 2. Run the API Server

```bash
cd api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create the .env file
echo "GITHUB_TOKEN=<your-token>" > .env

uvicorn main:app --host 0.0.0.0 --port 8000
```

### 3. Trigger a Provision

```bash
curl -X POST http://localhost:8000/provision \
  -H "Content-Type: application/json" \
  -d '{"app_name": "myapp"}'
```

This fires a GitHub repository_dispatch event, which kicks off the Actions workflow. Monitor progress at `https://github.com/dfroehli1/IDP/actions`.

### 4. Manual Terraform Deployment (bypassing API)

```bash
# Step 1 — Infra
cd terraform/infra
terraform init
terraform apply -var="bucket_name=myapp-bucket" -var="ecr_repo_name=myapp"

# Step 2 — Build and push image manually
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker build -t myapp ./terraform/modules/lambda/app
docker tag myapp:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest

# Step 3 — Deploy Lambda
cd terraform/lambda
terraform init
terraform apply \
  -var="lambda_name=myapp-lambda" \
  -var="bucket_name=myapp-bucket" \
  -var="image_uri=<account-id>.dkr.ecr.us-east-1.amazonaws.com/myapp:latest"
```

---

## Terraform State Backend

All stacks share the same S3 backend. Each uses a distinct state key:

| Stack | State key |
|-------|-----------|
| `bootstrap/` | local (`terraform.tfstate`) |
| `terraform/infra/` | `infra/terraform.tfstate` |
| `terraform/lambda/` | `lambda/terraform.tfstate` |

Backend config (in each stack's `main.tf`):
```hcl
backend "s3" {
  bucket         = "team-deb-terraform-state"
  key            = "<stack>/terraform.tfstate"
  region         = "us-east-1"
  dynamodb_table = "idp-terraform-locks"
  encrypt        = true
}
```

---

## Naming Conventions

| Resource | Pattern |
|----------|---------|
| S3 app bucket | `{app_name}-bucket` |
| Lambda function | `{app_name}-lambda` |
| ECR repository | `{app_name}` |
| IAM role | `{app_name}-lambda-role` |
| S3 event objects | `events/{uuid}.json` |

All AWS resources are in **`us-east-1`**.

---

## Important Conventions

- **Terraform stacks vs. modules:** `terraform/infra/` and `terraform/lambda/` are stacks (entry points). `terraform/modules/` contains the reusable modules they invoke. Add new resources to modules, not stacks.
- **All Terraform applies use `-auto-approve`** in CI/CD. There is no manual confirmation gate.
- **Variable passing in the workflow** uses `${{ github.event.client_payload.<field> }}` from the dispatch payload. Add new workflow inputs to both the API payload (`api/main.py`) and the workflow `-var` flags.
- **Job outputs** between workflow jobs use the pattern:
  ```yaml
  outputs:
    ecr_repo: ${{ steps.<step-id>.outputs.ecr_repo }}
  ```
  then consumed as `${{ needs.<job>.outputs.ecr_repo }}`.
- **Docker image tag** is always `:latest`. There is no versioned tagging.
- **Lambda package type is `Image`** (container-based), not zip. The Dockerfile lives in `terraform/modules/lambda/app/`.

---

## Environment Variables and Secrets

### Local API (`api/.env`)

```
GITHUB_TOKEN=<github-personal-access-token>
```

This file is in `.gitignore`. Never commit it.

### GitHub Actions Secrets

Configure these in the repo settings under **Settings → Secrets and variables → Actions**:

| Secret | Purpose |
|--------|---------|
| `AWS_ACCESS_KEY_ID` | AWS IAM access key |
| `AWS_SECRET_ACCESS_KEY` | AWS IAM secret key |

### Lambda Runtime

`BUCKET_NAME` is injected by Terraform as a Lambda environment variable. Do not hardcode it in `handler.py`.

---

## Known Gaps / Before You Contribute

- **No S3 write permissions on the Lambda IAM role.** The role has only `AWSLambdaBasicExecutionRole`. The handler will fail to write events unless an explicit `s3:PutObject` policy is added to the role in `terraform/modules/lambda/main.tf`.
- **No API authentication or rate limiting** on the FastAPI server. Do not expose it publicly without adding auth.
- **No tests.** There is no test suite, no linting config, and no CI check on the Python code.
- **Hardcoded GitHub repo** (`dfroehli1/IDP`) in `api/main.py`. Update this constant if forking.
- **Bootstrap state is local.** The `bootstrap/terraform.tfstate` file is tracked in git — this works for a single developer but breaks for teams. Migrate to a separate remote backend or use Terraform Cloud for the bootstrap layer in a shared environment.
- **Single ECR image tag (`:latest`).** Concurrent provisions will overwrite each other's image. Add per-deploy tagging (e.g., git SHA) if supporting parallel deployments.
