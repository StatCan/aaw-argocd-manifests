#!/bin/bash
set -euo pipefail
cd /tmp

echo "Waiting 60 seconds..."
sleep 60

# login into az cli as pod identity
az login --identity 
az account set --subscription "vdl"

AZURE_STORAGE_KEY=$(kubectl get secret azure-blob-storage -n $NAMESPACE -o jsonpath="{.data.storageAccountKey}")

# get storage account key every 60 seconds. if just retrieved key doesnt match current key
# patch secret that holds storage account creds then restart minio-gateway deployment
while true; do
    NEW_KEY=$(az storage account keys list -g $RESOURCE_GROUP -n $AZURE_STORAGE_ACCOUNT --query [0].value -o tsv | base64 -w 0)
    if [ "$NEW_KEY" == "" ] || [ "$NEW_KEY" == "null" ]; then
        echo "Failed to get the Access Key";
        exit 1;
    fi
    if [ "$AZURE_STORAGE_KEY" != "$NEW_KEY" ]; then
        echo "Restarting the MinIO deployment with new key"
        kubectl patch secret azure-blob-storage -n $NAMESPACE -p="{\"data\":{\"storageAccountKey\": \"$NEW_KEY\"}}"
        kubectl rollout restart deployment minio-gateway
        AZURE_STORAGE_KEY=$NEW_KEY
    fi
    sleep 60
done
