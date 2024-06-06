#!/bin/bash
## Install FreeNATS from Download

# Latest Stable - this is the default
DEFURL="https://www.purplepixie.org/freenats/download.php?DirectCurrent=1"

# Specific Version if env VERSION is set

# Can set manually for testing
# VERSION="1.30.13a"

if [ -z "$VERSION" ]; then
    URL=${DEFURL}
else
    URL="https://www.purplepixie.org/freenats/downloads/freenats-${VERSION}.tar.gz"
fi

WD="/tmp"

cd ${WD}
rm -Rf freenat*

echo "Downloading FreeNATS via ${URL}"

wget --content-disposition ${URL}
RES=$?
if [ $RES -ne 0 ]; then
    echo "Download failed... FATAL ERROR"
    exit 1
fi

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
