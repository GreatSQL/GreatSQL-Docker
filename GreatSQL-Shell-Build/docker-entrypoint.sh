#!/bin/bash
. /opt/greatsqlsh-setenv.sh

echo "0. init GreatSQL-Shell-Build env" && \
echo "0.1 touch logfile ${MAKELOG}"
touch ${MAKELOG} && \
chown ${MYSQL_USER}:${MYSQL_USER} ${MAKELOG} && \
chmod 0777 ${MAKELOG} && \
echo "0.2 install all DEPS(autoconf, gcc ...)" && \
dnf install -y ${DEPS} > /dev/null 2>&1 && \
echo 'source /opt/rh/gcc-toolset-11/enable' >> /root/.bash_profile && \
rm -f /etc/yum.repos.d/CentOS-Linux-* && \
echo "0.3 download ${YUM_REPOS}.tar.xz and ${V8_LIBS_PKG}.tar.xz" && \
mkdir -p ${OPT_DIR}/${V8_DEPS} && \
wget -c -O ${OPT_DIR}/${V8_DEPS}/${YUM_REPOS}.tar.xz ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${V8_DEPS}/${YUM_REPOS}.tar.xz >> ${MAKELOG} 2>&1 && \
wget -c -O ${OPT_DIR}/${V8_DEPS}/${V8_LIBS_PKG}.tar.xz ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${V8_DEPS}/${V8_LIBS_PKG}.tar.xz >> ${MAKELOG} 2>&1 && \
echo "0.4 install ${YUM_REPOS} and ${V8_LIBS_PKG}" && \
cd ${OPT_DIR}/${V8_DEPS} && \
tar xf ${YUM_REPOS}*z -C ${OPT_DIR}/${V8_DEPS} && \
tar xf ${V8_LIBS_PKG}*z -C ${OPT_DIR}/${V8_DEPS} && \
rpm -ivhU --nodeps ${YUM_REPOS}/centos*noarch.rpm >> ${MAKELOG} 2>&1 && \
dnf install -y epel-release >> ${MAKELOG} 2>&1 && \
dnf install -y 'dnf-command(config-manager)' >> ${MAKELOG} 2>&1 && \
dnf config-manager --enable epel-testing epel-modular epel-testing-modular >> ${MAKELOG} 2>&1 && \
rpm -Uvh ${YUM_REPOS}/epel-release*noarch.rpm >> ${MAKELOG} 2>&1 && \
dnf install -y ${V8_LIBS_PKG}/*rpm >> ${MAKELOG} 2>&1 && \
echo && \
echo "1. downloading sourcecode tarballs and extract"
cd ${OPT_DIR} && \
echo " 1.1 downloading sourcecode tarballs ..." && \
wget -c -O ${GREATSQLSH_ENV} ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${GREATSQLSH_ENV} >> ${MAKELOG} 2>&1 && \
wget -c -O ${GREATSQLSH_MAKESH} ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${GREATSQLSH_MAKESH} >> ${MAKELOG} 2>&1 && \
wget -c -O ${GREATSQLSH_PATCH} ${GREATSQLSH_BUILD_DOWNLOAD_URL}/${GREATSQLSH_PATCH} >> ${MAKELOG} 2>&1 && \
wget -c -O ${RPCGEN} ${GREATSQL_BUILD_DOWNLOAD_URL}/${RPCGEN} >> ${MAKELOG} 2>&1 && \
wget -c -O ${PATCHELF}.tar.gz ${GREATSQL_BUILD_DOWNLOAD_URL}/${PATCHELF}.tar.gz >> ${MAKELOG} 2>&1 && \
wget -c -O ${PROTOBUF}.tar.xz ${GREATSQL_BUILD_DOWNLOAD_URL}/${PROTOBUF}.tar.xz >> ${MAKELOG} 2>&1 && \
wget -c -O ${ANTLR}.tar.xz ${GREATSQL_BUILD_DOWNLOAD_URL}/${ANTLR}.tar.xz >> ${MAKELOG} 2>&1 && \
wget -c -O ${BOOST}.tar.gz ${BOOST_SRC_DOWNLOAD_URL}/${BOOST}.tar.gz >> ${MAKELOG} 2>&1 && \
wget -c -O ${MYSQLSH}.tar.gz ${MYSQLSH_SRC_DOWNLOAD_URL}/${MYSQLSH}.tar.gz >> ${MAKELOG} 2>&1 && \
wget -c -O ${MYSQL}.tar.gz ${MYSQL_SRC_DOWNLOAD_URL}/${MYSQL}.tar.gz >> ${MAKELOG} 2>&1 && \
echo " 1.2 extract tarballs ..." && \
tar xf ${OPT_DIR}/${PATCHELF}*z && \
tar xf ${OPT_DIR}/${PROTOBUF}*z && \
tar xf ${OPT_DIR}/${ANTLR}*z && \
tar xf ${OPT_DIR}/${BOOST}*z && \
tar xf ${OPT_DIR}/${MYSQL}*z && \
tar xf ${OPT_DIR}/${MYSQLSH}*z && \
chown -R ${MYSQL_USER}:${MYSQL_USER} ${OPT_DIR} && \
dnf install -y ${RPCGEN} >> ${MAKELOG} 2>&1 && \
chmod +x ${OPT_DIR}/*sh && \
echo && \
echo "2. compiling antlr4"
cd ${OPT_DIR}/${ANTLR}/runtime/Cpp/bld && \
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/antlr4 >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && make -j${MAKE_JOBS} install >> ${MAKELOG} 2>&1 && \
echo && \
echo "3. compiling patchelf"
cd ${OPT_DIR}/${PATCHELF} && \
./bootstrap.sh >> ${MAKELOG} 2>&1 && \
./configure >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} install >> ${MAKELOG} 2>&1 && \
echo && \
echo "4. compiling protobuf"
cd ${OPT_DIR}/${PROTOBUF} && \
./configure >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && \
make -j${MAKE_JOBS} install >> ${MAKELOG} 2>&1 && \
echo && \
echo "5. compiling MySQL Shell for GreatSQL"
su - ${MYSQL_USER} -s /bin/bash -c "cd ${OPT_DIR}; /bin/sh ${OPT_DIR}/${GREATSQLSH_MAKESH}" && \
echo && \
echo "6. MySQL Shell for GreatSQL 8.0.32-25 build completed!"
pip3.8 install --user certifi pyclamd >> ${MAKELOG} 2>&1 && \
echo " 6.1 MySQL Shell for GreatSQL 8.0.32-25 version:" && \
${BASE_DIR}/bin/mysqlsh --version && \
cd ${OPT_DIR} && \
tar cf ${GREATSQLSH}.tar ${GREATSQLSH} >> ${MAKELOG} 2>&1 && \
xz -9 -f -T${MAKE_JOBS} ${GREATSQLSH}.tar >> ${MAKELOG} 2>&1 && \
echo " 6.2 TARBALL file:" && \
ls -la ${OPT_DIR}/${GREATSQLSH}.tar.xz && \
cd ${OPT_DIR} && \
rm -fr ${ANTLR}* ${BOOST}* ${MYSQL}* ${MYSQLSH}* ${MYSQLSH_PATCH} ${PATCHELF}* ${PROTOBUF}* ${RPCGEN}
/bin/bash
