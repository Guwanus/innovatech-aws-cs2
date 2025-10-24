import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Notify action received event: %s", json.dumps(event))
    # Placeholder: integrate with SES/SNS/incident system
    # For demo, just log
    return {"status":"notified"}
