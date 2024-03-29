FROM centos:8

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Shell-Docker"

ENV LANG en_US.utf8
ARG OPT_DIR=/opt \
MYSQL_UID=3306 \
MYSQL_USER=mysql \
GREATSQLSH_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-25/GreatSQL-Shell-Build" \
GREATSQLSH_ENV="greatsqlsh-setenv.sh" \
ENTRYPOINT="docker-entrypoint.sh"

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
dnf -y update > /dev/null 2>&1 ; \
rm -f /etc/yum.repos.d/CentOS-Linux-* ; \
dnf clean all > /dev/null 2>&1 && \
dnf makecache > /dev/null 2>&1 && \
/usr/sbin/groupadd -g ${MYSQL_UID} ${MYSQL_USER} && \
/usr/sbin/useradd -u ${MYSQL_UID} -g ${MYSQL_UID} -s /sbin/nologin ${MYSQL_USER} && \
mkdir -p ${OPT_DIR} && \
curl -o ${OPT_DIR}/${GREATSQLSH_ENV} ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${GREATSQLSH_ENV} > /dev/null 2>&1 && \
curl -o ${OPT_DIR}/${ENTRYPOINT} ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${ENTRYPOINT} > /dev/null 2>&1 && \
chmod +x ${OPT_DIR}/*sh

ENTRYPOINT ["/opt/docker-entrypoint.sh"]

CMD ["bash"]
