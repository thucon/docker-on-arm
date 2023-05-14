#!/usr/bin/env python3

from flask import Flask, request

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello World (from service)!"
