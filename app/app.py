import requests
from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/health")
def health():
    return jsonify(status="ok")


@app.route("/status")
def status():
    upstream = requests.get("https://httpbin.org/status/200", timeout=5)
    return jsonify(app="cortex-code-to-cloud-demo", upstream_status=upstream.status_code)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
