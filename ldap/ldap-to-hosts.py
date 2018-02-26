#!/usr/bin/python

import sys
import json
import ldap
import pprint

def getopts(argv):
    opts = {}
    while argv:
        if argv[0][0] == '-':
            opts[argv[0]] = argv[1]
        argv = argv[1:]
    return opts

d = {}
#d{'_meta'}{'hostvars'}{"moocow.example.net"}{"asdf"} = 1234
d['_meta'] = {
    'hostvars' : {
    }
}


l = ldap.initialize('ldapi:///')
sasl_auth = ldap.sasl.sasl({},'external')
l.sasl_interactive_bind_s("", sasl_auth)
res = l.search_s("dc=example,dc=net",ldap.SCOPE_SUBTREE,"(objectClass=netIronHost)",['hostname'])

#output = json.dumps(d, indent=2)
#print output

#d['_meta']['hostvars']['stuff'] = '7'

#pp = pprint.PrettyPrinter(indent=4)
#pp.pprint(res)

for dn,entry in res:
  #print dn
  host = entry['hostName'][0]
  d['_meta']['hostvars'][host] = {}
  d['_meta']['hostvars'][host]['hostname'] = host

pp = pprint.PrettyPrinter(indent=4)
pp.pprint(d)
