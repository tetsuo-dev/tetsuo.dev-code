#!/bin/bash
set -x
curl -s -X POST -H "Content-Type: application/json" 127.0.0.1:8080/pull -d '{"url":"https://github.com/codecowboydotio/swapi-json-server", "branch":"main"}'| jq
