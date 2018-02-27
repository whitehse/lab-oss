#!/bin/bash

IAM=`whoami`

if [ "x$IAM" != "xroot" ]; then
    echo "I must run with root privileges to proceed. Exiting"
    exit 1
fi

#echo "This script will delete the local slapd database."
#echo -n "Shall I continue? (y/n): "
#
#read LINE
#
#if [ "x$LINE" != "xy" ]; then
#    echo "I am not continuing. Exiting"
#    exit 1
#fi

for foo in python-netmiko
do
    dpkg -L $foo > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "$foo is not installed, and is required"
        exit 1
    fi
done
