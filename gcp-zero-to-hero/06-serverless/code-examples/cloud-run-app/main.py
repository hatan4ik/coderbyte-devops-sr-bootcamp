# A simple Flask web application for the Cloud Run demo.

import os
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    """Returns a simple greeting."""
    return 'Hello from Cloud Run!'

if __name__ == "__main__":
    # Cloud Run injects the PORT environment variable.
    # We default to 8080 for local development.
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
