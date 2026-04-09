import os
import socket
from flask import Flask, jsonify

app = Flask(__name__)

POD_NAME = os.environ.get("POD_NAME", socket.gethostname())
POD_IP   = os.environ.get("POD_IP", "unknown")
PORT     = int(os.environ.get("PORT", 8080))


@app.route("/", defaults={"path": ""})
@app.route("/<path:path>")
def index(path):
    return jsonify(pod_name=POD_NAME, pod_ip=POD_IP)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=PORT)
