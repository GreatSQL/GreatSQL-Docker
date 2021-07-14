FROM centos:7
MAINTAINER greatsql@greatdb.com

RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

ENV MYSQL_DATA_DIR=/data/GreatSQL
ENV MYSQL_USER=mysql
ENV MYSQL_UID_GID=3306
ENV MYSQL_EXTRACT_DIR=/usr/local
ENV TMP_DIR=/tmp
ENV MYSQL_PORT=3306
ENV GREATSQL="GreatSQL-8.0.25-15-Linux.x86_64.glibc2.12"
ENV MYSQL_BASEDIR=${MYSQL_EXTRACT_DIR}/${GREATSQL}
ENV JEMALLOC_RPM="jemalloc-3.6.0-1.el7.x86_64.rpm"
ENV DEP_LIBS="numactl-libs libaio readline-devel ncurses-devel"
ENV GREATSQL_INIT="greatsql-init.sh"

#Creating user mysql
RUN groupadd -g ${MYSQL_UID_GID} ${MYSQL_USER}; \
    useradd -u ${MYSQL_UID_GID} -r -g ${MYSQL_UID_GID} -s /sbin/nologin \
        -c "MySQL User" ${MYSQL_USER}

#Copying files
COPY ${GREATSQL} ${MYSQL_EXTRACT_DIR}/${GREATSQL}
COPY ${JEMALLOC_RPM} ${TMP_DIR}

#Installing jemalloc & depend libs
RUN yum install -y ${TMP_DIR}/${JEMALLOC_RPM} ; yum install -y ${DEP_LIBS}

RUN cd ${MYSQL_BASEDIR}/support-files && \
    cp -f my.cnf /etc/my.cnf ; \
    echo "LD_PRELOAD=/usr/lib64/libjemalloc.so.1" >> /etc/sysconfig/mysql ; \
    echo "THP_SETTING=never" >> /etc/sysconfig/mysql ; \
    echo "export PATH=\$PATH:${MYSQL_BASEDIR}/bin" >> /etc/profile.d/mysql.sh ; \
    source /etc/profile.d/mysql.sh
RUN PATH="\$PATH:${MYSQL_BASEDIR}/bin"
RUN export PATH

#Creating datadir
RUN mkdir -p ${MYSQL_DATA_DIR} && chown -R ${MYSQL_USER}:${MYSQL_USER} ${MYSQL_BASEDIR} ; \
    chmod -R ug+rwX ${MYSQL_BASEDIR} ; \
    chmod -R ug+rwX /etc/my.cnf

RUN rm -f ${TMP_DIR}/${JEMALLOC_RPM}

COPY ${GREATSQL_INIT} /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE ${MYSQL_PORT} ${MYSQL_PORT}0 ${MYSQL_PORT}1
CMD ["mysqld"]
