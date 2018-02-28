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

### Work in Progress

cat > /etc/freeradius/3.0/mods-available/ldap << EOF
ldap {
    server = "ldapi://"
    base_dn = "dc=example,dc=net"
    sasl {
        mech = 'EXTERNAL'
    }
    user {
        base_dn = "ou=people,dc=example,dc=net"
        filter = "(uid=%{%{Stripped-User-Name}:-%{User-Name}})"
        scope = one
    }
    group {
        base_dn = "ou=groups,dc=example,dc=net"
        filter = '(objectClass=posixGroup)'
        scope = one
        membership_filter = "(memberUid=%{%{Stripped-User-Name}:-%{User-Name}})"
    }
}
EOF

( cd /etc/freeradius/3.0/mods-enabled/ ; ln -sf ../mods-available/ldap . )

cat > /etc/freeradius/3.0/sites-available/default << EOF
server default {

listen {
        type = auth
        ipaddr = *
        port = 0
        limit {
              max_connections = 16
              lifetime = 0
              idle_timeout = 30
        }
}

listen {
        ipaddr = *
        port = 0
        type = acct
        limit {
        }
}

authorize {
        filter_username
        preprocess
        chap
        mschap
        digest
        suffix
        eap {
                ok = return
        }
        files
        -sql
        ldap
        expiration
        logintime
        pap
}

authenticate {
        Auth-Type PAP {
                pap
        }
        Auth-Type CHAP {
                chap
        }
        Auth-Type MS-CHAP {
                mschap
        }
        Auth-Type LDAP {
            ldap
        }
        mschap
        digest
        eap
}

preacct {
        preprocess
        acct_unique
        suffix
        files
}

accounting {
        detail
        -unix
        -sql
        exec
        attr_filter.accounting_response
}

session {
}

post-auth {
        ldap

        if (Huntgroup-Name == "netiron") {
            if (!(LDAP-Group == "netiron-admins")) {
                reject
            }
            else {
                noop
            }
        }

        else {
            reject
        }

        update {
                &reply: += &session-state:
        }

        -sql
        exec
        remove_reply_message_if_eap

        Post-Auth-Type REJECT {
                -sql
                attr_filter.access_reject
                eap
                remove_reply_message_if_eap
        }

}

pre-proxy {
}

post-proxy {
        eap
}

}
EOF

cat > /etc/freeradius/3.0/users << EOF
DEFAULT Huntgroup-Name == "netiron", Auth-Type := ldap
                Brocade-Auth-Role = "0"

EOF

cat > /etc/freeradius/3.0/huntgroups << EOF
# lab-mlxe
netiron     NAS-IP-Address == 192.168.1.10
# lab-cer-top
netiron     NAS-IP-Address == 192.168.1.11
# lab-cer-bottom
netiron     NAS-IP-Address == 192.168.1.12
EOF

cat > /etc/freeradius/3.0/clients.conf << EOF
client example.net {
    ipaddr      = 192.168.1.0/24
    secret      = passw0rd 
}

EOF

service freeradius start
