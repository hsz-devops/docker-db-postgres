# v1.0.0    2016-06-20     webmaster@highskillz.com
#
FROM postgres:9.5

MAINTAINER HighSkillz <webdev@highskillz.com>

# ------------------------------------------------------------
ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update \
    && \
    apt-get install -y \
        apt-transport-https \
        lsb-release \
        ca-certificates \
        openssl \
        ssl-cert \
        less \
        pwgen \
    && \
    echo "..."

# ------------------------------------------------------------
VOLUME [ "/var/lib/postgresql/data", "/var/log/postgresql" ]
# could also export
#   /etc/postgres/_cert
#   /etc/postgres/conf.d

# ------------------------------------------------------------
ENV DOCKER_BUILDER_DIR=/opt/.docker-build
WORKDIR ${DOCKER_BUILDER_DIR}/
ADD      ./src/  ./
RUN chmod -R a+x ./*.sh

ENV POSTGRES_CERT_DIR=/etc/postgres/_cert
ENV POSTGRES_CONFD_DIR=/etc/postgres/conf.d

ENV POSTGRES_GEN_CERTS=1

ENTRYPOINT [ "./docker-entrypoint.sh" ]
CMD ["postgres"]
