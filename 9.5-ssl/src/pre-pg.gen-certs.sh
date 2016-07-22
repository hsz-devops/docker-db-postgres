#!/usr/bin/env bash
set -e
set -x

if [ "${POSTGRES_GEN_CERTS}" == "1" ]; then
    POSTGRES_CERTS_OWNER="${POSTGRES_CERTS_OWNER:-postgres}"
    POSTGRES_CERTS_GROUP="${POSTGRES_CERTS_GROUP:-postgres}"

    # POSTGRES_CERT_DIR="${POSTGRES_CERT_DIR:-/etc/pgsql/_cert}"
    [ -z "${POSTGRES_CERT_DIR}"  ] && exit -2

    mkdir -p "${POSTGRES_CERT_DIR}"
    pushd    "${POSTGRES_CERT_DIR}"
    if [ ! -f ./server-cert.crt ] || [ ! -f ./server-cert.key ]; then
        # regenerate if either the key or the cert is missing

        # clean all of them
        [ -f ./server-cert.crt ] && rm ./server-cert.crt
        [ -f ./server-cert.key ] && rm ./server-cert.key
        [ -f ./server.pem ]      && rm ./server.pem

        openssl req \
            -new \
            -newkey rsa:2048 \
            -days 1461 \
            -nodes \
            -x509 \
            -subj "/C=GB/ST=None/L=Nowhere/O=e123/CN=db-postgres-${T_STAMP}" \
            -out    ./server-cert.crt \
            -keyout ./server-cert.key

        cat ./server-cert.key ./server-cert.crt > ./server.pem

        if [ "${POSTGRES_CERTS_OWNER}" == "" ] || [ "${POSTGRES_CERTS_OWNER}" == "root" ]; then
            chown -cR "root:root" "${POSTGRES_CERT_DIR}"

            chmod -cR "u=rwX,g=rX,o=rX" "${POSTGRES_CERT_DIR}"
            chmod -c  "u=rw,g=r,o="     "${POSTGRES_CERT_DIR}"/*.key  "${POSTGRES_CERT_DIR}"/*.pem
        else
            chown -cR "${POSTGRES_CERTS_OWNER}:${POSTGRES_CERTS_OWNER}" "${POSTGRES_CERT_DIR}"

            chmod -cR "u=rwX,g=rX,o=rX" "${POSTGRES_CERT_DIR}"
            chmod -c  "u=rw,g=,o="      "${POSTGRES_CERT_DIR}"/*.key  "${POSTGRES_CERT_DIR}"/*.pem
        fi
        ls -la "${POSTGRES_CERT_DIR}"
    fi
    popd
fi
