import json
import boto3
import os
import uuid
from datetime import datetime

s3 = boto3.client("s3")

BUCKET_NAME = os.environ["BUCKET_NAME"]

def lambda_handler(event, context):
    # Example event payload
    data = {
        "event_id": str(uuid.uuid4()),
        "timestamp": datetime.utcnow().isoformat(),
        "event": event
    }

    # Convert to JSON
    body = json.dumps(data)

    # Create a unique file name
    key = f"events/{data['event_id']}.json"

    # Upload to S3
    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=key,
        Body=body,
        ContentType="application/json"
    )

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Event stored in S3",
            "s3_key": key
        })
    }
