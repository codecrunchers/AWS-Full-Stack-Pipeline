#!/bin/bash
_BUCKET_ID=$(uuidgen)
sed -i "s/_BUCKET_ID/$_BUCKET_ID/" statefile.tf
sed -i "s/_BUCKET_ID/$_BUCKET_ID/" terraform.tfvars

if [ -z "$_BUCKET_ID" ]; then
    read -p "uuigen not working, enter a UUID: " _BUCKET_ID
    echo "Using $_BUCKET_ID"
fi

export BUCKET_NAME="alan-$_BUCKET_ID"
export DYNAMO_TABLE="alan-$_BUCKET_ID-lock"
export DEV_KEY="alan-$_BUCKET_ID-key"
echo "---- CREATING STATIC AWS RESOURCES ---------"
terraform get
terraform init
echo "---- CREATING STATIC AWS RESOURCES ---------"

aws s3 mb s3://"$BUCKET_NAME" 
aws ec2 create-key-pair --key-name "$DEV_KEY" --query 'KeyMaterial' --output text > "$DEV_KEY".pem
chmod 400 "$DEV_KEY.pem"
aws dynamodb create-table \
    --table-name "$DYNAMO_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
echo "---- IMPORTING STATE ---------"
terraform import aws_s3_bucket.statefiles_for_app "$BUCKET_NAME"
terraform import aws_dynamodb_table.terraform_statelock "$DYNAMO_TABLE"
terraform plan





