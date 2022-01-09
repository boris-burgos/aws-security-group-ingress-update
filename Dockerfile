FROM python:3.6-alpine

RUN pip3 --no-cache-dir install --upgrade awscli
RUN apk add --no-cache curl
RUN apk add --no-cache bash
RUN apk add --no-cache bind-tools

# set the working directory
RUN ["mkdir", "app"]
WORKDIR "app"

RUN curl https://raw.githubusercontent.com/boris-burgos/aws-security-group-ingress-update/master/update.sh --output /app/update.sh
RUN chmod +x /app/update.sh

# copy crontabs for root user
RUN echo -en "\n*/5 * * * * /app/update.sh\n\n" >> /etc/crontabs/root

# start crond with log level 8 in foreground, output to stderr
CMD ["crond", "-f", "-d", "8"]
