#!/bin/bash

IAM=`whoami`

if [ "x$IAM" != "xroot" ]; then
    echo "I must run with root privileges to proceed. Exiting"
    exit 1
fi

echo "This script will rewrite the local FreeRadius configuration."
echo -n "Shall I continue? (y/n): "

read LINE

if [ "x$LINE" != "xy" ]; then
    echo "I am not continuing. Exiting"
    exit 1
fi

for foo in freeradius freeradius-ldap
do
    dpkg -L $foo > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "$foo is not installed, and is required"
        exit 1
    fi
done

service freeradius stop

cat > /etc/freeradius/3.0/mods-available << EOF
ldap {
    server = "ldapi://"
    base_dn = "dc=example,dc=net"
    sasl {
        mech = 'EXTERNAL'
    }
    user {
        base_dn = "ou=people,dc=example,dc=net"
        filter = "(uid=%{%{Stripped-User-Name}:-%{User-Name}})"
    }
    group {
        base_dn = "ou=groups,dc=example,dc=net"
        filter = '(objectClass=posixGroup)'
        scope = one
        membership_filter = "(|(member=%{control:Ldap-UserDn})(memberUid=%{%{Stripped-User-Name}:-%{User-Name}}))"
    }
EOF

( cd /etc/freeradius/3.0/mods-enabled/ ; ln -s ../mods-available/ldap . )
