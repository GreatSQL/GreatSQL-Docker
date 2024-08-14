#!/bin/bash

. /opt/greatsql-setenv.sh

echo "0. touch logfile ${MAKELOG}"
touch ${MAKELOG} && \
chown ${MYSQL_USER}:${MYSQL_USER} ${MAKELOG} && \
chmod 0777 ${MAKELOG} && \
echo && \
echo "1. downloading sourcecode tarballs and extract"
cd ${OPT_DIR} && \
echo " 1.1 downloading sourcecode tarballs ..." && \
wget -c -O ${GREATSQL_ENV} ${GREATSQL_MAKESH_DOWNLOAD_URL}/${GREATSQL_ENV} && \
wget -c -O ${GREATSQL_MAKESH} ${GREATSQL_MAKESH_DOWNLOAD_URL}/${GREATSQL_MAKESH} && \
wget -c -O ${RPCGEN} ${GREATSQL_BUILD_DOWNLOAD_URL}/${RPCGEN} && \
wget -c -O ${PATCHELF}.tar.gz ${GREATSQL_BUILD_DOWNLOAD_URL}/${PATCHELF}.tar.gz && \
wget -c -O ${BOOST}.tar.gz ${BOOST_SRC_DOWNLOAD_URL}/${BOOST}.tar.gz && \
wget -c -O ${GREATSQL_SRC}.tar.xz ${GREATSQL_SRC_DOWNLOAD_URL}/${GREATSQL_SRC}.tar.xz && \
echo " 1.2 extract tarballs ..." && \
tar xf ${OPT_DIR}/${PATCHELF}*z && \
tar xf ${OPT_DIR}/${BOOST}*z && \
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
make >> ${MAKELOG} > /dev/null 2>&1 && \
make install >> ${MAKELOG} > /dev/null 2>&1 && \
echo && \
echo "3. compile GreatSQL"; \
su - ${MYSQL_USER} -s /bin/bash -c "cd /opt; /bin/sh /opt/greatsql-automake.sh" && \
echo && \
echo "4. greatsql build completed!" ; \
ls -la ${OPT_DIR} | grep GreatSQL.*glibc.* && ${OPT_DIR}/GreatSQL*glibc*/bin/mysqld --verbose --version && \
echo && \
echo "5. remove files and clean up" ;\
cd ${OPT_DIR} && rm -rf ${BOOST} ${GREATSQL_SRC} ${PATCHELF}
/bin/bash
