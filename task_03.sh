#!/bin/bash

E_NONSUDO=101

[[ $UID -eq -0 ]] || {
	echo "Permission denied!"
	echo "Exiting..."
	exit $E_NONSUDO
}

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

which aws &> /dev/null
if [[ $? -ne 0 ]]
then
	echo "aws-cli not installed!"
	echo "Installing aws-cli..."
	temp=$(uname -m)
	echo "System architecture: ${temp}"
	uname -m | grep x86
	if [[ $? -eq 0 ]]
	then
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
		which unzip
		if [[ $? -ne 0 ]]
		then
			echo "Unzip not found, installing unzip..."
			apt-get install unzip -y
		fi
		unzip awscliv2.zip
		sudo ./aws/install &> /dev//null
	else
		grep arm <<<temp
		if [[ $? -eq 0 ]]
		then
			curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
			which unzip
			if [[ $? -ne 0 ]]
			then
				echo "Unzip not found, installing unzip..."
				apt-get install unzip -y
			fi
			unzip awscliv2.zip
			sudo ./aws/install &> /dev/null
		fi
	fi
else
	VERSION=`awk '{print $1}' <<<\`aws --version\``
	echo "${VERSION//// } is already installed in your machine"
fi
