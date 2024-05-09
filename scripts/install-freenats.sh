#!/bin/bash
## Install FreeNATS from Download

# Latest Stable
#URL="https://www.purplepixie.org/freenats/download.php?DirectCurrent=1"

# Specific Version
SPECVERSION="1.30.13a"
URL="https://www.purplepixie.org/freenats/downloads/freenats-${SPECVERSION}.tar.gz"

WD="/tmp"

cd ${WD}
rm -Rf freenat*

echo "Downloading FreeNATS via ${URL}"

wget --content-disposition ${URL}

TARBALL=$(ls freenats*.tar.gz)

echo "Downloaded ${TARBALL}"

LEN=$(expr ${#TARBALL} - 7)
VERSLEN=$(expr ${LEN} - 9)

DIRNAME=${TARBALL:0:LEN}
VERSION=${TARBALL:9:VERSLEN}

echo "FreeNATS Version ${VERSION} into directory ${DIRNAME}"

tar -xvzf ${TARBALL}

rm -Rf /opt/freenats
mv ${DIRNAME} /opt/freenats
rm -Rf /var/www/html
mv /opt/freenats/server/web /var/www/html

sed -i 's/localhost/127.0.0.1/g' /opt/freenats/server/base/config.inc.php

mv /var/www/html/firstrun.php /var/www/html/firstrun-.php
