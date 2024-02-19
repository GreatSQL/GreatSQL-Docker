FROM centos:8
ENV LANG en_US.utf8

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG MYSQL_UID=3306 \
MYSQL_USER=mysql \
OPT_DIR=/opt \
BOOST_SRC_DOWNLOAD_URL="https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source" \
GREATSQL_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/master/GreatSQL-Build" \
GREATSQL_SRC_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-8.0.32-25" \
GREATSQL_MAKESH="greatsql-automake.sh" \
ENTRYPOINT="docker-entrypoint.sh" \
GREATSQL="greatsql-8.0.32-25.tar.xz" \
PATCHELF="patchelf-0.14.5" \
BOOST="boost_1_77_0.tar.gz" \
RPCGEN="rpcgen-1.3.1-4.el8.x86_64.rpm" \
DEPS="autoconf automake binutils bison cmake cyrus-sasl-devel cyrus-sasl-scram gcc-c++ \
gcc-toolset-11 gcc-toolset-11-annobin-plugin-gcc jemalloc jemalloc-devel krb5-devel libaio-devel \
libcurl-devel libtirpc-devel libudev-devel m4 make ncurses-devel numactl-devel openldap-devel \
openssl openssl-devel pam-devel readline-devel zlib-devel wget"

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
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf clean all > /dev/null 2>&1 && \
dnf makecache > /dev/null 2>&1 && \
dnf update -y > /dev/null 2>&1 && \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf install -y epel-release > /dev/null 2>&1 && \
dnf install -y ${DEPS} > /dev/null 2>&1 && \
source /opt/rh/gcc-toolset-11/enable > /dev/null 2>&1 && \
echo 'source /opt/rh/gcc-toolset-11/enable' >> /root/.bash_profile; \
/usr/sbin/groupadd -g ${MYSQL_UID} ${MYSQL_USER} && \
/usr/sbin/useradd -u ${MYSQL_UID} -g ${MYSQL_UID} -s /sbin/nologin ${MYSQL_USER} && \
dnf install -y ${GREATSQL_BUILD_DOWNLOAD_URL}/${RPCGEN} > /dev/null 2>&1 && \
curl -o ${OPT_DIR}/${GREATSQL_MAKESH} ${GREATSQL_BUILD_DOWNLOAD_URL}/${GREATSQL_MAKESH} > /dev/null 2>&1 && \
curl -o /${ENTRYPOINT} ${GREATSQL_BUILD_DOWNLOAD_URL}/${ENTRYPOINT} > /dev/null 2>&1 && \
chmod +x ${OPT_DIR}/${GREATSQL_MAKESH} /${ENTRYPOINT} > /dev/null 2>&1 && \
curl -o ${OPT_DIR}/${PATCHELF}.tar.gz ${GREATSQL_BUILD_DOWNLOAD_URL}/${PATCHELF}.tar.gz > /dev/null 2>&1 && \
tar xf ${OPT_DIR}/${PATCHELF}.tar.gz -C ${OPT_DIR} > /dev/null 2>&1 && \
wget -c -O ${OPT_DIR}/${BOOST} ${BOOST_SRC_DOWNLOAD_URL}/${BOOST} > /dev/null 2>&1 && \
tar xf ${OPT_DIR}/${BOOST} -C /opt > /dev/null 2>&1 && \
curl -o ${OPT_DIR}/${GREATSQL} ${GREATSQL_SRC_DOWNLOAD_URL}/${GREATSQL} > /dev/null 2>&1 && \
tar xf ${OPT_DIR}/${GREATSQL} -C /opt > /dev/null 2>&1 && \
chown -R ${MYSQL_USER}:${MYSQL_USER} ${OPT_DIR} > /dev/null 2>&1 && \
chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
