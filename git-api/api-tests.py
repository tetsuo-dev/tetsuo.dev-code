#!/usr/bin/python

import requests

#def test_pull_api():
#  url = 'http://127.0.0.1/pull'
#  myobj = {"repo":"http://github.com/codecowboydotio/fw-tester", "branch":"gober", "dest":"/root/fw-tester-fooble"}
#  response = requests.post(url, data = myobj)
#  assert response.status_code == 200
#  assert response.headers['Content-Type'] == 'application/json'

def test_info_api():
  url = 'http://127.0.0.1/info'
  response = requests.get(url)
  assert response.status_code == 200

def test_docs():
  response = requests.get('http://127.0.0.1/apidocs')
  assert response.status_code == 200

def test_root():
  response = requests.get('http://127.0.0.1/')
  assert response.status_code == 200
