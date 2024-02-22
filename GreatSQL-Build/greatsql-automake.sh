#!/bin/bash

. /opt/greatsql-setenv.sh

echo " 3.1 compiling GreatSQL"

if [ ${ARCH} = "loongarch64" ] ; then
  cd ${OPT_DIR}/${GREATSQL_SRC}
  sed -i 's/\(.*defined.*mips.*\) \\/\1 defined(__loongarch__) || \\/ig' extra/icu/source/i18n/double-conversion-utils.h
fi

LIBLIST="libcrypto.so libssl.so libreadline.so libtinfo.so libsasl2.so libbrotlidec.so libbrotlicommon.so libgssapi_krb5.so libkrb5.so libkrb5support.so libk5crypto.so librtmp.so libgssapi.so libssl3.so libsmime3.so libnss3.so libnssutil3.so libplc4.so libnspr4.so libssl3.so libplds4.so libncurses.so libjemalloc.so"
DIRLIST="bin lib lib/private lib/plugin lib/mysqlrouter/plugin lib/mysqlrouter/private"

LIBPATH=""

function gather_libs {
    local elf_path=$1
    for lib in ${LIBLIST}; do
        for elf in $(find ${elf_path} -maxdepth 1 -exec file {} \; | grep 'ELF ' | cut -d':' -f1); do
            IFS=$'\n'
            for libfromelf in $(ldd ${elf} | grep ${lib} | awk '{print $3}'); do
                lib_realpath="$(readlink -f ${libfromelf})"
                lib_realpath_basename="$(basename $(readlink -f ${libfromelf}))"
                lib_without_version_suffix=$(echo ${lib_realpath_basename} | awk -F"." 'BEGIN { OFS = "." }{ print $1, $2}')

                # Some libraries may have dependencies on earlier openssl libraries, such as authentication_ldap_simple.so,
                # thus we need to treat them specially here, other than stripping version suffix.
                if [[ "${lib_realpath_basename}" =~ ^libcrypto.so.1.0.* ]] || [[ "${lib_realpath_basename}" =~ ^libssl.so.1.0.* ]];
                then
                  lib_without_version_suffix=$(basename ${libfromelf})
                fi


                if [ ! -f "lib/private/${lib_realpath_basename}" ] && [ ! -L "lib/private/${lib_realpath_basename}" ]; then
                
                    echo "Copying lib ${lib_realpath_basename}"
                    cp ${lib_realpath} lib/private

                    echo "Symlinking lib from ${lib_realpath_basename} to ${lib_without_version_suffix}"
                    cd lib/
                    ln -s private/${lib_realpath_basename} ${lib_without_version_suffix}
                    cd -
                    if [ ${lib_realpath_basename} != ${lib_without_version_suffix} ]; then
                        cd lib/private
                        ln -s ${lib_realpath_basename} ${lib_without_version_suffix}
                        cd -
                    fi

                    patchelf --set-soname ${lib_without_version_suffix} lib/private/${lib_realpath_basename}

                    LIBPATH+=" $(echo ${libfromelf} | grep -v $(pwd))"
                fi
            done
            unset IFS
        done
    done
}

function set_runpath {
    # Set proper runpath for bins but check before doing anything
    local elf_path=$1
    local r_path=$2
    for elf in $(find ${elf_path} -maxdepth 1 -exec file {} \; | grep 'ELF ' | cut -d':' -f1); do
        echo "Checking LD_RUNPATH for ${elf}"
        if [[ -z $(patchelf --print-rpath ${elf}) ]]; then
            echo "Changing RUNPATH for ${elf}"
            patchelf --set-rpath ${r_path} ${elf}
        fi
        if [[ ! -z "${override}" ]] && [[ "${override}" == "true" ]]; then
            echo "Overriding RUNPATH for ${elf}"
            patchelf --set-rpath ${r_path} ${elf}
        fi
    done
}

function replace_libs {
    local elf_path=$1
    for libpath_sorted in ${LIBPATH}; do
        for elf in $(find ${elf_path} -maxdepth 1 -exec file {} \; | grep 'ELF ' | cut -d':' -f1); do
            LDD=$(ldd ${elf} | grep ${libpath_sorted}|head -n1|awk '{print $1}')
            lib_realpath_basename="$(basename $(readlink -f ${libpath_sorted}))"
            lib_without_version_suffix="$(echo ${lib_realpath_basename} | awk -F"." 'BEGIN { OFS = "." }{ print $1, $2}')"
            if [[ ! -z $LDD  ]] && [[ "${minimal}" == "false" ]]; then
                echo "Replacing lib ${lib_realpath_basename} to ${lib_without_version_suffix} for ${elf}"
                patchelf --replace-needed ${LDD} ${lib_without_version_suffix} ${elf}
            fi
        done
    done
}

function check_libs {
    local elf_path=$1
    for elf in $(find ${elf_path} -maxdepth 1 -exec file {} \; | grep 'ELF ' | cut -d':' -f1); do
        if ! ldd ${elf}; then
            exit 1
        fi
    done
}

function link {
    if [ ! -d lib/private ]; then
        mkdir -p lib/private
    fi
    # Gather libs
    for DIR in ${DIRLIST}; do
        gather_libs ${DIR}
    done
    # Set proper runpath
    export override=false
    set_runpath bin '$ORIGIN/../lib/private/'
    set_runpath lib '$ORIGIN/private/'
    set_runpath lib/plugin '$ORIGIN/../private/'
    set_runpath lib/private '$ORIGIN'
    # LIBS MYSQLROUTER
    unset override && export override=true && set_runpath lib/mysqlrouter/plugin '$ORIGIN/:$ORIGIN/../private/:$ORIGIN/../../private/'
    unset override && export override=true && set_runpath lib/mysqlrouter/private '$ORIGIN/:$ORIGIN/../plugin/:$ORIGIN/../../private/'
    #  BINS MYSQLROUTER
    unset override && export override=true && set_runpath bin/mysqlrouter_passwd '$ORIGIN/../lib/mysqlrouter/private/:$ORIGIN/../lib/mysqlrouter/plugin/:$ORIGIN/../lib/private/'
    unset override && export override=true && set_runpath bin/mysqlrouter_plugin_info '$ORIGIN/../lib/mysqlrouter/private/:$ORIGIN/../lib/mysqlrouter/plugin/:$ORIGIN/../lib/private/'
    unset override && export override=true && set_runpath bin/mysqlrouter '$ORIGIN/../lib/mysqlrouter/private/:$ORIGIN/../lib/mysqlrouter/plugin/:$ORIGIN/../lib/private/'
    unset override && export override=true && set_runpath bin/mysqlrouter_keyring '$ORIGIN/../lib/mysqlrouter/private/:$ORIGIN/../lib/mysqlrouter/plugin/:$ORIGIN/../lib/private/'
    # Replace libs
    for DIR in ${DIRLIST}; do
        replace_libs ${DIR}
    done
    # Make final check in order to determine any error after linkage
    for DIR in ${DIRLIST}; do
        check_libs ${DIR}
    done
}

rm -fr ${MAKELOG}

cd ${OPT_DIR}/${GREATSQL_SRC} && \
rm -fr bld && \
mkdir bld && \
cd bld && \
cmake .. \
-DBOOST_INCLUDE_DIR=${OPT_DIR}/${BOOST} \
-DLOCAL_BOOST_DIR=${OPT_DIR}/${BOOST} \
-DCMAKE_INSTALL_PREFIX=${DEST_DIR} \
-DWITH_ZLIB=bundled \
-DWITH_NUMA=ON \
-DCMAKE_EXE_LINKER_FLAGS="${CMAKE_EXE_LINKER_FLAGS}" \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DBUILD_CONFIG=mysql_release \
-DWITH_TOKUDB=OFF \
-DWITH_ROCKSDB=OFF \
-DROCKSDB_DISABLE_AVX2=1 \
-DROCKSDB_DISABLE_MARCH_NATIVE=1 \
-DGROUP_REPLICATION_WITH_ROCKSDB=OFF \
-DALLOW_NO_SSE42=ON \
-DMYSQL_MAINTAINER_MODE=OFF \
-DFORCE_INSOURCE_BUILD=1 \
-DCOMPILATION_COMMENT="GreatSQL, Release ${RELEASE}, Revision ${REVISION}" \
-DMAJOR_VERSION=${MAJOR_VERSION} -DMINOR_VERSION=${MINOR_VERSION} -DPATCH_VERSION=${PATCH_VERSION} \
-DWITH_NDB=OFF \
-DWITH_NDBCLUSTER_STORAGE_ENGINE=OFF \
-DWITH_NDBCLUSTER=OFF \
-DWITH_UNIT_TESTS=OFF \
-DWITH_SSL=system \
-DWITH_SYSTEMD=ON \
-DWITH_AUTHENTICATION_LDAP=OFF \
-DWITH_PAM=1 \
-DWITH_LIBEVENT=bundled \
-DWITH_LDAP=system \
-DWITH_SYSTEM_LIBS=ON \
-DWITH_LZ4=bundled \
-DWITH_PROTOBUF=bundled \
-DWITH_RAPIDJSON=bundled \
-DWITH_ICU=bundled \
-DWITH_READLINE=system \
-DWITH_ZSTD=bundled \
-DWITH_FIDO=bundled \
-DWITH_KEYRING_VAULT=ON \
>> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} install >> ${MAKELOG} 2>&1

echo " 3.2 remove mysql-test from GreatSQL"
rm -fr ${DEST_DIR}/mysql-test 2 > /dev/null

echo " 3.3 make dynamic link for GreatSQL"
# strip binaries to get minimal package
# 如果想生成minial包，就取消195-204行注释
#minimal=true
#echo "minimal = ${minimal}" >> ${MAKELOG} 2>&1
#echo "link ${DEST_DIR}-minimal" >> ${MAKELOG} 2>&1
#(
#  cp -rp ${DEST_DIR} ${DEST_DIR}-minimal
#  cd ${DEST_DIR}-minimal
#  find . -type f -exec file '{}' \; | grep ': ELF ' | cut -d':' -f1 | xargs strip --strip-unneeded
#  link >> ${MAKELOG} 2>&1
#)
#如果要打包压缩，就把下面两行注释去掉
#tar -cf ${DEST_DIR}-minimal.tar ${DEST_DIR}-minimal
#xz -9 -f -T${MAKE_JOBS} ${DEST_DIR}-minimal.tar ${DEST_DIR}-minimal

minimal=false
(
  cd ${DEST_DIR}
  link >> ${MAKELOG} 2>&1
)
#如果要打包压缩，就把下面两行注释去掉
#tar -cf ${DEST_DIR}.tar ${DEST_DIR}
#xz -9 -f -T${MAKE_JOBS} ${DEST_DIR}.tar.xz ${DEST_DIR}
