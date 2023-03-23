FROM centos:8

MAINTAINER greatsql@greatdb.com

ENV LANG en_US.utf8

ENV MYSQL_DATA_DIR=/data/GreatSQL
ENV MYSQL_USER=mysql
ENV MYSQL_UID_GID=3306
ENV MYSQL_EXTRACT_DIR=/usr/local
ENV TMP_DIR=/tmp
ENV MYSQL_PORT=3306
#for centos8
#ENV DEPS="numactl-libs libaio readline-devel ncurses-devel openssl openssl-devel net-tools perl"
ENV DEPS="numactl-libs libaio readline-devel ncurses-devel"
#for centos8
ENV JEMALLOC_RPM="jemalloc-5.2.1-2.el8.x86_64.rpm"
ENV GREATSQL_SHRINK="greatsql-shrink.sh"
ENV GREATSQL_INIT="greatsql-init.sh"

#Creating user mysql
RUN groupadd -g ${MYSQL_UID_GID} ${MYSQL_USER}; \
    useradd -u ${MYSQL_UID_GID} -r -g ${MYSQL_UID_GID} -s /sbin/nologin \
        -c "MySQL User" ${MYSQL_USER}

#Copying files
COPY greatsql-802516.tgz ${TMP_DIR}
# greatsql-802516.tgz 压缩包中，包含以下几个rpm文件，请自行构建（并注意区分不同平台）
# greatsql-client-8.0.25-16.1.el8.x86_64.rpm
# greatsql-devel-8.0.25-16.1.el8.x86_64.rpm
# greatsql-server-8.0.25-16.1.el8.x86_64.rpm
# greatsql-shared-8.0.25-16.1.el8.x86_64.rpm
#
COPY ${JEMALLOC_RPM} ${TMP_DIR}

#Installing jemalloc & depend libs
#curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo && \
COPY CentOS-Base.repo /etc/yum.repos.d/
RUN rm -f /etc/yum.repos.d/CentOS-Linux-AppStream.repo /etc/yum.repos.d/CentOS-Linux-BaseOS.repo ; \
sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && \
yum clean all && \
yum makecache
RUN yum install -y ${TMP_DIR}/${JEMALLOC_RPM}
RUN yum install -y ${DEPS}
RUN cd ${TMP_DIR}; tar zxvf greatsql-802516.tgz; rpm -ivh greatsql*rpm --nodeps
RUN unlink /etc/localtime; ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY my.cnf /etc/my.cnf

RUN echo "LD_PRELOAD=/usr/lib64/libjemalloc.so.2" >> /etc/sysconfig/mysql ; \
    echo "THP_SETTING=never" >> /etc/sysconfig/mysql

#Creating datadir
RUN mkdir -p ${MYSQL_DATA_DIR} && chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_DATA_DIR}; chmod -R ug+rwX /etc/my.cnf

RUN rm -f ${TMP_DIR}/${JEMALLOC_RPM} ${TMP_DIR}/greatsql-802516.tgz

COPY ${GREATSQL_SHRINK} ${TMP_DIR}
RUN /bin/sh -ex ${TMP_DIR}/${GREATSQL_SHRINK}

COPY ${GREATSQL_INIT} /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE ${MYSQL_PORT} ${MYSQL_PORT}0 ${MYSQL_PORT}1
CMD ["mysqld"]
