#!/usr/bin/env bash

# we need to run this at this point (instead at docker-entry)
# because we cannot write to an empty pgdata folder

set -eu
set -x

[ -f "${PGDATA}/postgresql.conf" ] || exit -11
[ -f "${PGDATA}/pg_hba.conf"     ] || exit -12
[ -f "${PGDATA}/pg_ident.conf"   ] || exit -13

[ -z "${POSTGRES_CONFD_DIR}" ] && exit -21
[ -d "${POSTGRES_CONFD_DIR}" ] || exit -22

[ -z "${POSTGRES_CERT_DIR}"  ] && exit -31
[ -d "${POSTGRES_CERT_DIR}"  ] || exit -32

[ "$(whoami)" == "root"  ] || exit -41

# ------------------------------------------------------------------
# Modify postgresql.conf
# sed -ri=~  "${PGDATA}/postgresql.conf"

# sed --in-place=~ \
#         -eri "s|^#?(ssl\s*=\s*)\S+|\1' = on ???????'|"  \
#         -eri "s|^#?(ssl_cert_file\s*=\s*)\S+|\1'on'|"  \
#     /etc/ssh/sshd_config

# #ssl_cert_file = 'server.crt'           # (change requires restart)
# #ssl_key_file = 'server.key'            # (change requires restart)

if cat "${PGDATA}/postgresql.conf" | grep -E "^[\s#]*(include_dir)\s*=\s*([| \s#]+).*$" ; then
    sed \
            --in-place=~ \
            --regexp-extended \
            --expression "s|^[\s#]*(include_dir)\s*=\s*([| \s#]+).*$|include_dir = \'${POSTGRES_CONFD_DIR}\'|" \
        "${PGDATA}/postgresql.conf"
else
    echo "include_dir = '${POSTGRES_CONFD_DIR}'" >> "${PGDATA}/postgresql.conf"
fi

# ------------------------------------------------------------------
# Modify hba.conf
POSTGRES_AUTH_DEFAULT=${POSTGRES_AUTH_DEFAULT:-md5}

if cat "${PGDATA}/pg_hba.conf" | grep -E "^\s*host(ssl|nossl)?\s+(all)\s+(all)\s+(0.0.0.0/0)\s+(trust)(.*)$" ; then
    sed \
            --in-place=~ \
            --regexp-extended \
            --expression "s|^\s*host((no)?nossl)?\s+(all)\s+(all)\s+(0.0.0.0/0)\s+(trust)(.*)$|host all all 0.0.0.0/0 ${POSTGRES_AUTH_DEFAULT}|" \
        "${PGDATA}/pg_hba.conf"
fi
