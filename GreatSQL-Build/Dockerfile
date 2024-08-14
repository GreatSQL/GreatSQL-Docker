#FROM oraclelinux:8-slim as builder
FROM ccr.ccs.tencentyun.com/greatsql/oraclelinux:8-slim as builder

WORKDIR /

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG TARGETARCH \
OPT_DIR=/opt \
MYSQL_UID=3306 \
MYSQL_USER=mysql \
GREATSQL_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-26/GreatSQL-Build" \
GREATSQL_ENV="greatsql-setenv.sh" \
ENTRYPOINT="docker-entrypoint.sh" \
DEPS="autoconf automake binutils bison cmake cyrus-sasl-devel cyrus-sasl-scram gcc-c++ \
gcc-toolset-11 gcc-toolset-11-annobin-plugin-gcc jemalloc jemalloc-devel krb5-devel libaio-devel \
libcurl-devel libtirpc-devel libudev-devel m4 make ncurses-devel numactl-devel openldap-devel \
openssl openssl-devel pam-devel readline-devel zlib-devel xz util-linux findutils"

RUN echo '[main]' > /etc/dnf/dnf.conf && \
microdnf install -y oracle-epel-release-el8 && \
microdnf install -y ${DEPS} && \
microdnf update -y && \
microdnf clean all && \
source /opt/rh/gcc-toolset-11/enable && \
echo 'source /opt/rh/gcc-toolset-11/enable' >> /root/.bash_profile; \
/usr/sbin/groupadd -g ${MYSQL_UID} ${MYSQL_USER} && \
/usr/sbin/useradd -u ${MYSQL_UID} -g ${MYSQL_UID} -s /sbin/nologin ${MYSQL_USER} && \
curl -o ${OPT_DIR}/${GREATSQL_ENV} ${GREATSQL_BUILD_DOWNLOAD_URL}/${GREATSQL_ENV} && \
curl -o /${ENTRYPOINT} ${GREATSQL_BUILD_DOWNLOAD_URL}/${ENTRYPOINT} && \
chmod +x /*sh ${OPT_DIR}/*sh
sh /docker-entrypoint.sh


#FROM oraclelinux:8-slim as greatsql_build
FROM ccr.ccs.tencentyun.com/greatsql/oraclelinux:8-slim as greatsql_build

LABEL maintainer="greatsql.cn" \
email="greatsql@greatdb.com" \
forum="https://greatsql.cn/forum.php" \
gitee="https://gitee.com/GreatSQL/GreatSQL-Docker"

ARG TARGETARCH \
OPT_DIR=/opt

COPY --from=builder ${OPT_DIR}/GreatSQL*.tar.xz ${OPT_DIR}

RUN echo 'GreatSQL 8.0.32-26 tarball:' && ls -lha ${OPT_DIR} 

CMD ["sh"]
