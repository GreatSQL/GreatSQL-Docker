#!/bin/sh

. /opt/greatsql-setenv.sh

echo "0. GreatSQL-Build INIT" && \
microdnf install -y oracle-epel-release-el8 && \
microdnf makecache && \
microdnf install -y ${DEPS} && \
microdnf update -y && \
microdnf clean all && \
source /opt/rh/gcc-toolset-11/enable && \
echo 'source /opt/rh/gcc-toolset-11/enable' >> /root/.bash_profile; \
chmod +x /*sh ${OPT_DIR}/*sh && \
touch ${MAKELOG} && \
chown ${MYSQL_USER}:${MYSQL_USER} ${MAKELOG} && \
chmod 0777 ${MAKELOG} && \
echo && \
echo "1. downloading sourcecode tarballs and extract"
cd ${OPT_DIR} && \
echo " 1.1 downloading sourcecode tarballs ..." && \
curl -OL -o ${GREATSQL_ENV} ${GREATSQL_MAKESH_DOWNLOAD_URL}/${GREATSQL_ENV} && \
curl -OL -o ${GREATSQL_MAKESH} ${GREATSQL_MAKESH_DOWNLOAD_URL}/${GREATSQL_MAKESH} && \
curl -OL -o ${RPCGEN} ${GREATSQL_BUILD_DOWNLOAD_URL}/${RPCGEN} && \
curl -OL -o ${PATCHELF}.tar.gz ${GREATSQL_BUILD_DOWNLOAD_URL}/${PATCHELF}.tar.gz && \
curl -OL -o ${BOOST}.tar.bz2 ${BOOST_SRC_DOWNLOAD_URL}/${BOOST}.tar.bz2 && \
curl -OL -o ${GREATSQL_SRC}.tar.xz ${GREATSQL_SRC_DOWNLOAD_URL}/${GREATSQL_SRC}.tar.xz && \
echo " 1.2 extract tarballs ..." && \
tar xf ${OPT_DIR}/${PATCHELF}*z && \
tar xf ${OPT_DIR}/${BOOST}*z* && \
tar xf ${OPT_DIR}/${GREATSQL_SRC}*z && \
echo " 1.3 chown to ${MYSQL_USER}:${MYSQL_USER} for ${OPT_DIR} ..." && \
chown -R ${MYSQL_USER}:${MYSQL_USER} ${OPT_DIR} && \
echo " 1.4 install ${RPCGEN} ..." && \
rpm -ivh --nodeps ${RPCGEN} && \
chmod +x ${OPT_DIR}/*sh && \
echo && \
echo "2. compile patchelf"; \
cd ${OPT_DIR}/${PATCHELF} && ./bootstrap.sh >> ${MAKELOG} && \
./configure >> ${MAKELOG} > /dev/null 2>&1 && \
make -j${MAKE_JOBS} >> ${MAKELOG} > /dev/null 2>&1 && \
make -j${MAKE_JOBS} install >> ${MAKELOG} > /dev/null 2>&1 && \
echo && \
echo "3. compile GreatSQL"; \
su - ${MYSQL_USER} -s /bin/sh -c "cd /opt; /bin/sh /opt/greatsql-automake.sh" && \
echo && \
echo "4. greatsql build completed!" ; \
ls -la ${OPT_DIR} | grep ${GREATSQL} && ${OPT_DIR}/${GREATSQL}/bin/mysqld --verbose --version && \
cd ${OPT_DIR} && tar cf ${GREATSQL}.tar ${GREATSQL} && xz -9 -f -T ${MAKE_JOBS} ${GREATSQL}.tar && \
echo && \
echo "5. remove files and clean up" ;\
cd ${OPT_DIR} && rm -rf ${BOOST} ${GREATSQL_SRC} ${PATCHELF}
