FROM centos:8

MAINTAINER greatsql.cn

ENV LANG en_US.utf8

ENV MYSQL_DATA_DIR=/data/GreatSQL
ENV MYSQL_USER=mysql
ENV MYSQL_UID_GID=3306
ENV MYSQL_EXTRACT_DIR=/usr/local
ENV TMP_DIR=/tmp
ENV MYSQL_PORT=3306
# For CentOS 8
# ENV DEPS="numactl-libs libaio readline-devel ncurses-devel openssl openssl-devel net-tools perl"
ENV DEPS="numactl-libs libaio readline-devel ncurses-devel"

# GreatSQL tarball
ENV GREATSQL_TARBALL="greatsql-803225.tar.xz"

# For CentOS 8
ENV JEMALLOC_RPM="jemalloc-5.2.1-2.el8.x86_64.rpm"
ENV GREATSQL_INIT="greatsql-init.sh"
ENV GREATSQL_TEST="greatsql-test.sql"

# Creating user mysql
RUN groupadd -g ${MYSQL_UID_GID} ${MYSQL_USER}; \
    useradd -u ${MYSQL_UID_GID} -r -g ${MYSQL_UID_GID} -s /sbin/nologin \
        -c "MySQL User" ${MYSQL_USER}

# Copying files
COPY ${GREATSQL_TARBALL} ${TMP_DIR}
COPY ${JEMALLOC_RPM} ${TMP_DIR}
COPY ${GREATSQL_TEST} ${TMP_DIR}

# Installing jemalloc & depend libs
# curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo && \
COPY CentOS-Base.repo /etc/yum.repos.d/
RUN rm -f /etc/yum.repos.d/CentOS-Linux-AppStream.repo /etc/yum.repos.d/CentOS-Linux-BaseOS.repo ; \
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
yum clean all && \
yum makecache
RUN yum install -y ${TMP_DIR}/${JEMALLOC_RPM}
RUN yum install -y ${DEPS}
RUN unlink /etc/localtime; ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# extract tarball
RUN tar xf ${TMP_DIR}/${GREATSQL_TARBALL} -C / && rm -f ${TMP_DIR}/${GREATSQL_TARBALL}
COPY my.cnf /etc/my.cnf

RUN echo "LD_PRELOAD=/usr/lib64/libjemalloc.so" >> /etc/sysconfig/mysql ; \
    echo "THP_SETTING=never" >> /etc/sysconfig/mysql

# Creating datadir
RUN mkdir -p ${MYSQL_DATA_DIR} && chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_DATA_DIR}; chmod -R ug+rwX /etc/my.cnf

RUN rm -f ${TMP_DIR}/${JEMALLOC_RPM}

COPY ${GREATSQL_INIT} /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE ${MYSQL_PORT} ${MYSQL_PORT}0 ${MYSQL_PORT}1
CMD ["mysqld"]
