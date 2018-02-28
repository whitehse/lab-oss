#!/bin/bash

IAM=`whoami`

if [ "x$IAM" != "xroot" ]; then
    echo "I must run with root privileges to proceed. Exiting"
    exit 1
fi

echo "This script will reconfigure nsswitch.conf and nslcd."
echo -n "Shall I continue? (y/n): "

read LINE

if [ "x$LINE" != "xy" ]; then
    echo "I am not continuing. Exiting"
    exit 1
fi

for foo in libpam-ldapd nslcd
do
    dpkg -L $foo > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "$foo is not installed, and is required. When"
        echo "installing nslcd, select 'passwd, group, shadow, and hosts'"
        exit 1
    fi
done

service nslcd stop

cat > /etc/nslcd.conf << EOF
uid nslcd
gid nslcd

uri ldapi:///

base dc=example,dc=net

#ldap_version 3

tls_cacertfile /etc/ssl/certs/ca-certificates.crt

base ou=people,dc=example,dc=net
base ou=groups,dc=example,dc=net
base idnsName=example.net,ou=dns,dc=example,dc=net
scope one

filter hosts (objectClass=idnsRecord)
map hosts cn idnsName
map hosts ipHostNumber ARecord
EOF

echo "session required pam_mkhomedir.so umask=0022 skel=/etc/skel" >> /etc/pam.d/common-session

service nslcd start

