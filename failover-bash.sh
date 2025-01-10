#!/bin/bash

echo 'Checking the status of certscan app in 60 server'
temp=$(curl -s -o /dev/null -w "%{http_code}" https://portal.certscan.net/csview/)

echo "the status of certscan app in 60 server is : $temp"

echo $temp != 200

if [ $temp != 200 ]
then
	echo "Scaling up the deployment"
	kubectl scale deployment coreapp-deployment --replicas=1
else
	echo "Scaling down the deployment"
	kubectl scale deployment coreapp-deployment --replicas=0
fi


