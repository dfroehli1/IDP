from fastapi import FastAPI
from pydantic import BaseModel
import os
import requests
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO = "dfroehli1/IDP"


# ----------------------------
# 1. Developer Input Schema
# ----------------------------
class ProvisionRequest(BaseModel):
    app_name: str
    runtime: str = "python3.12"


# ----------------------------
# 2. Transform to Platform Payload
# ----------------------------
def build_payload(req: ProvisionRequest):
    return {
        "app_name": req.app_name,
        "bucket_name": f"{req.app_name}-bucket",
        "lambda_name": f"{req.app_name}-lambda",
        "ecr_repo": req.app_name,
        "runtime": req.runtime
    }


# ----------------------------
# 3. GitHub Trigger Function
# ----------------------------
def trigger_github_workflow(payload):
    url = f"https://api.github.com/repos/{REPO}/dispatches"

    headers = {
        "Authorization": f"Bearer {GITHUB_TOKEN}",
        "Accept": "application/vnd.github+json"
    }

    data = {
        "event_type": "provision",
        "client_payload": payload
    }

    response = requests.post(url, json=data, headers=headers)

    return response.status_code, response.text


# ----------------------------
# 4. Self-Service Endpoint
# ----------------------------
@app.post("/provision")
def provision(request: ProvisionRequest):
    payload = build_payload(request)

    status, text = trigger_github_workflow(payload)

    return {
        "message": "Provision request accepted",
        "input": request.dict(),
        "generated_payload": payload,
        "github_status": status,
        "github_response": text
    }
