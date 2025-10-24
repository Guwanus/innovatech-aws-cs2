# app/listener/app.py
from flask import Flask, request, jsonify
import os
import requests
import logging
import json

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

ENGINE_URL = os.getenv("ENGINE_URL", "http://soar-engine:5000/process")

@app.route("/api/alerts", methods=["POST"])
def receive_alert():
    payload = request.get_json(force=True)
    logging.info("Received alert: %s", json.dumps(payload))
    # Forward to engine (in-cluster service name)
    try:
        resp = requests.post(ENGINE_URL, json=payload, timeout=5)
        return jsonify({"status": "forwarded", "engine_status": resp.status_code}), 200
    except Exception as e:
        logging.exception("Failed to forward to engine")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status":"ok"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
