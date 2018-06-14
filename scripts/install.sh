#!/bin/bash

## Install Kubernetes components
echo ""
echo ""
echo "----------------------------------------------------"
echo "INSTALLING KUBERNETES MANIFESTS"
echo "----------------------------------------------------"
kubectl create -f manifests/
echo "----------------------------------------------------"
echo ""
echo "Waiting for DNS as per usual (60 seconds)..."

sleep 60

## Create the database in Postgres
echo ""
echo ""
echo "----------------------------------------------------"
echo "CONFIGURING POSTGRES DATABASE"
echo "----------------------------------------------------"
kubectl exec -it $(kubectl get po | grep postgres | cut -d " " -f 1) -- bash -c "psql -c 'CREATE DATABASE stateful_app_development;' -U postgres"
echo "----------------------------------------------------"
echo ""


## Now that the database exists let's deploy our pod
echo ""
echo ""
echo "----------------------------------------------------"
echo "SCALE THE APPLICATION"
echo "----------------------------------------------------"
kubectl scale deploy/statefulapp --replicas 1
echo "----------------------------------------------------"
echo ""

## Get DNS
aname=$(kubectl get svc -oyaml | grep hostname | cut -d ":" -f 2 | tr -d ' ')
ips=$(dig +short $aname)

echo ""
echo ""
echo "----------------------------------------------------"
echo "STATEFUL APPLICATION ADDRESSES"
echo "----------------------------------------------------"
echo "Public IP addresses"
echo "${ips}"
echo ""
echo "Load balancer A record"
echo "${aname}"
echo "----------------------------------------------------"
echo ""


echo ""
echo ""
echo "Done.."
echo ""