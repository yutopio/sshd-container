#!/bin/sh

for file in /mnt/secret/ssh_host_*_key
do
    tmp="/tmp/$(basename -- $file)"
    dst="/etc/ssh/$(basename -- $file)"
    tr -d '\r' < $file > $tmp
    chmod 400 $tmp
    ln -sf $tmp $dst
done

mkdir -p /home/user/.ssh
tr -d '\r' < /mnt/config/authorized_keys > /home/user/.ssh/authorized_keys
tr -d '\r' < /mnt/config/known_hosts > /home/user/.ssh/known_hosts

rm /run/nologin

/usr/sbin/sshd -D
