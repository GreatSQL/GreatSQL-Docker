FROM container-registry.oracle.com/os/oraclelinux:9-slim

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG TARGETARCH
ENV LANG=en_US.utf8 \
GREATSQL_DATA_DIR=/data/GreatSQL \
GREATSQL_USER=mysql \
GREATSQL_UID_GID=3306 \
GREATSQL_EXTRACT_DIR=/usr/local \
TMP_DIR=/tmp \
GREATSQL_PORT=3306 \
DEPS="libaio-devel numactl-devel xz openssl-devel openssl procps-ng util-linux" \
GREATSQL_DOCKER_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.4.4-4/GreatSQL" \
GREATSQL_INIT="greatsql-init.sh" \
GREATSQL_SHRINK="greatsql-shrink.sh" \
GREATSQL_TEST="greatsql-test.sql" \
GREATSQL_CNF="my.cnf" \
GREATSQL_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-8.4.4-4" \
GREATSQL_PKG="GreatSQL-8.4.4-4-Linux-glibc2.17-${TARGETARCH}-minimal"

RUN microdnf install --nodocs -y ${DEPS} && \
microdnf update -y && \
curl -o ${TMP_DIR}/${GREATSQL_SHRINK} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_SHRINK} && \
curl -o ${TMP_DIR}/${GREATSQL_TEST} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_TEST} && \
curl -o /${GREATSQL_INIT} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_INIT} && \
curl -o /etc/${GREATSQL_CNF} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_CNF} && \
/usr/sbin/groupadd -g ${GREATSQL_UID_GID} ${GREATSQL_USER} && \
/usr/sbin/useradd -u ${GREATSQL_UID_GID} -r -g ${GREATSQL_UID_GID} -s /sbin/nologin ${GREATSQL_USER} && \
curl -o ${TMP_DIR}/${GREATSQL_PKG}.tar.xz ${GREATSQL_DOWNLOAD_URL}/${GREATSQL_PKG}.tar.xz && \
tar xf ${TMP_DIR}/${GREATSQL_PKG}.tar.xz -C ${GREATSQL_EXTRACT_DIR} && \
ln -s ${GREATSQL_EXTRACT_DIR}/GreatSQL-* ${GREATSQL_EXTRACT_DIR}/GreatSQL && \
ln -s ${GREATSQL_EXTRACT_DIR}/GreatSQL/bin/* /usr/bin/ && \
/bin/bash ${TMP_DIR}/${GREATSQL_SHRINK} ; \
mkdir -p ${GREATSQL_DATA_DIR} && \
chown -R ${GREATSQL_USER}:${GREATSQL_USER} ${GREATSQL_DATA_DIR} && \
chmod -R ug+rwX /etc/my.cnf && \
chmod +x /${GREATSQL_INIT} && \
microdnf clean all && \
rm -f ${TMP_DIR}/*xz && \
rm -fr /usr/share/doc /usr/share/man /usr/share/misc

ENTRYPOINT ["/greatsql-init.sh"]

EXPOSE ${GREATSQL_PORT} ${GREATSQL_PORT}0 ${GREATSQL_PORT}1
CMD ["mysqld"]
