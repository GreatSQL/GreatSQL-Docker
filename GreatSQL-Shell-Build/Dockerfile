#for x86_64
FROM centos:8

#for aarch64
#FROM docker.io/arm64v8/centos

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Shell-Docker"

ENV LANG en_US.utf8
ARG OPT_DIR=/opt \
INSTALL_PKG="automake bison boost-devel bzip2 bzip2-devel clang cmake cmake3 cyrus-sasl-devel cyrus-sasl-scram \
diffutils expat-devel file flex gcc gcc-c++ gcc-toolset-11 gcc-toolset-11-annobin-plugin-gcc git \
libaio-devel libarchive libcurl-devel libevent-devel libffi-devel libicu-devel libssh libssh-config \
libssh-devel libtirpc libtirpc-devel libtool libuuid libuuid-devel libxml2-devel libzstd libzstd-devel \
lz4-devel make ncurses-devel ncurses-libs net-tools numactl numactl-devel numactl-libs openldap-clients \
openldap-devel openssl openssl-devel pam pam-devel perl perl-Env perl-JSON perl-Memoize perl-Time-HiRes \
pkg-config psmisc python38 python38-devel python38-libs python38-pyyaml readline-devel redhat-lsb-core \
rpm rpm-build scl-utils-build tar time unzip uuid valgrind vim wget yum-utils zlib-devel" \
BUILD_PKG="greatsql_shell_docker_build.tar" \
MYSQLSH_MAKE="greatsql-shell-build.sh"

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
dnf -y update > /dev/null 2>&1 ; \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf clean all > /dev/null 2>&1 && \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf install -y ${INSTALL_PKG} > /dev/null 2>&1 ; \
echo 'source /opt/rh/gcc-toolset-11/enable' >> /root/.bash_profile

COPY ${BUILD_PKG} ${OPT_DIR}
COPY ${MYSQLSH_MAKE} /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
