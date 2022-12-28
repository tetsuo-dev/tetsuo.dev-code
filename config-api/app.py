from flask import Flask, jsonify, request, redirect
from flasgger import Swagger
from flasgger.utils import swag_from, validate
from jsonschema import ValidationError
import json
from pathlib import Path

app = Flask(__name__)
swagger = Swagger(app)

@app.route ('/')
def root():
    return redirect("/apidocs", code=302)
@app.route('/app', methods=['POST'])
@swag_from('app.yml')
def config():
    result_data = request.get_data()
    print(result_data)
    data = request.get_json(force=True)
    name = data['name']

    f = open('unit-configs/foo')
  
    # returns JSON object as 
    # a dictionary
    data = json.load(f)

    return jsonify(data)

@app.route('/info', methods=['GET'])
@swag_from('info.yml')
def info():
    msg = 'This is the API that you see'
    api_ver = '1.0'
    
    return jsonify(status=msg, version=api_ver)

if __name__ == "__main__":
  app.run(host='0.0.0.0')
