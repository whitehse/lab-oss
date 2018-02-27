#!/usr/bin/python

import sys
from netmiko import ConnectHandler

host = sys.argv[1]
user = sys.argv[2]
password = sys.argv[3]
command = sys.argv[4]

mlxe = {
    'device_type': 'brocade_netiron',
    'ip': host,
    'username': user,
    'password': password
}

net_connect = ConnectHandler(**mlxe)

output = net_connect.send_command(command)
print (output)
