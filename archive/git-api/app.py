from flask import Flask, jsonify, request, redirect
from flasgger import Swagger
from flasgger.utils import swag_from, validate
from jsonschema import ValidationError
import git
from git import Repo
from pathlib import Path

app = Flask(__name__)
swagger = Swagger(app)

@app.route ('/')
def root():
    return redirect("/apidocs", code=302)
@app.route('/pull', methods=['POST'])
@swag_from('pull.yml')
def pull():
    result_data = request.get_data()
    print(result_data)
    data = request.get_json(force=True)
    repo = data['repo']
    branch = data['branch']
    dest   = data['dest']

    path_exists = Path(dest).is_dir()
    if path_exists == True:
      git_repo = Repo(dest)
      origin = git_repo.remotes.origin 
      origin.fetch()
      origin.pull()
    else:
      Repo.clone_from(repo, dest)    

    return jsonify(repo=repo, branch=branch, dest=dest)

@app.route('/info', methods=['GET'])
@swag_from('info.yml')
def info():
    msg = 'This is the API that you see'
    api_ver = '1.0'
    
    return jsonify(status=msg, version=api_ver)

if __name__ == "__main__":
  app.run(host='0.0.0.0')
