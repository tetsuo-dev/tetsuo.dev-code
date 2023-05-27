from flask import Flask, jsonify, request, redirect
from flasgger import Swagger
from flasgger.utils import swag_from, validate
from jsonschema import ValidationError
from jsonschema import validate
import git
from git import Repo
from pathlib import Path
from urllib.parse import urlparse
import pathlib

app = Flask(__name__)
cors = CORS(app, resources={r"/*": {"origins": "*"}})
swagger = Swagger(app)

@app.route ('/')
def root():
    return redirect("/apidocs", code=302)
@app.route('/pull', methods=['POST'])
@swag_from('pull.yml')
def pull():
    schema = {
        "type": "object",
        "properties": {
            "url": {"type": "string"},
            "branch": {"type": "string"},
        },
        "required": ["url", "branch"]
    }
    


    result_data = request.get_data()
    print(result_data)
    print("******")
    data = request.get_json(force=True)

    # Test k/v validity
    validate(instance={"url": data['url'], "branch": data['branch']}, schema=schema)
    print(data['url'])
    repo = data['url']
    branch = data['branch']
    parsed_url = urlparse(repo)
    dest = parsed_url.path
    app_name = pathlib.PurePath(dest)
    dest = "/apps/" + app_name.name

    print(dest)

    path_exists = Path(dest).is_dir()
    if path_exists == True:
      app_repo = Repo(dest)
      origin = app_repo.remotes.origin
      origin.fetch()
      origin.pull()
    else:
      Repo.clone_from(repo, dest, branch=branch)

    return jsonify(repo=repo, branch=branch, dest=dest)

@app.route('/info', methods=['GET'])
#@swag_from('info.yml')
def info():
    msg = 'This is the API that you see'
    api_ver = '1.0'

    return jsonify(status=msg, version=api_ver)

if __name__ == "__main__":
  app.run(host='0.0.0.0')
