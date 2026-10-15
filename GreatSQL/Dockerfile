FROM container-registry.oracle.com/os/oraclelinux:9-slim

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG TARGETARCH
ENV GREATSQL_DATA_DIR=/data/GreatSQL \
GREATSQL_USER=mysql \
GREATSQL_UID_GID=3306 \
GREATSQL_EXTRACT_DIR=/usr/local \
TMP_DIR=/tmp \
GREATSQL_PORT=3306 \
DEPS="libaio libatomic numactl-libs xz openssl openssl-libs procps-ng util-linux tzdata" \
GREATSQL_DOCKER_DOWNLOAD_URL="https://raw.giteeusercontent.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.4.4-5/GreatSQL" \
GREATSQL_INIT="greatsql-init.sh" \
GREATSQL_SHRINK="greatsql-shrink.sh" \
GREATSQL_TEST="greatsql-test.sql" \
GREATSQL_CNF="my.cnf" \
GREATSQL_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-8.4.4-5" \
GREATSQL_PKG="GreatSQL-8.4.4-5-Linux-glibc2.17-${TARGETARCH}-minimal"

# Layer 1: install base deps (only rebuilds when DEPS changes)
RUN microdnf install --nodocs -y ${DEPS} && \
    microdnf update -y && \
    microdnf clean all

# Layer 2: create the runtime user and fetch helper scripts
# (--nodocs in layer 1 already avoids doc/man packages, so no post-hoc
#  rm -fr /usr/share/misc etc. is needed here)
RUN /usr/sbin/groupadd -g ${GREATSQL_UID_GID} ${GREATSQL_USER} && \
    /usr/sbin/useradd -u ${GREATSQL_UID_GID} -r -g ${GREATSQL_UID_GID} -s /sbin/nologin ${GREATSQL_USER} && \
    curl -fL -o ${TMP_DIR}/${GREATSQL_SHRINK} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_SHRINK} && \
    curl -fL -o ${TMP_DIR}/${GREATSQL_TEST} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_TEST} && \
    curl -fL -o /${GREATSQL_INIT} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_INIT} && \
    curl -fL -o /etc/${GREATSQL_CNF} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_CNF} && \
    chmod +x /${GREATSQL_INIT} && \
    chmod -R ug+rwX /etc/${GREATSQL_CNF}

# Layer 3: download & extract GreatSQL binary, shrink it, prepare datadir
# (only rebuilds when the package version changes)
RUN curl -fL -o ${TMP_DIR}/${GREATSQL_PKG}.tar.xz ${GREATSQL_DOWNLOAD_URL}/${GREATSQL_PKG}.tar.xz && \
    tar xf ${TMP_DIR}/${GREATSQL_PKG}.tar.xz -C ${GREATSQL_EXTRACT_DIR} && \
    ln -s ${GREATSQL_EXTRACT_DIR}/GreatSQL-* ${GREATSQL_EXTRACT_DIR}/GreatSQL && \
    ln -s ${GREATSQL_EXTRACT_DIR}/GreatSQL/bin/* /usr/bin/ && \
    /bin/bash ${TMP_DIR}/${GREATSQL_SHRINK} ; \
    mkdir -p ${GREATSQL_DATA_DIR} && \
    chown -R ${GREATSQL_USER}:${GREATSQL_USER} ${GREATSQL_DATA_DIR} && \
    rm -f ${TMP_DIR}/*xz

# Layer 2b: docker-healthcheck script (mirrors official mysql image pattern).
# The mysqladmin binary is removed by the shrink script, so probe with the
# mysql client instead.  Single-quoted printf keeps ${MYSQL_ROOT_PASSWORD}
# literal in the file so it expands from the container env at runtime.
RUN printf '%s\n' \
    '#!/bin/sh' \
    '# healthcheck: report healthy only when mysqld accepts queries' \
    '# (mysqladmin is removed by the shrink script, use the mysql client)' \
    'if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then' \
    '    MYSQL_PWD="${MYSQL_ROOT_PASSWORD}" mysql -uroot -Nse "SELECT 1" >/dev/null 2>&1' \
    'else' \
    '    mysql -uroot -Nse "SELECT 1" >/dev/null 2>&1' \
    'fi' \
    > /usr/local/bin/docker-healthcheck && \
    chmod +x /usr/local/bin/docker-healthcheck

# declare data volume so data survives container recreate (like official mysql image)
VOLUME /data/GreatSQL

# HEALTHCHECK: report healthy only when mysqld actually accepts queries.
HEALTHCHECK --interval=10s --timeout=5s --start-period=60s --retries=5 \
  CMD ["/usr/local/bin/docker-healthcheck"]

ENTRYPOINT ["/greatsql-init.sh"]

EXPOSE ${GREATSQL_PORT} ${GREATSQL_PORT}0 ${GREATSQL_PORT}1
CMD ["mysqld"]
