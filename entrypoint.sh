#!/usr/bin/env sh

syslogd

/yaskkserv2 --no-daemonize /dictionary.yaskkserv2 &
tail -f /var/log/messages
