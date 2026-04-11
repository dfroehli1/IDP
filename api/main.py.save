from fastapi import FastAPI
import os
import requests
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
REPO = "dfroehli1/IDP"

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


@app.post("/provision")
def provision(request: dict):
    status, text = trigger_github_workflow(request)

    return {
        "message": "GitHub workflow triggered",
        "status": status,
        "response": text
    }
