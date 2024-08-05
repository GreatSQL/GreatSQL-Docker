FROM centos:8
ENV LANG en_US.utf8

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG OPT_DIR=/opt \
MYSQL_UID=3306 \
MYSQL_USER=mysql \
GREATSQL_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-26/GreatSQL-Build" \
GREATSQL_ENV="greatsql-setenv.sh" \
ENTRYPOINT="docker-entrypoint.sh" \
DEPS="autoconf automake binutils bison cmake cyrus-sasl-devel cyrus-sasl-scram gcc-c++ \
gcc-toolset-11 gcc-toolset-11-annobin-plugin-gcc jemalloc jemalloc-devel krb5-devel libaio-devel \
libcurl-devel libtirpc-devel libudev-devel m4 make ncurses-devel numactl-devel openldap-devel \
openssl openssl-devel pam-devel readline-devel wget zlib-devel"

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
curl -o ${OPT_DIR}/${GREATSQL_ENV} ${GREATSQL_BUILD_DOWNLOAD_URL}/${GREATSQL_ENV} > /dev/null 2>&1 && \
curl -o /${ENTRYPOINT} ${GREATSQL_BUILD_DOWNLOAD_URL}/${ENTRYPOINT} > /dev/null 2>&1 && \
chmod +x /*sh ${OPT_DIR}/*sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
