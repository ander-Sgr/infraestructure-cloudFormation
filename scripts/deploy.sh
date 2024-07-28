#!/bin/bash

usage() {
    echo "Usage: $0 -p <PUBLIC_IP> -k <KEYNAME> -b <S3_BUCKET_PREFIX>"
    exit 1
}

# Parsear los argumentos
while getopts ":p:k:b:" opt; do
    case ${opt} in
        p )
            PUBLIC_IP=$OPTARG
            ;;
        k )
            KEY_NAME=$OPTARG
            ;;
        b )
            S3_BUCKET_PREFIX=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done

if [ -z "$PUBLIC_IP" ] || [ -z "$KEY_NAME" ] || [ -z "$S3_BUCKET_PREFIX" ]; then
    usage
fi

STACK_NAME="my-main-stack-anderson"
TEMPLATE_FILE="./stacks/main-stack.yaml"

echo "Deploying the stack CloudFormation..."
aws cloudformation deploy \
  --template-file "$TEMPLATE_FILE" \
  --stack-name "$STACK_NAME" \
  --parameter-overrides MyPublicIP="$MY_PUBLIC_IP" \
                        KeyName="$KEY_NAME" \
                        S3BucketPrefix="$S3_BUCKET_PREFIX" \
  
echo "Waiting to crete the stack"
aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME"

echo "Showing the outputs"
aws cloudformation describe-stacks --stack-name "$STACK_NAME" --query "Stacks[0].Outputs" --output table
