#!/usr/bin/python

import sys
import json
import ldap

def getopts(argv):
    opts = {}
    while argv:
        if argv[0][0] == '-':
            opts[argv[0]] = argv[1]
        argv = argv[1:]
    return opts

d = {}
d['_meta'] = {
    'hostvars' : {
    }
}


l = ldap.initialize('ldapi:///')
sasl_auth = ldap.sasl.sasl({},'external')
l.sasl_interactive_bind_s("", sasl_auth)
res = l.search_s("dc=example,dc=net",ldap.SCOPE_SUBTREE,"(objectClass=netIronHost)",['hostname'])

for dn,entry in res:
  host = entry['hostName'][0]
  d['_meta']['hostvars'][host] = {}
  d['_meta']['hostvars'][host]['hostname'] = host

d['routers'] = {}

routers = []

for dn,entry in res:
  host = entry['hostName'][0]
  routers.append(host)

d['routers']['hosts'] = routers
  
output = json.dumps(d, indent=2)
print output
