#!/bin/bash

E_NONSUDO=101

[[ $UID -eq -0 ]] || {
	echo "Permission denied!"
	echo "Exiting..."
	exit $E_NONSUDO
}

# which nginx || echo "NGINX not found" || echo "NGINX installed"

systemctl status nginx &> /dev/null && NGINX_STATUS="Active" || NGINX_STATUS="Inactive"
# echo ${NGINX_STATUS}
NGINX_VERSION=$(nginx -v 2>&1 | awk '{print $3}' | awk -F '/' '{print $2}')
# echo ${NGINX_VERSION}
AWS_VERSION=$(aws --version | awk '{print $1}' | awk -F '/' '{print $2}')
# echo ${AWS_VERSION}
NUM_EC2_RUNNING_INSTANCES=$(aws ec2 describe-instances --filters Name=instance-state-name,Values="running" | grep -o -i InstanceId | wc -l)
# echo ${NUM_EC2_RUNNING_INSTANCES}
NUM_SG=$(aws ec2 describe-security-groups | grep -o -i GroupName | wc -l)
# echo ${NUM_SG}

if [[ ${NGINX_STATUS}="Inactive" ]]
then
	systemctl enable nginx &> /dev/null
	systemctl start nginx &> /dev/null
fi

mkdir temp &> /dev/null && cd temp &> /dev/null
wget https://raw.githubusercontent.com/abdulazizfarid/cloud-task6/main/index.html &> /dev/null
sed -i "s/nginx_status/${NGINX_STATUS}/g" index.html
sed -i "s/nginx_version/${NGINX_VERSION}/g" index.html
sed -i "s/aws_version/${AWS_VERSION}/g" index.html
sed -i "s/num_ec2_instances/${NUM_EC2_RUNNING_INSTANCES}/g" index.html
sed -i "s/num_sg/${NUM_SG}/g" index.html
rm -r /var/www/html/* && mv index.html /var/www/html
echo "Website deployed!"
