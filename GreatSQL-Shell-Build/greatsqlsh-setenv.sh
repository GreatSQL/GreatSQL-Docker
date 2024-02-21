#/bin/bash

. ~/.bash_profile

MAKE_JOBS=`lscpu | grep '^CPU(s)'|awk '{print $NF}'`
if [ ${MAKE_JOBS} -ge 16 ] ; then
  MAKE_JOBS=`expr ${MAKE_JOBS} - 4`
else
  MAKE_JOBS=`expr ${MAKE_JOBS} - 1`
fi

OPT_DIR=/opt
MYSQL_VERSTION=8.0.32
RELEASE=25
GLIBC=`ldd --version | head -n 1 | awk '{print $NF}'`
ARCH=`uname -p`
OS=`grep '^ID=' /etc/os-release | sed 's/.*"\(.*\)".*/\1/ig'`
MAKELOG=/tmp/greatsqlsh-automake.log
MYSQL_USER=mysql
GREATSQLSH=greatsql-shell-${MYSQL_VERSTION}-${RELEASE}-${OS}-glibc${GLIBC}-${ARCH}
BASE_DIR=${OPT_DIR}/${GREATSQLSH}
GREATSQL_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-25/deppkgs"
GREATSQLSH_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-25/GreatSQL-Shell-Build"
BOOST_SRC_DOWNLOAD_URL="https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source"
MYSQL_SRC_DOWNLOAD_URL="https://downloads.mysql.com/archives/get/p/23/file"
MYSQLSH_SRC_DOWNLOAD_URL="https://downloads.mysql.com/archives/get/p/43/file"
ANTLR="antlr4-4.10"
BOOST="boost_1_77_0"
MYSQL="mysql-8.0.32"
MYSQLSH="mysql-shell-8.0.32-src"
PATCHELF="patchelf-0.14.5"
PROTOBUF="protobuf-3.19.4"
GREATSQLSH_PATCH="mysqlsh-for-greatsql-8.0.32.patch"
GREATSQLSH_MAKESH="greatsqlsh-automake.sh"
GREATSQLSH_ENV="greatsqlsh-setenv.sh"
if [ "`uname -p`" = "aarch64" ] ; then
 RPCGEN="rpcgen-1.3.1-4.el8.aarch64.rpm"
else
 RPCGEN="rpcgen-1.3.1-4.el8.x86_64.rpm"
fi
