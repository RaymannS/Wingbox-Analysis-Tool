import os
from flask import Flask, render_template
from logic import meow

# http://127.0.0.1:5000

app = Flask(__name__)


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/geometry')
def geo():
    return 'Geometry!' + str(meow(2,3))

@app.route('/loads')
def load():
    return 'Loads!'






