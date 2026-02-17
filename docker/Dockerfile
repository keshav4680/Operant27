FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV name="Devops Learnbay"

RUN apt-get update && \
    apt-get install -y apache2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY . /var/www/html/

EXPOSE 80

ENTRYPOINT ["apachectl", "-D", "FOREGROUND"]