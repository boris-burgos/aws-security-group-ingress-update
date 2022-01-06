# IP Update

## Build
 
docker build -t sg-update --build-arg aws_access_key_id=KEY --build-arg aws_secret_access_key=SECRECT --build-arg aws_region=eu-west-1 .

## Run

docker run  -e RULE_DESCRIPTION=DESC -e DDNS_HOST=me.duckdns.org sg-update

