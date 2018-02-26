#!/bin/bash

if [ -z "$1" ]; then
  echo "Must specific a schema file"
fi

SCHEMAFILE=$1
SCHEMANAME=`echo "$1" | sed 's/\..*//'`

TEMPDIR=`mktemp -d`
TEMPFILE=`mktemp`

cat > $TEMPFILE << EOF
include ./$SCHEMAFILE
EOF

/usr/sbin/slaptest -f $TEMPFILE -F $TEMPDIR
cat $TEMPDIR/cn=config/cn=schema/*ldif | sed "s/^dn.*/dn: cn=$SCHEMANAME,cn=schema,cn=config/" | sed '/structuralObjectClass/,$ d' | sed 's/^#.*//' | grep -v '^$'
echo ""
rm $TEMPFILE
rm -rf $TEMPDIR
