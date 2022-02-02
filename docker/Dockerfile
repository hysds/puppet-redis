ARG TAG=latest
FROM hysds/base:${TAG}

# get org and branch
ARG ORG
ARG BRANCH

MAINTAINER Gerald Manipon (pymonger) "pymonger@gmail.com"
LABEL description="Redis image for HySDS"

ENV GIT_URL https://github.com/${ORG}/puppet-redis/raw/${BRANCH}/install.sh

# get release to install
ARG HYSDS_RELEASE=develop

# provision
user root
RUN set -ex \
 && dnf update -y \
 && curl -skL ${GIT_URL} > /tmp/install.sh \
 && chmod 755 /tmp/install.sh \
 && /tmp/install.sh ${ORG} ${BRANCH} \
 && rm -rf /etc/puppetlabs/code/modules/* /mnt/swapfile \
 && dnf clean all \
 && rm -f /tmp/install.sh \
 && rm -rf /var/cache dnf

VOLUME /data/redis
WORKDIR /data/redis

COPY configs/redis-docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379
CMD [ "redis-server" ]
