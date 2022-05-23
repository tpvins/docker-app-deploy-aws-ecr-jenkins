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

echoPass "---------Installing Git---------"
yum install git -y
GIT_VERSION=$(git --version)
echoPass "---------Completed git installation : ${GIT_VERSION}---------"

echoPass "---------Installing Java---------"
# yum install java-11-openjdk -y
yes y | amazon-linux-extras install java-openjdk11
JAVA_VERSION=$(java --version)
echoPass "---------Completed java installation : ${JAVA_VERSION}---------"

echoPass "---------Installing Jenkins---------"
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum upgrade -y
yum install jenkins -y
systemctl daemon-reload
echoPass "---------Completed Jenkins Installation---------"

echoPass "---------Installing Docker---------"
yum install docker -y
systemctl start docker
echoPass "---------Completed Docker installation---------"

echoPass "---------Post installation steps---------"
usermod -aG docker jenkins
systemctl restart jenkins
echoPass "---------Your Jenkins server is ready---------"