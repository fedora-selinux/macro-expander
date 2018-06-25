#!/bin/bash

SELINUX_MACRO=$1

if [ -z $SELINUX_MACRO ]
then
    exit 1
fi

function cleanup {
    rm -rf $TEMP_STORE
}

IFS="("
set $1
SELINUX_DOMAIN="${2::-1}"

TEMP_STORE="$(mktemp -d)"
cd $TEMP_STORE

echo -e "policy_module(expander, 1.0.0) \n" \
     "gen_require(\`\n" \
     "type $SELINUX_DOMAIN ; \n" \
     "')" > $TEMP_STORE/expander.te

echo "$SELINUX_MACRO" >> $TEMP_STORE/expander.te

make -f /usr/share/selinux/devel/Makefile expander.pp &> /dev/null
MAKE_RESULT=$?

if [ $MAKE_RESULT -eq 2 ]
then
    cleanup
    exit 2
else
    cat $TEMP_STORE/expander.pp | /usr/libexec/selinux/hll/pp > $TEMP_STORE/expander.cil 2> /dev/null
    cat $TEMP_STORE/expander.cil | grep -v "cil_gen_require" | sort -u
    cleanup
fi
