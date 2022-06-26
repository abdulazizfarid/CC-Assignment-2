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

# Server  config information

S1_NAME='website-server'
S1_IMAGE_ID='ami-08d4ac5b634553e16'
S1_KEY_NAME='assignment-02-kp'
S1_SG_IDs='sg-0163bceeed4a99589'
S1_SUBNET='subnet-0e0f448971e3b084c'

# Server 2 config information

S2_NAME='ubuntu-server-02'
S2_IMAGE_ID='ami-08d4ac5b634553e16'
S2_KEY_NAME='assignment-02-kp'
S2_SG_IDs='sg-0163bceeed4a99589'
S2_SUBNET='subnet-0df58184476bc14f0'

which aws &> /dev/null
if [[ $? -ne 0 ]]
then
	echo "aws-cli not installed!"
	echo "Installing aws-cli..."
	temp=`uname -m`
	echo "System architecture: ${temp}"
	grep x86 temp
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
		grep arm temp
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
fi
aws ssm get-parameter --name "ADMIN_ACCESS_KEY_ID" --query Parameter.Value &> /dev/null
if [[ $? -ne 0 ]]
then
	echo "AWS credentials not configured, configuring..."
	ADMIN_ACCESS_KEY_ID=$(aws ssm get-parameter --name "ADMIN_ACCESS_KEY_ID" --query Parameter.Value | tr -d '"')
	ADMIN_SECRET_ACCESS_KEY=`aws ssm get-parameter --name "ADMIN_SECRET_ACCESS_KEY" --with-decryption --query Parameter.Value | tr -d '"'`
	aws configure set aws_access_key_id ${ADMIN_ACCESS_KEY_ID} | tr -d '"'
	aws configure set aws_secret_access_key ${ADMIN_SECRET_ACCESS_KEY} | tr -d '"'
	aws configure set default.region us-east-1
fi

echo "Creating '${S1_NAME}'..."
aws ec2 run-instances --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${S1_NAME}}]" --image-id ${S1_IMAGE_ID} --count 1 --instance-type t2.micro --key-name ${S1_KEY_NAME} --security-group-ids ${S1_SG_IDs} --subnet-id ${S1_SUBNET} --user-data "$(cat userdata.txt)" &> /dev/null

if [[ $? -eq 0 ]]
then
	echo -e "${GREEN}Created '${S1_NAME}'${NC}"
else
	echo -e "${RED}Something went wrong creating '${S1_NAME}'${NC}"
fi
