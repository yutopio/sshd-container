#!/bin/sh

for file in /tmp/configs/ssh_host_*_key
do
    dst="/etc/ssh/$(basename -- $file)"
    tr -d '\r' < $file > $dst
    chmod 400 $dst
done

mkdir -p /home/user/.ssh
tr -d '\r' < /tmp/configs/authorized_keys > /home/user/.ssh/authorized_keys
tr -d '\r' < /tmp/configs/known_hosts > /home/user/.ssh/known_hosts

rm /run/nologin

/usr/sbin/sshd -D
