#!/bin/bash

SELINUX_MACRO=$1

if [ -z $SELINUX_MACRO ]
then
    exit 1
fi

function cleanup {
    rm -rf /tmp/expander.* /tmp/tmp
}

IFS="("
set $1
SELINUX_DOMAIN="${2::-1}"

echo -e "policy_module(expander, 1.0.0) \n" \
     "gen_require(\`\n" \
     "type $SELINUX_DOMAIN ; \n" \
     "')" > /tmp/expander.te

echo "$SELINUX_MACRO" >> /tmp/expander.te

cd /tmp
make -f /usr/share/selinux/devel/Makefile expander.pp &> /dev/null
MAKE_RESULT=$?

if [ $MAKE_RESULT -eq 2 ]
then
    cleanup
    exit 2
else
    cat /tmp/expander.pp | /usr/libexec/selinux/hll/pp > /tmp/expander.cil 2> /dev/null
    cat /tmp/expander.cil | grep -v "cil_gen_require" | sort -u
    cleanup
fi
