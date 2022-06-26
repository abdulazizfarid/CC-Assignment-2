#!/bin/bash

E_NONSUDO=101

[[ $UID -eq -0 ]] || {
	echo "Permission denied!"
	echo "Exiting..."
	exit $E_NONSUDO
}

CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

[[ ! -z "$1" ]] && VS_CURRENCY=$1 || VS_CURRENCY=pkr

[[ ! -z "$2" ]] && PER_PAGE=$2 || PER_PAGE=10

curl -o coins.json -X 'GET' \
"https://api.coingecko.com/api/v3/coins/markets?vs_currency=${VS_CURRENCY}&order=market_cap_desc&per_page=${PER_PAGE}&page=1&sparkline=false" \
-H 'accept: application/json' &> /dev/null

grep -i error coins.json &> /dev/null
if [[ $? -ne 0 ]]
then
	printf "${CYAN}\n\tRank\tName\t\t\tSymbol\t\tCurrent Price (USD)\n${NC}"
	for (( i=0; i<$PER_PAGE; i++ ))
	do
		temp=$(jq ".[$i] | .market_cap_rank" coins.json) && printf "\t %02d" ${temp}
		temp=$(jq ".[$i] | .name" coins.json | tr -d '"') && [[ ${#temp} -gt 9 ]] && printf "\t${temp}    " || printf "\t${temp}     "
		temp=$(jq ".[$i] | .symbol" coins.json | tr -d '"') && printf "\t\t${temp}"
		temp=$(jq ".[$i] | .current_price" coins.json) && printf "\t\t${temp}\n"
	done
	printf "\n"
else
	echo -e "${RED}Error:${NC} $(awk -F '"' '{print $4}' coins.json)"
fi
