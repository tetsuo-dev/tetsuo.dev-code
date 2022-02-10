#!/bin/bash
MANIFEST=akira
REG_TYPE=azure
REG_SERVER=antoonh.azurecr.io
REG_USER=antoonh
REG_REGION=us-east-1

# fetch credentials and login the appropriate registry
case ${REG_TYPE} in
  azure)
    echo "logging in the ${REG_TYPE} ${REG_SERVER}"
    az acr credential show -n antoonh -g antoonh-rg | jq -r '.passwords[0].value' | podman login --username ${REG_USER} --password-stdin ${REG_SERVER}
    ;;
  aws)
    echo "logging in the ${REG_TYPE} ${REG_SERVER}"
    aws ecr-public get-login-password --region ${REG_REGION} | podman login --username ${REG_USER} --password-stdin ${REG_SERVER}
    ;;
  *)
    echo 'specify "azure" or "aws" as the repo type'
    exit 1
    ;;
esac

# clean up the old
podman untag ${REG_SERVER}/${MANIFEST}:full-unit
podman rmi $(podman images -f reference=${MANIFEST} --format='{{.ID}}')

# build the new
podman build -t ${MANIFEST} .

# tag and push
podman tag ${MANIFEST}:latest ${REG_SERVER}/${MANIFEST}:full-unit
podman push ${REG_SERVER}/${MANIFEST}:full-unit
