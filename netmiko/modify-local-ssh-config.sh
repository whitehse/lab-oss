#!/bin/bash

echo "This script will modify the local user's client ssh config"
echo "to allow for older algorythms."
echo -n "Shall I continue? (y/n): "

read LINE

if [ "x$LINE" != "xy" ]; then
    echo "I am not continuing. Exiting"
    exit 1
fi

cat >> ~/.ssh/config << EOF
KexAlgorithms +diffie-hellman-group1-sha1
HostKeyAlgorithms +ssh-dss
EOF
