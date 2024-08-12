#FROM oraclelinux:8-slim
#FROM ccr.ccs.tencentyun.com/greatsql/oraclelinux:8-slim
FROM registry.cn-beijing.aliyuncs.com/greatsql/oraclelinux:8-slim

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ENV LANG en_US.utf8
ARG TARGETARCH \
MYSQL_DATA_DIR=/data/GreatSQL \
MYSQL_USER=mysql \
MYSQL_UID_GID=3306 \
MYSQL_EXTRACT_DIR=/usr/local \
TMP_DIR=/tmp \
MYSQL_PORT=3306 \
DEPS="libaio-devel numactl-devel xz openssl-devel openssl procps-ng util-linux" \
GREATSQL_DOCKER_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-26/GreatSQL" \
GREATSQL_INIT="greatsql-init.sh" \
GREATSQL_SHRINK="greatsql-shrink.sh" \
GREATSQL_TEST="greatsql-test.sql" \
GREATSQL_CNF="my.cnf" \
GREATSQL_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-8.0.32-26"

ENV GREATSQL_PKG="greatsql-8.0.32-26.1.el8.${TARGETARCH}.rpm-bundle.tar.xz"

CMD /bin/bash

RUN microdnf install --nodocs -y ${DEPS} && \
microdnf update -y && \
curl -o ${TMP_DIR}/${GREATSQL_SHRINK} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_SHRINK} && \
curl -o ${TMP_DIR}/${GREATSQL_TEST} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_TEST} && \
curl -o /${GREATSQL_INIT} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_INIT} && \
curl -o /etc/${GREATSQL_CNF} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_CNF} && \
/usr/sbin/groupadd -g ${MYSQL_UID_GID} ${MYSQL_USER} && \
/usr/sbin/useradd -u ${MYSQL_UID_GID} -r -g ${MYSQL_UID_GID} -s /sbin/nologin ${MYSQL_USER} && \
curl -o ${TMP_DIR}/greatsql.tar.xz ${GREATSQL_DOWNLOAD_URL}/${GREATSQL_PKG} && \
tar xf ${TMP_DIR}/greatsql.tar.xz -C ${TMP_DIR} && \
cd ${TMP_DIR} && \
rpm -ivh --nodeps greatsql-client*rpm greatsql-shared*rpm greatsql-server*rpm greatsql-icu-data-files*rpm && \
/bin/bash ${TMP_DIR}/${GREATSQL_SHRINK} && \
mkdir -p ${MYSQL_DATA_DIR} && \
chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_DATA_DIR} && \
chmod -R ug+rwX /etc/my.cnf && \
chmod +x /${GREATSQL_INIT} && \
microdnf clean all && \
rm -f ${TMP_DIR}/greatsql*xz ${TMP_DIR}/greatsql*rpm ; \
rm -fr /usr/share/doc /usr/share/man /usr/share/misc

ENTRYPOINT ["/greatsql-init.sh"]

EXPOSE ${MYSQL_PORT} ${MYSQL_PORT}0 ${MYSQL_PORT}1
CMD ["mysqld"]
