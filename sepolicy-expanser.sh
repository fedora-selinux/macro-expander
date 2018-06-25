#!/bin/bash

SELINUX_MACRO=$1

if [ -z $SELINUX_MACRO ]
then
    exit 1
fi

function cleanup {
    rm -rf /tmp/expanser.* /tmp/tmp
}

IFS="("
set $1
SELINUX_DOMAIN="${2::-1}"

echo -e "policy_module(expanser, 1.0.0) \n" \
     "gen_require(\`\n" \
     "type $SELINUX_DOMAIN ; \n" \
     "')" > /tmp/expanser.te

echo "$SELINUX_MACRO" >> /tmp/expanser.te

cd /tmp
make -f /usr/share/selinux/devel/Makefile expanser.pp &> /dev/null
MAKE_RESULT=$?

if [ $MAKE_RESULT -eq 2 ]
then
    cleanup
    exit 2
else
    cat /tmp/expanser.pp | /usr/libexec/selinux/hll/pp > /tmp/expanser.cil 2> /dev/null
    cat /tmp/expanser.cil | grep -v "cil_gen_require" | sort -u
    cleanup
fi
