#!/usr/bin/env sh
mkdir -p /var/spool/rsyslog
touch /var/log/nginx/access.log
touch /var/log/nginx/error.log
mkdir -p /var/spool/rsyslog
chgrp adm /var/spool/rsyslog
chmod g+w /var/spool/rsyslog
