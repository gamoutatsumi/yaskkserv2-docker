#!/usr/bin/env sh

syslogd

/yaskkserv2 --no-daemonize --midashi-utf8 /dictionary.yaskkserv2 &
tail -f /var/log/messages
