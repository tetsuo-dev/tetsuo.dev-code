#!/bin/bash
set -x
curl -s -X POST -H "Content-Type: application/json" http://10.1.1.150:8080/pull -d '{"url":"https://github.com/codecowboydotio/swapi-json-server", "branch":"dev"}'| jq
set +x
echo; echo
sleep 5
set -x
curl -s -X POST -H "Content-Type: application/json" http://10.1.1.150:8080/pull -d '{"url":"https://github.com/codecowboydotio/swapi-json-server", "branch":"ev"}'| jq
set +x
echo; echo
sleep 5
set -x
curl -s -X POST -H "Content-Type: application/json" http://10.1.1.150:8080/pull -d '{"branch":"ev"}'| jq
curl -s -X POST -H "Content-Type: application/json" http://10.1.1.150:8080/pull -d '{"url":"https://github.com/codecowboydotio/swapi-json-server"}'| jq
