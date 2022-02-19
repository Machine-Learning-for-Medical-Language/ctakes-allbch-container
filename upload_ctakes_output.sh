#!/bin/bash

resourceid=`curl http://169.254.169.254/latest/meta-data/instance-id`

# May have to also set AWS key parameters here, potentially passed in as tags as well.
aws=/usr/local/bin/aws

s3_bucket=`$aws ec2 describe-tags --filters Name=key,Values=s3_bucket | jq --raw-output '.Tags[0].Value'`
s3_output_path=`$aws ec2 describe-tags --filters Name=key,Values=s3_out Name=resource-id,Values=$resourceid | jq --raw-output '.Tags[0].Value'`
keyId=$($aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:us-east-1:718952877825:secret:master-fWTVY2 --output text --query SecretString | jq --raw-output '."'$2'-kms-s3"')

find $1 -name "*.json" -exec cat {} \; >> /data/all.json
find $1 -name "*.csv" -exec cat {} \; >> /data/all.csv
$aws s3 cp /data/all.json s3://$s3_bucket/$s3_output_path/ --sse aws:kms --sse-kms-key-id $keyId
$aws s3 cp /data/all.csv s3://$s3_bucket/$s3_output_path/ --sse aws:kms --sse-kms-key-id $keyId

