import os
from flask import Flask, render_template, request, jsonify
from logic.simple_logic import meow, bark
import subprocess

# http://127.0.0.1:5000
# flask --app wingbox run --debug

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/geometry')
def geometry():
    return render_template('index_geo.html')

@app.route('/loads')
def loads():
    return 'Loads!'

@app.route('/calculate', methods=['POST'])
def calculate():
    try:
        data = request.json  # Get JSON data from frontend
        numbers = data.get("numbers", [])  # Extract number

        # Run the C++ script and pass the number
        result = subprocess.run(
            ["./logic/logic_calcs.exe"],  # Run compiled C++ script
            input=" ".join(map(str, numbers)),  # Send number as input
            text=True,
            capture_output=True
        )
        # Get the output (modified number)
        modified_value = result.stdout.strip().split()

        return jsonify({"result": modified_value})  # Send back to frontend

    except Exception as e:
        return jsonify({"error": str(e)}), 500  # Return error if something goes wrong






