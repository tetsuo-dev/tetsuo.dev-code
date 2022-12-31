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
    port = data['port']
    w_dir = data['directory']

    f = open('unit-configs/foo')
  
    data = json.load(f)

    data['applications'][name] = data['applications'].pop('node')
    data['listeners']={ "*:" + port : { "pass": "applications/" + name} }
    data['applications'][name]['working_directory']=w_dir
    print(data['listeners'])
    print(data['applications'][name]['working_directory'])
    #for k, v in applications.items():
    #  print(k)
    #  print(v)
    payload = jsonify(data)
    r = request.post("http://127.0.0.1:8888/config", data=payload)
    return jsonify(data)

@app.route('/info', methods=['GET'])
@swag_from('info.yml')
def info():
    msg = 'This is the API that you see'
    api_ver = '1.0'
    
    return jsonify(status=msg, version=api_ver)

if __name__ == "__main__":
  app.run(host='0.0.0.0')
