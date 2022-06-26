#!/bin/bash

E_NONSUDO=101

[[ $UID -eq -0 ]] || {
	echo "Permission denied!"
	echo "Exiting..."
	exit $E_NONSUDO
}

# which nginx || echo "NGINX not found" || echo "NGINX installed"

which nginx
if [[ $? -eq 0 ]]
then
	echo "NGINX is installed"
	echo "Checking for NGINX updates..."
	apt-get upgrade nginx -y
else
	echo "NGINX not found"
	echo "Installing NGINX..."
	apt-get install nginx -y &> /dev/null
	echo "NGINX installed"
fi
