#!/bin/bash
set -e

# colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NCOLOR='\033[0m'

# color coded output funcs
function echoPass() {
	echo -e "${GREEN}[PASS]${NCOLOR} $1"
}

function echoFail() {
	echo -e "${RED}[FAIL]${NCOLOR} $1"
}

[[ ! $(id -u) == 0 ]] && echo you gotta be root && exit 256

echoPass "---------Installing Docker---------"
yum install docker -y
systemctl start docker
usermod -aG docker ec2-user
echoPass "---------Completed Docker installation---------"

echoPass "---------Installing AWS CLI---------"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
echoPass "---------Completed set up---------"