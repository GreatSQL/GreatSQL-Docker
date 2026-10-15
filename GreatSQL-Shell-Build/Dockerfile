# Dockerfile for GreatSQL Shell 8.4.4-4
#
# docker version 26.1.3 (not podman)
# docker buildx build --platform linux/arm64,linux/amd64 -t greatsql/greatsql_shell_build:8.4.4-4 . --push
#
FROM oraclelinux:8-slim
#FROM registry.cn-beijing.aliyuncs.com/greatsql/oraclelinux:8-slim
#FROM ccr.ccs.tencentyun.com/greatsql/oraclelinux:8-slim

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Shell-Docker"

ARG TARGETARCH
ENV OPT_DIR=/opt \
MYSQL_UID=3306 \
MYSQL_USER=mysql \
GREATSQLSH_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.4.4-4/GreatSQL-Shell-Build" \
GREATSQLSH_ENV="greatsqlsh-setenv.sh" \
ENTRYPOINT="docker-entrypoint.sh"

RUN echo '[main]' > /etc/dnf/dnf.conf && \
microdnf install -y util-linux xz dnf dnf-plugins-core oracle-epel-release-el8 > /dev/null 2>&1 && \
microdnf clean all > /dev/null 2>&1 && \
/usr/sbin/groupadd -g ${MYSQL_UID} ${MYSQL_USER} && \
/usr/sbin/useradd -u ${MYSQL_UID} -g ${MYSQL_UID} -s /sbin/nologin ${MYSQL_USER} && \
mkdir -p ${OPT_DIR} && \
curl -o ${OPT_DIR}/${GREATSQLSH_ENV} ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${GREATSQLSH_ENV} > /dev/null 2>&1 && \
curl -o ${OPT_DIR}/${ENTRYPOINT} ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${ENTRYPOINT} > /dev/null 2>&1 && \
chmod +x ${OPT_DIR}/*sh

ENTRYPOINT ["/opt/docker-entrypoint.sh"]

CMD ["bash"]
