FROM centos:centos6.6
MAINTAINER David Cutting <dcutting@purplepixie.org>

# Setup the LAMP Environment and Ancilliary
RUN yum -y install bash tar wget httpd httpd-tools php php-cli php-gd php-imap php-xml php-soap php-mysql mysql-server mysql unzip cronie
RUN chkconfig httpd on
RUN chkconfig mysqld on
RUN chkconfig crond on
RUN service httpd start
RUN service mysqld start
RUN service crond start

# Setup FreeNATS
RUN mkdir /tmp/nats-install
RUN cd /tmp/nats-install; wget --trust-server-names http://www.purplepixie.org/freenats/downloads/docker/docker-nats-setup-centos66.zip; unzip docker-nats-setup-centos66.zip
RUN cd /tmp/nats-install/docker-nats-setup-centos66
# RUN chmod 755 setup.sh; ./setup.sh

# Setup FreeNATS Inside a Docker Container/Image on Build
# For: CentOS 6.6 Docker Image

# Base: /opt/freenats/server/base
# Bin:  /opt/freenats/server/bin
# Web:  /srv/www/html

# Apache Config

RUN cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
RUN cp -Rf /tmp/nats-install/docker-nats-setup-centos66/etc/httpd/conf/httpd.conf /etc/httpd/conf/

RUN service httpd stop
RUN mkdir -p /srv/www/html
RUN service httpd start

# Cron Config

RUN mkdir -p /etc/cron.minute
RUN cp /tmp/nats-install/docker-nats-setup-centos66/etc/cron.minute/freenats-tester /etc/cron.minute/freenats-tester
RUN chmod 755 /etc/cron.minute/freenats-tester
RUN mkdir -p /etc/cron.daily
RUN cp /tmp/nats-install/docker-nats-setup-centos66/etc/cron.daily/freenats-cleanup /etc/cron.daily/freenats-cleanup
RUN chmod 755 /etc/cron.daily/freenats-cleanup

RUN echo "* * * * * root run-parts /etc/cron.minute" >> /etc/crontab

RUN service crond stop
RUN service crond start

## DB + User

RUN service mysqld restart \
 && /usr/bin/mysqladmin -u root password '' \
 && mysql -u root < /tmp/nats-install/docker-nats-setup-centos66/db-setup.sql

## Configuration

# Copy Ancilliary Files
# + Run
# + Upgrade

RUN mkdir -p /root/freenats \
 && cp /tmp/nats-install/docker-nats-setup-centos66/root/freenats/upgrade /root/freenats/ \
 && chmod 755 /root/freenats/upgrade \
 && cp /tmp/nats-install/docker-nats-setup-centos66/root/freenats.sh /root/freenats/ \
 && chmod 755 /root/freenats/freenats.sh

# Download FreeNATS

RUN mkdir -p /tmp/freenats
RUN cd /tmp/freenats \
  && wget --trust-server-names http://www.purplepixie.org/freenats/download.php?DirectCurrent=docker66 -P /tmp/freenats \
  && VS=`ls /tmp/freenats/ | awk 'BEGIN { FS="-" } ; { print $2 }'` \
  && VLEN=${#VS}-7 \
  && VERS=${VS:0:${VLEN}} \
  && FILE=freenats-$VERS \
  && tar -xvzf /tmp/freenats/$FILE.tar.gz \
  && mv /tmp/freenats/$FILE /tmp/freenats/freenats-install

# Install FreeNATS

## Files

RUN mkdir -p /opt/freenats \
 && mkdir -p /opt/freenats/server \
 && mkdir -p /opt/freenats/server/base \
 && mkdir -p /opt/freenats/server/bin \
 && cp -Rf /tmp/freenats/freenats-install/server/base/* /opt/freenats/server/base/ \
 && cp -Rf /tmp/freenats/freenats-install/server/bin/* /opt/freenats/server/bin/ \
 && cp -Rf /tmp/freenats/freenats-install/server/web/* /srv/www/html/ \
 && echo "<?php" > /srv/www/html/include.php \
 && echo "\$BaseDir=\"/opt/freenats/server/base/\";" >> /srv/www/html/include.php \
 && echo "require(\$BaseDir.\"nats.php\");" >> /srv/www/html/include.php

## DB Schema

RUN service mysqld restart \
 && mysql -u root freenats < /tmp/freenats/freenats-install/server/base/sql/schema.drop.sql \
 && mysql -u root freenats < /tmp/freenats/freenats-install/server/base/sql/default.sql \
 && mv /srv/www/html/firstrun.php /srv/www/html/firstrun-.php



# Expose the web server port
EXPOSE 80

# Start the command sequence
# USER apache
CMD service mysqld restart \
 && service httpd restart \
 && service crond restart \
 && /root/freenats/freenats.sh 
