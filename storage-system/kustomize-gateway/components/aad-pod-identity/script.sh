#!/bin/bash
set -euxo pipefail
cd /tmp
sleep 60

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl

# login into az cli as pod identity
az login --identity

AZURE_STORAGE_KEY=$(./kubectl get secret azure-blob-storage -n $NAMESPACE -o jsonpath="{.data.storageAccountKey}" | base64 -d)

# get storage account key every 60 seconds. if just retrieved key doesnt match current key
# patch secret that holds storage account creds then restart minio-gateway deployment
while true; do
    NEW_KEY=$(az storage account keys list -n $AZURE_STORAGE_ACCOUNT --query [0].value -o tsv)
    if [ "$NEW_KEY" == "" ] || [ "$NEW_KEY" == "null" ]; then
        echo "Failed to get the Access Key";
        exit 1;
    fi
    if [ "$AZURE_STORAGE_KEY" != "$NEW_KEY" ]; then
        ./kubectl patch secret azure-blob-storage -n $NAMESPACE -p="{\"data\":{\"storageAccountKey\": \"$NEW_KEY\"}}"
        ./kubectl rollout restart deployment minio-gateway
        AZURE_STORAGE_KEY=$NEW_KEY
    fi
    sleep 60
done
