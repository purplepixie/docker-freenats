FROM ubuntu:22.04

LABEL author="David Cutting"
LABEL package="FreeNATS"
LABEL url="http://www.purplepixie.org/freenats/"

# Update packages
RUN apt update 
RUN apt upgrade -y

# Install Required Software
RUN apt install -y mysql-server
RUN apt install -y apache2
RUN apt install -y cron
RUN apt install -y wget
# TZData Fix (avoids interactive prompt), UTC by default
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata
# Required PHP Libraries
RUN apt install -y libapache2-mod-php php-mysql php-imap php-xml php-gd

# FreeNATS Setup and Install
ADD scripts ./scripts
# Install FreeNATS Script
RUN chmod +x scripts/install-freenats.sh
RUN scripts/install-freenats.sh
RUN ln -s /opt/freenats/server/base /var/www/base
RUN rm /etc/apache2/mods-available/alias.conf
# MySQL Setup
RUN service mysql restart \
 && mysql < scripts/fix-root-password.sql \
 && echo "CREATE DATABASE freenats" | mysql \
 && mysql freenats < /opt/freenats/server/base/sql/schema.sql \
 && mysql freenats < /opt/freenats/server/base/sql/default.sql
# CRON Setup
RUN mkdir /etc/cron.minute
RUN echo "* * * * * root run-parts /etc/cron.minute" >> /etc/crontab
RUN cp /scripts/freenats-tester /etc/cron.minute/
RUN cp /scripts/freenats-cleanup /etc/cron.daily/
RUN chmod +x /etc/cron.minute/freenats-tester
RUN chmod +x /etc/cron.daily/freenats-cleanup

# Expose HTTP
EXPOSE 80

# Runtime
CMD service mysql restart \
 && service apache2 restart \
 && service cron restart \
 && tail -f /var/log/apache2/error.log
