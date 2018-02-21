from netmiko import ConnectHandler

mlxe = {
    'device_type': 'brocade_netiron',
    'ip': '192.168.1.10',
    'username': 'admin',
    'password': '.....'
}

net_connect = ConnectHandler(**mlxe)

output = net_connect.send_command('show ip int')
print (output)
