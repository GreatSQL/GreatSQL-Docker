#for x86_64
FROM centos:8

#for aarch64
#FROM docker.io/arm64v8/centos

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ENV LANG en_US.utf8
ARG MYSQL_DATA_DIR=/data/GreatSQL \
MYSQL_USER=mysql \
MYSQL_UID_GID=3306 \
MYSQL_EXTRACT_DIR=/usr/local \
TMP_DIR=/tmp \
MYSQL_PORT=3306 \
DEPS="pkg-config perl libaio-devel numactl-devel numactl-libs \
net-tools openssl openssl-devel perl-Data-Dumper perl-Digest-MD5 \
python2 perl-JSON perl-Test-Simple" \
GREATSQL_DOCKER_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-25/GreatSQL" \
GREATSQL_INIT="greatsql-init.sh" \
GREATSQL_SHRINK="greatsql-shrink.sh" \
GREATSQL_TEST="greatsql-test.sql" \
GREATSQL_CNF="my.cnf" \
GREATSQL_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-8.0.32-25-Rapid" \
GREATSQL_PKG="greatsql-8.0.32-25.1.el8.x86_64.rpm-bundle.tar.xz"

#for aarch64
#GREATSQL_PKG="greatsql-8.0.32-25.1.el8.aarch64.rpm-bundle.tar.xz"

CMD /bin/bash

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
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf -y update > /dev/null 2>&1 && \
dnf clean all > /dev/null 2>&1 && \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf install -y ${DEPS} > /dev/null 2>&1 && \
curl -o ${TMP_DIR}/${GREATSQL_SHRINK} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_SHRINK} > /dev/null 2>&1 && \
curl -o ${TMP_DIR}/${GREATSQL_TEST} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_TEST} > /dev/null 2>&1 && \
curl -o /${GREATSQL_INIT} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_INIT} > /dev/null 2>&1 && \
curl -o /etc/${GREATSQL_CNF} ${GREATSQL_DOCKER_DOWNLOAD_URL}/${GREATSQL_CNF} > /dev/null 2>&1 && \
/usr/sbin/groupadd -g ${MYSQL_UID_GID} ${MYSQL_USER} && \
/usr/sbin/useradd -u ${MYSQL_UID_GID} -r -g ${MYSQL_UID_GID} -s /sbin/nologin ${MYSQL_USER} && \
curl -o ${TMP_DIR}/greatsql.tar.xz ${GREATSQL_DOWNLOAD_URL}/${GREATSQL_PKG} > /dev/null 2>&1 && \
tar xf ${TMP_DIR}/greatsql.tar.xz -C ${TMP_DIR} > /dev/null 2>&1 && \
dnf install -y ${TMP_DIR}/greatsql*rpm > /dev/null 2>&1 && \
/bin/bash ${TMP_DIR}/${GREATSQL_SHRINK} > /dev/null 2>&1 && \
mkdir -p ${MYSQL_DATA_DIR} > /dev/null 2>&1 && \
chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_DATA_DIR} && \
chmod -R ug+rwX /etc/my.cnf > /dev/null 2>&1 && \
chmod +x /${GREATSQL_INIT} && \
rm -f ${TMP_DIR}/greatsql*xz ${TMP_DIR}/greatsql*rpm

ENTRYPOINT ["/greatsql-init.sh"]

EXPOSE ${MYSQL_PORT} ${MYSQL_PORT}0 ${MYSQL_PORT}1
CMD ["mysqld"]
