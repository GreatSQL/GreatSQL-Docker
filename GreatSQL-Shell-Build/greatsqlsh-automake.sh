#!/bin/bash
. /opt/greatsqlsh-setenv.sh

# --- bundled runtime library collection ---
# copy_lib resolves the real file via `readlink -f`, so exact version
# suffixes in the filename (e.g. libssl.so.1.1.1k) never have to be
# hard-coded here: after a system package upgrade the matched file name may
# change, but the stable target name below stays the same.  If a glob matches
# nothing the call is skipped with a warning instead of failing the build.
copy_lib() {
    local src_glob=$1
    local dst_name=$2
    local src
    src=$(ls ${src_glob} 2>/dev/null | head -n 1)
    if [ -z "${src}" ]; then
        echo "WARNING: no library matched '${src_glob}', skip" >&2
        return 1
    fi
    src=$(readlink -f "${src}")
    echo "Copying $(basename "${src}") -> ${dst_name}"
    cp -L "${src}" "${BASE_DIR}/lib/mysqlsh/${dst_name}"
}

echo " 5.1 compiling mysqlclient and mysqlxclient" && \
cd ${OPT_DIR}/${MYSQL} && \
patch -p1 -f < ${OPT_DIR}/${MYSQL_PATCH} >> ${MAKELOG} 2>&1 && \
rm -fr bld && \
mkdir bld && \
cd bld && \
cmake .. -DBOOST_INCLUDE_DIR=${OPT_DIR}/${BOOST} \
-DLOCAL_BOOST_DIR=${OPT_DIR}/${BOOST} \
-DWITH_AUTHENTICATION_KERBEROS=ON \
-DWITH_PROTOBUF=system \
-DWITH_SSL=system \
-DWITH_ZSTD=system \
>> ${MAKELOG} 2>&1 && \
cmake --build . --target mysqlclient -- -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && \
cmake --build . --target mysqlxclient -- -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && \
echo " 5.2 prepare jdk" && \
export GRAALJDK_ROOT=${OPT_DIR}/${JDK} && \
export JAVA_HOME=${OPT_DIR}/${GRAALVM} && \
export PATH=$PATH:${OPT_DIR}/${GRAALVM} && \
cd ${OPT_DIR}/${MYSQLSH}/ext/polyglot && \
echo " 5.3 mvn package" && \
mvn package >> ${MAKELOG} 2>&1 && \
echo " 5.4 compiling MySQL Shell for GreatSQL" && \
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
-DBUNDLED_ANTLR_DIR=/usr/local/antlr4/ \
-DHAVE_JS=ON \
-DBUNDLED_POLYGLOT_DIR=${OPT_DIR}/${MYSQLSH}/ext/polyglot/polyglot-nativeapi-native-library/target \
>> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} install >> ${MAKELOG} 2>&1 && \
copy_lib '/usr/local/lib/libprotobuf.so.30*' 'libprotobuf.so.30' ; \
copy_lib '/lib64/libbrotlienc.so.1*' 'libbrotlienc.so.1' ; \
copy_lib '/lib64/libbrotlidec.so.1*' 'libbrotlidec.so.1' ; \
copy_lib '/lib64/libuv.so.1*' 'libuv.so.1' ; \
copy_lib '/lib64/libbrotlicommon.so.1*' 'libbrotlicommon.so.1' ; \
copy_lib '/lib64/libssl.so.1.1*' 'libssl.so.1.1' ; \
copy_lib '/lib64/libcrypto.so.1.1*' 'libcrypto.so.1.1' ; \
copy_lib '/lib64/libcrypt.so.1*' 'libcrypt.so.1.1' ; \
copy_lib '/lib64/libcrypt.so.1*' 'libcrypt.so.1' ; \
copy_lib '/lib64/libssh.so.4*' 'libssh.so.4' ; \
copy_lib '/lib64/libpython3.8.so.1*' 'libpython3.8.so.1.0' ; \
copy_lib '/lib64/libpcre2-8.so.0*' 'libpcre2-8.so.0' ; \
copy_lib '/lib64/libpthread.so.0*' 'libpthread.so.0' ; \
copy_lib '/lib64/libdl.so.2*' 'libdl.so.2' ; \
copy_lib '/lib64/libresolv.so.2*' 'libresolv.so.2' ; \
copy_lib '/lib64/librt.so.1*' 'librt.so.1' ; \
copy_lib '/lib64/libutil.so.1*' 'libutil.so.1' ; \
copy_lib '/lib64/libcurl.so.4*' 'libcurl.so.4' ; \
copy_lib '/lib64/libm.so.6*' 'libm.so.6' ; \
copy_lib '/lib64/libstdc++.so.6*' 'libstdc++.so.6' ; \
copy_lib '/lib64/libgcc_s.so.1*' 'libgcc_s.so.1' ; \
copy_lib '/lib64/libc.so.6*' 'libc.so.6' ; \
copy_lib '/lib64/libz.so.1*' 'libz.so.1' ; \
copy_lib '/lib64/libgssapi_krb5.so.2*' 'libgssapi_krb5.so.2' ; \
copy_lib '/lib64/libkrb5.so.3*' 'libkrb5.so.3' ; \
copy_lib '/lib64/libk5crypto.so.3*' 'libk5crypto.so.3' ; \
copy_lib '/lib64/libcom_err.so.2*' 'libcom_err.so.2' ; \
copy_lib '/lib64/libuuid.so.1*' 'libuuid.so.1' ; \
copy_lib '/lib64/libkrb5support.so.0*' 'libkrb5support.so.0' ; \
copy_lib '/lib64/libkeyutils.so.1*' 'libkeyutils.so.1' ; \
copy_lib '/lib64/libselinux.so.1*' 'libselinux.so.1'
