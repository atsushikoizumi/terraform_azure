#!/bin/bash

SCRIPT_DIR=$(cd $(dirname $0); pwd)
TFSTATE_STORAGE_ACCOUNT="terraform0tfstate"
TFSTATE_CONTAINER_NAME="tfstate"
TFSTATE_FILE_NAME="test01.tfstate"

az storage blob download \
    --account-name $TFSTATE_STORAGE_ACCOUNT \
    --auth-mode login \
    --container-name $TFSTATE_CONTAINER_NAME \
    --name $TFSTATE_FILE_NAME \
    --file "${SCRIPT_DIR}/${TFSTATE_FILE_NAME}"
