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

systemctl status nginx &> /dev/null
if [[ $? -eq 0 ]]
then
	echo -e "${GREEN}NGINX is Running${NC}"
else
	echo -e "${RED}NGINX is Dead. Do you want to run NGINX [y/n]? ${NC}" 
# 	read -p "Do you want to run NGINX [y/n]: " INPUT
	read -p "Enter choice: " INPUT
	if [[ $INPUT = 'y' ]]
	then
		echo "Running NGINX..."
		systemctl enable nginx
		systemctl start nginx
		if [[ $? -ne 0 ]]
		then
			echo -e "${RED}Something went wrong. NGINX cannot be activated${NC}"
		fi
	else
		echo "Exiting..."
		exit 0
	fi
fi
