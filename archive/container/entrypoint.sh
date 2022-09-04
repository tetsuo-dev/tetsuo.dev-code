#!/usr/bin/bash

set -x
#unitd --no-daemon --modules /usr/lib/unit/modules --control 0.0.0.0:8888 --pid /fooble/unit.pid --log /fooble/unit.log --state /fooble/state
chown unit:unit /${PVC}
git clone https://github.com/codecowboydotio/git-pull-api /${PVC}/git-pull-api
unitd --modules /usr/lib/unit/modules --control 0.0.0.0:8888 --pid /${PVC}/unit.pid --log /${PVC}/unit.log 
download_config()
{
set -x
  CONFIG_URL=$1
  if [ -z CONFIG_URL ]
  then
    echo "No URL was passed to the download config function - no config will be downloaded"
  else
    curl -s $CONFIG_URL | tee -a | curl -X PUT 127.0.0.1:8888/config -d @-
  fi
}
download_config ${UNIT_CONFIG_URL}

tail -f ${PVC}/unit.log
