#!/bin/bash
. /opt/greatsqlsh-setenv.sh

echo " 5.1 compiling mysqlclient and mysqlxclient" && \
cd ${OPT_DIR}/${MYSQL} && \
rm -fr bld && \
mkdir bld && \
cd bld && \
cmake .. -DBOOST_INCLUDE_DIR=${OPT_DIR}/${BOOST} \
-DLOCAL_BOOST_DIR=${OPT_DIR}/${BOOST} \
-DWITH_AUTHENTICATION_KERBEROS=ON \
-DWITH_PROTOBUF=system \
-DWITH_SSL=system >> ${MAKELOG} 2>&1 && \
cmake --build . --target mysqlclient -- -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 ; \
cmake --build . --target mysqlxclient -- -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && \
echo " 5.2 compiling MySQL Shell for GreatSQL" && \
cd ${OPT_DIR}/${MYSQLSH} && \
patch -p1 -f < ${OPT_DIR}/${GREATSQLSH_PATCH} >> ${MAKELOG} 2>&1 && \
rm -fr bld && \
mkdir bld && \
cd bld && \
cmake .. \
-DCMAKE_INSTALL_PREFIX=${BASE_DIR} \
-DMYSQL_SOURCE_DIR=${OPT_DIR}/${MYSQL} \
-DMYSQL_BUILD_DIR=${OPT_DIR}/${MYSQL}/bld/ \
-DBUILD_SOURCE_PACKAGE=0 \
-DWITH_PROTOBUF=system \
-DHAVE_PYTHON=1 \
-DBUNDLED_ANTLR_DIR=/usr/local/antlr4/ >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} install >> ${MAKELOG} 2>&1 && \
cp /usr/local/lib/libprotobuf.so.30 ${BASE_DIR}/lib/mysqlsh/ &&
cp /lib64/libnode.so.93 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libbrotlienc.so.1.0.6 ${BASE_DIR}/lib/mysqlsh/libbrotlienc.so.1 && \
cp /lib64/libbrotlidec.so.1.0.6 ${BASE_DIR}/lib/mysqlsh/libbrotlidec.so.1 && \
cp /lib64/libuv.so.1.0.0 ${BASE_DIR}/lib/mysqlsh/libuv.so.1 && \
cp /lib64/libbrotlicommon.so.1.0.6 ${BASE_DIR}/lib/mysqlsh/libbrotlicommon.so.1 && \
cp /lib64/libssl.so.1.1.1k ${BASE_DIR}/lib/mysqlsh/libssl.so.1.1 && \
cp /lib64/libcrypto.so.1.1.1k ${BASE_DIR}/lib/mysqlsh/libcrypto.so.1.1 && \
cp /lib64/libcrypt.so.1.1.0 ${BASE_DIR}/lib/mysqlsh/libcrypt.so.1.1 && \
cp /lib64/libssh.so.4.8.5 ${BASE_DIR}/lib/mysqlsh/libssh.so.4 && \
cp /lib64/libpython3.8.so.1.0 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libnghttp2.so.14.19.0 ${BASE_DIR}/lib/mysqlsh/libnghttp2.so.14 && \
cp /lib64/libpcre2-8.so.0.7.1 ${BASE_DIR}/lib/mysqlsh/libpcre2-8.so.0 && \
cp /lib64/libpthread.so.0 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libdl.so.2 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libresolv.so.2 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/librt.so.1 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libutil.so.1 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libcurl.so.4 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libm.so.6 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libstdc++.so.6 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libgcc_s.so.1 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libc.so.6 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libz.so.1 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libgssapi_krb5.so.2 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libkrb5.so.3 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libk5crypto.so.3 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libcom_err.so.2 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libcrypt.so.1 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libuuid.so.1 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libkrb5support.so.0 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libkeyutils.so.1 ${BASE_DIR}/lib/mysqlsh/ && \
cp /lib64/libselinux.so.1 ${BASE_DIR}/lib/mysqlsh/
