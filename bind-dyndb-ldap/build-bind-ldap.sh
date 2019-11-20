#!/bin/bash

IAM=`whoami`

if [ "x$IAM" != "xroot" ]; then
    echo "I must run with root privileges to proceed. Exiting"
    exit 1
fi

echo "This script will reconfigure the local bind daemon."
echo -n "Shall I continue? (y/n): "

read LINE

if [ "x$LINE" != "xy" ]; then
    echo "I am not continuing. Exiting"
    exit 1
fi

for foo in bind9 bind9-dyndb-ldap
do
    dpkg -L $foo > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "$foo is not installed, and is required."
        exit 1
    fi
done

service bind9 stop

cat > /etc/bind/named.conf.local << EOF
dyndb bind9-dyndb "/usr/lib/bind/ldap.so" {
    server_id "";
    uri "ldapi:///";
    base "ou=dns,dc=example,dc=net";
    auth_method "sasl";
    sasl_mech "EXTERNAL";
};
EOF

cat > /etc/resolv.conf << EOF
search example.net
nameserver 127.0.0.1
EOF

service bind9 start
// This is the primary configuration file for the BIND DNS server named.
//
// Please read /usr/share/doc/bind9/README.Debian.gz for information on the 
// structure of BIND configuration files in Debian, *BEFORE* you customize 
// this configuration file.
//
// If you are just adding zones, please do that in /etc/bind/named.conf.local

include "/etc/bind/named.conf.options";
include "/etc/bind/named.conf.local";
include "/etc/bind/named.conf.default-zones";

