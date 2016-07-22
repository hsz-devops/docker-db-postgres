- Generate self-signed certs to /etc/postgres/_cert
- Make Postgres load configs from /etc/postgres/conf.d
- Setup some logging

We generate certs to /etc/postgres/_cert instead of ${PGDATA} to separate cert management from data management.

However, the approach taken by github.com/muccg/docker-postgres-ssl is also good.
