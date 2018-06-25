#!/bin/sh

set -e

TEMP=`getopt -o vdm: --long smtp:,pop3:,account:,console:,host:,password: \
	-n 'setup' -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1; fi

eval set -- "$TEMP"

SMTP=9025
POP3=9110
CONSOLE=4555
ACCOUNT=no-rep
HOST=codespeed.tk
PASSWORD='codespeed_admin110'

sudo yum install -y yum-utils \
	device-mapper-persistent-data \
	lvm2 \
	telnet \
	expect
sudo yum-config-manager \
	--add-repo \
	https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce
sudo systemctl start docker
docker pull paracode/james2

while true;do
  case "$1" in
    --smtp ) SMTP="$2"; shift 2 ;;
    --pop3 ) POP3="$2"; shift 2 ;;
    --console ) CONSOLE="$2"; shift 2 ;;
    --host ) HOST="$2"; shift 2 ;;
    --password ) PASSWORD="$2"; shift 2 ;;
    --account ) ACCOUNT="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done
ENV_HOST="host="${HOST}
ENV_PASSWORD="password="${PASSWORD}
CONTAINER=`docker run -d -p $SMTP:25 -p $POP3:110 -p $CONSOLE:4555 -e $ENV_HOST -e $ENV_PASSWORD paracode/james2`
echo Initializing user...
CONSOLE_IP=$(docker inspect $CONTAINER|grep 'IPAddress'|grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|head -n 1)
USER=${ACCOUNT}"@"${HOST}
sleep 30
expect init.sh $CONSOLE_IP $CONSOLE $USER $PASSWORD
