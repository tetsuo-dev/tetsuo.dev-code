from flask import Flask, jsonify, request, redirect
from flasgger import Swagger
from flasgger.utils import swag_from, validate
from jsonschema import ValidationError
import json
from pathlib import Path
import requests
import os
import subprocess
import time
from subprocess import PIPE, run


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
    print(data)
    os.chdir(w_dir)
    result = subprocess.run(['/usr/bin/npm', 'install'], stdout=PIPE, stderr=PIPE, universal_newlines=True)
    print(result.returncode, result.stdout, result.stderr)

    # update the application component
    url = "http://127.0.0.1:8888/config/applications/" + name
    app_r = requests.put(url, json=data['applications'][name])
    print(app_r.text)
    time.sleep(15)

    # update the listener
    url = "http://127.0.0.1:8888/config/listeners/" + "*:" + port
    print(url)
    listener_r = requests.put(url, json=data['listeners']['*:' + port])
    print(listener_r.text)
    return (app_r.content, listener_r.content)

@app.route('/info', methods=['GET'])
@swag_from('info.yml')
def info():
    msg = 'This is the API that you see'
    api_ver = '1.0'
    
    return jsonify(status=msg, version=api_ver)

if __name__ == "__main__":
  app.run(host='0.0.0.0')
