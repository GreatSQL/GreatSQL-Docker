# Dockerfile for GreatSQL Shell 8.4.4-4
#
# docker version 26.1.3 (not podman)
# docker buildx build --platform linux/arm64,linux/amd64 -t greatsql/greatsql_shell:8.4.4-4 . --push
#
FROM centos:8

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG TARGETARCH
ENV LANG en_US.utf8 \
DEPS="libssh python38 python38-pyyaml python38-dateutil" \
GREATSQLSH_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-8.4.4-4" \
GREATSQLSH="greatsql-shell-8.4.4-4-glibc2.28-${TARGETARCH}" \
BASE_DIR="/usr/local"

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*; \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
rm -f /etc/yum.repos.d/CentOS-Stream-* ; \
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo > /dev/null 2>&1 && \
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo > /dev/null 2>&1 && \
dnf clean all > /dev/null 2>&1 && \
dnf install -y epel-release > /dev/null 2>&1 && \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf -y update > /dev/null 2>&1 && \
dnf clean all > /dev/null 2>&1 && \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf install -y ${DEPS} > /dev/null 2>&1 && \
pip3.8 install -i https://pypi.tuna.tsinghua.edu.cn/simple --user certifi pyclamd numpy > /dev/null 2>&1 && \
curl -o ${BASE_DIR}/${GREATSQLSH}.tar.xz ${GREATSQLSH_DOWNLOAD_URL}/${GREATSQLSH}.tar.xz > /dev/null 2>&1 && \
tar xf ${BASE_DIR}/${GREATSQLSH}.tar.xz -C ${BASE_DIR} > /dev/null 2>&1 && \
rm -f ${BASE_DIR}/${GREATSQLSH}.tar.xz > /dev/null 2>&1 && \
ln -s ${BASE_DIR}/${GREATSQLSH}/bin/mysqlsh ${BASE_DIR}/bin/mysqlsh

CMD ["bash"]
