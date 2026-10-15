# Dockerfile for GreatSQL Shell 8.4.4-4
#
# docker version 26.1.3 (not podman)
# docker buildx build --platform linux/arm64,linux/amd64 -t greatsql/greatsql_shell:8.4.4-4 . --push
#
FROM oraclelinux:8-slim
#FROM registry.cn-beijing.aliyuncs.com/greatsql/oraclelinux:8-slim
#FROM ccr.ccs.tencentyun.com/greatsql/oraclelinux:8-slim

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG TARGETARCH \
GREATSQL_VERSION="8.4.4-4"
ENV DEPS="libssh python38 python38-pyyaml python38-dateutil" \
GREATSQLSH_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-${GREATSQL_VERSION}" \
GREATSQLSH="greatsql-shell-${GREATSQL_VERSION}-glibc2.28-${TARGETARCH}" \
BASE_DIR="/usr/local"

RUN echo ; echo "0. init, enable EPEL repo" ; \
echo '[main]' > /etc/dnf/dnf.conf && \
microdnf install -y xz oracle-epel-release-el8 > /dev/null 2>&1 && \
echo ; echo "1. install ${DEPS}" ; \
microdnf install -y ${DEPS} > /dev/null 2>&1 && \
microdnf clean all > /dev/null 2>&1 && \
pip3.8 install -i https://pypi.tuna.tsinghua.edu.cn/simple --user certifi pyclamd numpy > /dev/null 2>&1 && \
echo ; echo "2. download greatsql-shell ${GREATSQLSH_DOWNLOAD_URL}/${GREATSQLSH}.tar.xz" ; \
curl -o ${BASE_DIR}/${GREATSQLSH}.tar.xz ${GREATSQLSH_DOWNLOAD_URL}/${GREATSQLSH}.tar.xz > /dev/null 2>&1 && \
tar xf ${BASE_DIR}/${GREATSQLSH}.tar.xz -C ${BASE_DIR} > /dev/null 2>&1 && \
rm -f ${BASE_DIR}/${GREATSQLSH}.tar.xz > /dev/null 2>&1 && \
ln -s ${BASE_DIR}/greatsql-shell-${GREATSQL_VERSION}-*/bin/mysqlsh ${BASE_DIR}/bin/mysqlsh

CMD ["bash"]
