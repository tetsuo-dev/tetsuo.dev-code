#!/bin/bash

UNIT_VERSION="1.30.0-1~lunar"
UNATTENDED=0
INTERACTIVE=0
export DEBIAN_FRONTEND=noninteractive

help() {

  echo "TETSUO INSTALLER"
  echo "${0##*/}"
  echo "-h | --help: This help message"
  echo "-u | --unattended: Unattended installation"
  echo "-i | --interactive: Interactive installation"
}

# We translate all of the options to upper case to make it easier to deal with.
while [ $# -gt 0 ]; do
  OPTION=$(echo $1 | tr '[a-z]' '[A-Z]')
  case $OPTION in
    "-H" | "--HELP" )
       help
       shift
       ;;
    "-U" | "--UNATTENDED" )
       UNATTENDED=1
       shift
       ;;
    "-I" | "--INTERACTIVE" )
       INTERACTIVE=1
       shift
       ;;
    *) echo "Catch all detected"
       shift
       ;;
  esac
done

if [ $UNATTENDED -eq 1 ] && [ $INTERACTIVE -eq 1 ]; then
        echo "You cannot perform both an Interactive and Unattended installation at the same time."
fi

output_off() {
  FILE=/tmp/firstrun.log
  if [ ! -e $FILE ]
  then
   touch $FILE
   exit
  fi

  exec &>>$FILE
}

output_on() {
  exec &>$(tty)
}

if [ "$UNATTENDED" = 1 ] ; then
	output_off
	sleep 3
fi
if [ "$INTERACTIVE" = 1 ] ; then
	output_on
fi




echo "firstrun debug: starting-config"
sudo curl --output /usr/share/keyrings/nginx-keyring.gpg  \
      https://unit.nginx.org/keys/nginx-keyring.gpg
cat << EOF >  /etc/apt/sources.list.d/unit.list
deb [signed-by=/usr/share/keyrings/nginx-keyring.gpg] https://packages.nginx.org/unit/ubuntu/ lunar unit
deb-src [signed-by=/usr/share/keyrings/nginx-keyring.gpg] https://packages.nginx.org/unit/ubuntu/ lunar unit
EOF
apt update
apt install -y build-essential libcap2-bin net-tools jq
apt install -y nodejs npm
curl -sL https://deb.nodesource.com/setup_X.Y | sudo bash -
apt install -y nodejs
npm install -g node-gyp
apt install -y php-dev libphp-embed
apt install -y libperl-dev
apt install -y python-dev-is-python3
apt install -y ruby-dev
apt install -y openjdk-X-jdk
apt install -y libssl-dev
apt install -y libpcre2-dev
apt install -y libpcre3-dev
apt install -y golang-go
apt install -y python-is-python3
apt update
apt install -y php php-dev libphp-embed
apt update
#curl -L https://go.dev/dl/go1.19.linux-amd64.tar.gz -o /tmp/go1.19.linux-amd64.tar.gz
curl -L https://go.dev/dl/go1.20.4.linux-amd64.tar.gz -o /tmp/go1.20.4.linux-amd64.tar.gz
tar -C /usr/local -xzf /tmp/go1.20.4.linux-amd64.tar.gz


export PATH=$PATH:/usr/local/go/bin
echo "########################################################################################"
#apt install -y unit=$UNIT_VERSION
apt install -y unit
echo "########################################################################################"
#apt install -y unit-dev=$UNIT_VERSION
#apt install -y unit-go=$UNIT_VERSION
#apt install -y unit-jsc11=$UNIT_VERSION
#apt install -y unit-jsc17=$UNIT_VERSION
#apt install -y unit-jsc18=$UNIT_VERSION
#apt install -y unit-jsc19=$UNIT_VERSION
#apt install -y unit-jsc20=$UNIT_VERSION
#apt install -y unit-perl=$UNIT_VERSION
#apt install -y unit-php=$UNIT_VERSION
#apt install -y unit-python3.11 
#apt install -y unit-ruby
#apt install -y unit-python3.11
#
apt install -y unit-dev unit-go unit-jsc11 unit-jsc17 unit-jsc18 unit-jsc19 unit-jsc20  \
              unit-perl unit-php unit-python3.11 unit-ruby unit-wasm
systemctl restart unit



echo "########################################################################################"
sleep 30
systemctl start unit
mkdir -p /apps/status
chown unit:unit /apps
cat << EOF > /apps/status/index.html
<HTML>
<head>
  <meta http-equiv="refresh" content="10">
</head> 
<body>
<p>Unit Installed</p>
EOF
curl -X PUT --data-binary '{
        "listeners": {
                "*:8080": {
                        "pass": "routes"
                }
        },

        "routes": [
                {
                        "action": {
                                "share": "/apps/status/"
                        }
                }
        ]
}' --unix-socket /var/run/control.unit.sock http://localhost/config/
##apt install -y docker.io
##echo "<p>installed docker runtime...</p>" >> /apps/status/index.html
apt install -y nodejs npm
echo "<p>installed node and npm</p>" >> /apps/status/index.html
systemctl stop apache2
echo "<p>stopped default apache server</p>" >> /apps/status/index.html
echo "################"
echo "Performing app installations"
apt install -y python3-pip python3
apt install -y python3-flask-2.2.3
apt install -y python3-flasgger
apt install -y python3-git
apt install -y gunicorn
apt install -y python3-flask-cors
apt install -y python3-flask-restful
echo "<p>Installed Unit GIT API pre-requisites</p>" >> /apps/status/index.html
echo "################"
echo "Unit pre-reqs done, moving to app install"
pkill unitd
mkdir /home/unit
chown unit:unit /home/unit
usermod -d /home/unit unit
usermod -s /bin/bash unit
MY_IP=$(ip -br addr | grep eth0 | awk '{print $3}' | awk -F"/" '{print $1}' | head -1)
unitd --modulesdir /usr/lib/unit/modules --control 0.0.0.0:8888 --user root --group root --group root
cd /apps
git clone -b rel-0.9 https://github.com/tetsuo-dev/tetsuo.dev-code
echo "<p>Cloned TETSUO</p>" >> /apps/status/index.html
######### BUILD GOLANG MODULES###########
#cd /apps/tetsuo.dev-code/go-rest-api
#export GO111MODULE=on
#rm -rf go.mod
#sleep 5
#go mod init go-rest-api
#go mod tidy
#pwd
#id
#whoami
#export GOMODCACHE=/root/go
#export HOME=/root/
#echo "running go get"
#go get
#echo "running go build"
#go build
#echo "<p>built go api</p>" >> /apps/status/index.html
######### BUILD NPM MODULES###########
cd /apps/tetsuo.dev-code/multicast-sync
npm i
npm i unit-httpd
chown -R unit:unit /apps
set -x
curl -X PUT --data-binary '{
        "listeners": {
                "*:8080": {
                        "pass": "applications/tetsuo"
                },
                "*:3000": {
                        "pass": "applications/sync"
                },
                "*:8181": {
                        "pass": "applications/config-app"
                },
                "*:81": {
                             "pass": "routes"
                        }
        },

        "routes": [
                {
                        "match": {
                                "uri": "/ui3*"
                        },

                        "action": {
                                "share": "/apps/tetsuo.dev-code/ui3/index.html"
                        }
                },
                {
                        "match": {
                            "uri": "/ui*"
                        },

                        "action": {
                                "share": "/apps/tetsuo.dev-code/ui/index.html"
                        }
                },
                {
                        "match": {
                            "uri": "/api*"
                        },

                        "action": {
                                "pass": "applications/tetsuo"
                        }
                },
        ],

        "applications": {
		"tetsuo": {
                        "type": "python",
                        "path": "/apps/tetsuo.dev-code/git-api",
                        "working_directory": "/apps/tetsuo.dev-code/git-api",
                        "module": "wsgi",
                        "callable": "app"
                },
		"config-app": {
                        "type": "python",
                        "path": "/apps/tetsuo.dev-code/config-api",
                        "working_directory": "/apps/tetsuo.dev-code/config-api",
                        "module": "wsgi",
                        "callable": "app"
                },
                "sync": {
                       "type": "external",
                       "working_directory": "/apps/tetsuo.dev-code/multicast-sync",
                       "executable": "/usr/bin/env",
                       "stdout": "/tmp/sync.out",
                       "stderr": "/tmp/sync_err.log",
                       "arguments": [
                           "node",
                           "--experimental-modules",
                           "--loader",
                           "unit-http/loader.mjs",
                           "--require",
                           "unit-http/loader",
                           "sync.js"
                       ]
                }
        }
}' http://127.0.0.1:8888/config
echo "<p>Applied tetsuo config</p>" >> /apps/status/index.html
echo "<p>FINISHED</p>" >> /apps/status/index.html
echo "firstrun debug: finished-config"
