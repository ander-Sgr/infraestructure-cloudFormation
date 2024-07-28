#!/bin/bash

usage() {
    echo "Usage: $0 -b BUCKET_NAME -r REGION -d TEMPLATE_DIR"
    exit 1
}

# Parsear los argumentos
while getopts ":b:r:d:" opt; do
    case ${opt} in
        b )
            BUCKET_NAME=$OPTARG
            ;;
        r )
            REGION=$OPTARG
            ;;
        d )
            TEMPLATE_DIR=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done

if [ -z "$BUCKET_NAME" ] || [ -z "$REGION" ] || [ -z "$TEMPLATE_DIR" ]; then
    usage
fi

# create the bucket
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "Creating bucket $BUCKET_NAME..."
    aws s3api create-bucket --bucket "$BUCKET_NAME"
else
    echo "Bucket $BUCKET_NAME already exisits."
fi

echo "Disabling public access block..."
aws s3api delete-public-access-block --bucket "$BUCKET_NAME"

# policy for allow access to the resources
POLICY=$(cat <<EOM
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudformation.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$BUCKET_NAME/*"
        }
    ]
}
EOM
)

echo "Appling bucket policy..."
aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy "$POLICY"

echo "Uploading templates..."
aws s3 cp "$TEMPLATE_DIR" "s3://$BUCKET_NAME/" --recursive

echo "All templates have been uploaded to $BUCKET_NAME."