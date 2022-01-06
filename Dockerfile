FROM python:3.6-alpine

RUN pip3 --no-cache-dir install --upgrade awscli
RUN apk --no-cache add curl
RUN apk add --no-cache bash

# set the working directory
RUN ["mkdir", "app"]
WORKDIR "app"

# provision
ARG aws_access_key_id
ARG aws_secret_access_key
ARG aws_region
RUN aws configure set aws_access_key_id $aws_access_key_id
RUN aws configure set aws_secret_access_key $aws_secret_access_key
RUN aws configure set region $aws_region

RUN curl https://raw.githubusercontent.com/boris-burgos/aws-security-group-ingress-update/master/update.sh --output /app/update.sh
RUN chmod +x /app/update.sh

# copy crontabs for root user
RUN echo -en "\n* * * * * /app/update.sh\n\n" >> /etc/crontabs/root

# start crond with log level 8 in foreground, output to stderr
CMD ["crond", "-f", "-d", "8"]
