#!/bin/bash

IAM=`whoami`

if [ "x$IAM" != "xroot" ]; then
    echo "I must run with root privileges to proceed. Exiting"
    exit 1
fi

echo "This script will delete the local slapd database."
echo -n "Shall I continue? (y/n): "

read LINE

if [ "x$LINE" != "xy" ]; then
    echo "I am not continuing. Exiting"
    exit 1
fi

for foo in slapd bind9-dyndb-ldap ldap-utils python-ldap
do
    dpkg -L $foo > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "$foo is not installed, and is required"
        exit 1
    fi
done

echo ""
echo "The example_admin user has full administrative access to the"
echo "dc=example,dc=net database. This user can be used by an LDAP client"
echo -n "such as Apache Studio to maintain its entries. Enter a new password: "

read EXAMPLE_ADMIN_PASSWORD

echo ""
echo "The 'provisioner' account has radius access to login to and administer"
echo -n "all network equipment. It is used by Ansible. Enter a new password: "

read PROVISIONER_PASSWORD

service slapd stop

rm -rf /etc/ldap/slapd.d/*
rm -rf /var/lib/ldap/*

sudo -u openldap -g openldap slaptest -f slapd.conf.j2 -F /etc/ldap/slapd.d/

service slapd start

ldapadd -Y external -H ldapi:/// -f dnsattributes.ldif

ldapadd -Y external -H ldapi:/// -f netiron.ldif

EXAMPLE_LDIF=`mktemp`
cp example.net.ldif $EXAMPLE_LDIF

sed -i "s/EXAMPLE_ADMIN_PASSWORD/${EXAMPLE_ADMIN_PASSWORD}/g" $EXAMPLE_LDIF
sed -i "s/PROVISIONER_PASSWORD/${PROVISIONER_PASSWORD}/g" $EXAMPLE_LDIF

#ldapadd -Y external -H ldapi:/// -f $EXAMPLE_LDIF
slapadd -n 1 -F /etc/ldap/slapd.d -l $EXAMPLE_LDIF

rm $EXAMPLE_LDIF

