#!/bin/bash

## This is the script that will decide what DB configuration to use at container startup

if [[ ! -v DB_SERVER ]]; then
    echo "DB: No external configuration provided, using internal database"
    cp /config/internal-config.inc.php /opt/freenats/server/base/config.inc.php
else
    echo "DB: External configuration provided, using external database"
    cp /config/external-config.inc.php /opt/freenats/server/base/config.inc.php

    echo "DB: DB_SERVER=${DB_SERVER}"
    echo \$fnCfg[\'db.server\'] = \"${DB_SERVER}\"\; >> /opt/freenats/server/base/config.inc.php
     if [[ -v DB_PORT ]]; then
        echo "DB: DB_PORT=${DB_PORT}"
        echo \$fnCfg[\'db.port\'] = \"${DB_PORT}\"\; >> /opt/freenats/server/base/config.inc.php
    fi
    echo "DB: DB_USERNAME=${DB_USERNAME}"
    echo \$fnCfg[\'db.username\'] = \"${DB_USERNAME}\"\; >> /opt/freenats/server/base/config.inc.php
    echo \$fnCfg[\'db.password\'] = \"${DB_PASSWORD}\"\; >> /opt/freenats/server/base/config.inc.php
    echo "DB: DB_DATABASE=${DB_DATABASE}"
    echo \$fnCfg[\'db.database\'] = \"${DB_DATABASE}\"\; >> /opt/freenats/server/base/config.inc.php
fi
