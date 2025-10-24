import json
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)
dynamodb = boto3.resource("dynamodb", region_name=os.getenv("AWS_REGION","eu-central-1"))
TABLE_NAME = os.getenv("BLOCKED_TABLE", "cs2-ma-nca-blockedips")
TABLE_NAME = os.getenv("BLOCKED_TABLE", "cs2-ma-nca-events")
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    logger.info("BlockIP event: %s", json.dumps(event))
    ip = event.get("ip")
    if not ip:
        return {"status":"no-ip"}
    table = dynamodb.Table(TABLE_NAME)
    table.put_item(Item={"ip": ip, "reason": event.get("reason","auto-block"), "ts": int(context.aws_request_id[:8],16)})
    return {"status":"blocked", "ip": ip}
