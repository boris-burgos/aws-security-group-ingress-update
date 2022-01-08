#!/bin/bash

# == Script Config ===================

# The rule description is used to determine the rule that should be updated.
# RULE_DESCRIPTION=rule_description_name
# SECURITY_GROUP_NAME=web
echo "UPDATING SECURITY GROUPS FOR GROUP $SECURITY_GROUP_NAME AND RULE DESCRIPTION $RULE_DESCRIPTION"
# ====================================

OLD_CIDR_IP=`aws ec2 describe-security-groups --query "SecurityGroups[?GroupName=='"$SECURITY_GROUP_NAME"'].IpPermissions[*].IpRanges[?Description=='"$RULE_DESCRIPTION"'].CidrIp | [0][0]" --output text`
# NEW_IP=`curl -s http://checkip.amazonaws.com`
NEW_IP=`dig +short $DDNS_HOST`
NEW_CIDR_IP=$NEW_IP'/32'
echo "CHECK IP CHANGE OLD: $OLD_CIDR_IP → NEW: $NEW_CIDR_IP"
# If IP has changed and the old IP could be obtained, remove the old rule
if [[ $OLD_CIDR_IP != "" ]] && [[ $OLD_CIDR_IP != $NEW_CIDR_IP ]]; then
    echo "DELETE OLD CIDR IP RECORDS FOR $OLD_CIDR_IP"
    aws ec2 revoke-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol tcp --port 80 --cidr $OLD_CIDR_IP
    aws ec2 revoke-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol tcp --port 443 --cidr $OLD_CIDR_IP
    aws ec2 revoke-security-group-ingress --group-name $SECURITY_GROUP_NAME --protocol tcp --port 22 --cidr $OLD_CIDR_IP
fi

# If the IP has changed and the new IP could be obtained, create a new rule
if [[ $NEW_IP != "" ]] && [[ $OLD_CIDR_IP != $NEW_CIDR_IP ]]; then
   echo "CREATING NEW IP RECORDS FOR $NEW_CIDR_IP"
   aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 80, "ToPort": 80, "IpRanges": [{"CidrIp": "'$NEW_CIDR_IP'", "Description": "'$RULE_DESCRIPTION'"}]}]'
   aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 443, "ToPort": 443, "IpRanges": [{"CidrIp": "'$NEW_CIDR_IP'", "Description": "'$RULE_DESCRIPTION'"}]}]'
   aws ec2 authorize-security-group-ingress --group-name $SECURITY_GROUP_NAME --ip-permissions '[{"IpProtocol": "tcp", "FromPort": 22, "ToPort": 22, "IpRanges": [{"CidrIp": "'$NEW_CIDR_IP'", "Description": "'$RULE_DESCRIPTION'"}]}]'
fi
