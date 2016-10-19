#!/bin/bash

set -e

# This scripts generates a password to be passed to PGSQL
[ -z "${PGDATA}" ] && exit -11

if [ -z "${POSTGRES_PASSWORD}" ]; then
    # if POSTGRES_PASSWORD is null, we may need to generate a password
    # in case PGDATA is brand new
    if [ ! -d "${PGDATA}" ] || [ ! -f "$PGDATA/PG_VERSION"  ]; then

        pwgen -s 18 1
        exit 0

        # if [ -f /.postgres_pass_modified ]; then
        #     echo "PostgreSQL 'postgres' user pass already modified!"
        #     exit 0
        # fi

        # #generate pasword
        # PASS=${POSTGRES_PASS:-$(pwgen -s 12 1)}
        # _word=$( [ ${POSTGRES_PASS} ] && echo "preset" || echo "random" )

        # echo "=> Modifying 'postgres' user with a ${_word} password in PostgreSQL"
        # sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password '$PASS';"
        # echo "=> Done!"
        # touch /.postgres_pass_modified

        # echo "========================================================================"
        # echo "You can now connect to this PostgreSQL Server using:"
        # echo ""
        # echo "    psql -h <host> -p <port> --username=postgres"
        # echo ""
        # echo "and enter the password '$PASS' when prompted"
        # echo ""
        # echo "Please remember to change the above password as soon as possible!"
        # echo "========================================================================"
    else
        echo ""
    fi
else
    echo "${POSTGRES_PASSWORD}"
fi
