#/bin/bash

. ~/.bash_profile

MAKE_JOBS=`lscpu | grep '^CPU(s)'|awk '{print $NF}'`
if [ ${MAKE_JOBS} -ge 16 ] ; then
  MAKE_JOBS=`expr ${MAKE_JOBS} - 4`
else
  MAKE_JOBS=`expr ${MAKE_JOBS} - 1`
fi

MAJOR_VERSION=8
MINOR_VERSION=0
PATCH_VERSION=32
RELEASE=25
REVISION=79f57097e3f
OPT_DIR=/opt
GLIBC=`ldd --version | head -n 1 | awk '{print $NF}'`
ARCH=`uname -p`
OS=`grep '^ID=' /etc/os-release | sed 's/.*"\(.*\)".*/\1/ig'`
GREATSQL=GreatSQL-${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}-${RELEASE}-${OS}-glibc${GLIBC}-${ARCH}
MAKELOG=/tmp/greatsql-automake.log
MYSQL_USER=mysql
DEST_DIR=${OPT_DIR}/${GREATSQL}
GREATSQL_SRC=greatsql-${MAJOR_VERSION}.${MINOR_VERSION}.${PATCH_VERSION}-${RELEASE}
GREATSQL_BUILD_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-25/deppkgs"
GREATSQL_MAKESH_DOWNLOAD_URL="https://gitee.com/GreatSQL/GreatSQL-Docker/raw/greatsql-8.0.32-25/GreatSQL-Build"
GREATSQL_SRC_DOWNLOAD_URL="https://product.greatdb.com/GreatSQL-8.0.32-25"
BOOST_SRC_DOWNLOAD_URL="https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source"
BOOST="boost_1_77_0"
PATCHELF="patchelf-0.14.5"
GREATSQL_ENV="greatsql-setenv.sh"
GREATSQL_MAKESH="greatsql-automake.sh"
if [ "`uname -p`" = "aarch64" ] ; then
 RPCGEN="rpcgen-1.3.1-4.el8.aarch64.rpm"
else
 RPCGEN="rpcgen-1.3.1-4.el8.x86_64.rpm"
fi

CMAKE_EXE_LINKER_FLAGS=""
if [ ${ARCH} = "x86_64" ] ; then
  CMAKE_EXE_LINKER_FLAGS=" -ljemalloc "
fi
