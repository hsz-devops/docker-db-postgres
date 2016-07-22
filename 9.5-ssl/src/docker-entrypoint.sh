#!/usr/bin/env bash

set -eu
#set -x

T_STAMP=$(date +"%Y%m%dT%H%M%S%Z")

[ -z "${DOCKER_BUILDER_DIR}" ] && exit -1
cd "${DOCKER_BUILDER_DIR}"

# ------------------------------------------------------------------
# force generation of certificates...
#
./pre-pg.gen-certs.sh

# ------------------------------------------------------------------
# generate a random password in case we have an empty one
# if this is the 1st time, it will be used;
# if not, it will be ignored...
#
NEW_PWD="$(./pre-pg.gen-root-pwd.sh)"
if [ ! -z "${NEW_PWD}" ]; then
    echo "========================================================================"
    echo "About to configure Postgres installation in [${PGDATA}] with password:"
    echo ""
    echo "   $NEW_PWD"
    echo ""
    echo "Please remember to change the above password as soon as possible!"
    echo "========================================================================"

    POSTGRES_PASSWORD="${NEW_PWD}"
    export POSTGRES_PASSWORD
fi

# ------------------------------------------------------------------
# populate /docker-entrypoint-initdb.d
#
cp ./initdb.d/* /docker-entrypoint-initdb.d

# ------------------------------------------------------------------
# populate postgres conf files
#
# POSTGRES_CONFD_DIR="${POSTGRES_CONFD_DIR:-/etc/pgsql/conf.d}"
[ -z "${POSTGRES_CONFD_DIR}"  ] && exit -3

mkdir -p "${POSTGRES_CONFD_DIR}"

# Let's make sure we have our configs always enabled, even if they are in a volume
# Also, we want to make this here and not inside initdb.d so that postgres can use some of them
# in case the POSTGRES_CONFD_DIR is set to a subfolder of PGDATA
cp ./conf.d/*.conf "${POSTGRES_CONFD_DIR}"

# ------------------------------------------------------------------
#bash -x -v /entrypoint.sh "$@"
/docker-entrypoint.sh "$@"
