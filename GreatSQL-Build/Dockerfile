FROM oraclelinux:8-slim
#FROM registry.cn-beijing.aliyuncs.com/greatsql/oraclelinux:8-slim
#FROM ccr.ccs.tencentyun.com/greatsql/oraclelinux:8-slim

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG TARGETARCH \
OPT_DIR=/opt \
MYSQL_UID=3306 \
MYSQL_USER=mysql \
GREATSQL_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-26/GreatSQL-Build" \
GREATSQL_ENV="greatsql-setenv.sh" \
GREATSQL_BUILD_INIT="greatsql_build_init.sh"

RUN curl -OL -o /${GREATSQL_ENV} ${GREATSQL_BUILD_DOWNLOAD_URL}/${GREATSQL_ENV} && \
curl -OL -o /${GREATSQL_BUILD_INIT} ${GREATSQL_BUILD_DOWNLOAD_URL}/${GREATSQL_BUILD_INIT} && \
mv /${GREATSQL_ENV} ${OPT_DIR} && \
chmod +x /*sh ${OPT_DIR}/*sh && \
/usr/sbin/groupadd -g ${MYSQL_UID} ${MYSQL_USER} && \
/usr/sbin/useradd -u ${MYSQL_UID} -g ${MYSQL_UID} -s /sbin/nologin ${MYSQL_USER} && \
echo '[main]' > /etc/dnf/dnf.conf && \
microdnf install -y util-linux && \
microdnf clean all

ENTRYPOINT ["sh"]
