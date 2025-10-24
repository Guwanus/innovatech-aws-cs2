# app/engine/engine.py
from flask import Flask, request, jsonify
import boto3
import os
import logging
import json

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

LAMBDA_NOTIFY = os.getenv("LAMBDA_NOTIFY_NAME", "action_notify")
LAMBDA_BLOCKIP = os.getenv("LAMBDA_BLOCKIP_NAME", "action_blockip")
AWS_REGION = os.getenv("AWS_REGION", "eu-west-1")

lambda_client = boto3.client("lambda", region_name=AWS_REGION)
dynamodb = boto3.resource("dynamodb", region_name=os.getenv("AWS_REGION", "eu-west-1"))
EVENT_TABLE = os.getenv("EVENT_TABLE", "cs2-ma-nca-events")


@app.route("/process", methods=["POST"])
def process_event():
    event = request.get_json(force=True)
    logging.info("Processing event: %s", json.dumps(event))

    # Basic rule: if severity == 'critical' or source == 'firewall' -> both actions
    severity = event.get("severity","")
    source = event.get("source","")
    ip = event.get("ip","unknown")

    # Always log (in production write to DB)
    try:
        if severity.lower() == "critical" or source == "firewall":
            payload_notify = {"event": event}
            lambda_client.invoke(FunctionName=LAMBDA_NOTIFY, InvocationType="Event", Payload=json.dumps(payload_notify))
            payload_block = {"ip": ip, "reason": "auto-block by rule"}
            lambda_client.invoke(FunctionName=LAMBDA_BLOCKIP, InvocationType="Event", Payload=json.dumps(payload_block))
            table = dynamodb.Table(EVENT_TABLE)
table.put_item(Item={
    "event_id": event.get("id", f"evt-{context.aws_request_id if 'context' in locals() else 'local'}"),
    "severity": severity,
    "source": source,
    "ip": ip,
    "status": "processed"
})
            return jsonify({"status":"actions_triggered"}), 200
        else:
            return jsonify({"status":"no_action"}), 200
    except Exception as e:
        logging.exception("Error invoking lambda")
        return jsonify({"status":"error","message": str(e)}), 500

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status":"ok"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
