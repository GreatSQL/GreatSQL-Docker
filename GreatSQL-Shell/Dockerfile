#for x86_64
FROM centos:8

#for aarch64
#FROM docker.io/arm64v8/centos

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Shell-Docker"

ENV LANG en_US.utf8
ARG DEPS="libssh python38 python38-pyyaml python38-dateutil" \
GREATSQLSH_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-8.0.32-25" \
GREATSQLSH="greatsql-shell-8.0.32-25-Linux-glibc2.28-x86_64" \
BASE_DIR=/usr/local
#for aarch64
#GREATSQLSH="greatsql-shell-8.0.32-25-Linux-glibc2.28-aarch64" \

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
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo > /dev/null 2>&1 && \
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo > /dev/null 2>&1 && \
dnf clean all > /dev/null 2>&1 && \
dnf install -y epel-release > /dev/null 2>&1 && \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf -y update > /dev/null 2>&1 && \
dnf clean all > /dev/null 2>&1 && \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf install -y ${DEPS} > /dev/null 2>&1 && \
pip3.8 install --user certifi pyclamd > /dev/null 2>&1 && \
curl -o ${BASE_DIR}/${GREATSQLSH}.tar.xz ${GREATSQLSH_DOWNLOAD_URL}/${GREATSQLSH}.tar.xz > /dev/null 2>&1 && \
tar xf ${BASE_DIR}/${GREATSQLSH}.tar.xz -C ${BASE_DIR} > /dev/null 2>&1 && \
rm -f ${BASE_DIR}/${GREATSQLSH}.tar.xz > /dev/null 2>&1 && \
ln -s ${BASE_DIR}/${GREATSQLSH}/bin/mysqlsh ${BASE_DIR}/bin/mysqlsh

CMD ["bash"]
