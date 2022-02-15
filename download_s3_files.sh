#!/bin/bash

# May have to also set AWS key parameters here, potentially passed in as tags as well.
aws=/usr/local/bin/aws

resourceid=`curl http://169.254.169.254/latest/meta-data/instance-id`
s3_bucket=`$aws ec2 describe-tags --filters Name=key,Values=s3_bucket | jq --raw-output '.Tags[0].Value'`
s3_input_path=`$aws ec2 describe-tags --filters Name=key,Values=s3_in Name=resource-id,Values=$resourceid | jq --raw-output '.Tags[0].Value'`

$aws s3 cp --recursive s3://${s3_bucket}/${s3_input_path} /data/

# Don't enter the loop if the glob doesn't find files
shopt -s nullglob

cd /data
for fn in *.csv*encrypted; do
  of=${fn%%.*}.csv
  aws-encryption-cli --decrypt --input $fn --encryption-context purpose=test --metadata-output $of.metadata --output $of --discovery true
done


