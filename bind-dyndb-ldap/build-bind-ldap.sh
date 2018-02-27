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
dynamic-db "bind9-dyndb" {
    Library "ldap.so";
    arg "uri ldapi:///";
    arg "base ou=dns,dc=example,dc=net";
    arg "auth_method sasl";
    arg "sasl_mech EXTERNAL";
};
EOF

service bind9 start
