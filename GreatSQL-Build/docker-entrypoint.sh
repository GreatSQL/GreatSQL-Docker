#!/bin/bash
OPT_DIR=/opt
GREATSQL_MAKESH="greatsql-automake.sh"
PATCHELF="patchelf-0.14.5"
MAKELOG=/tmp/patchelf-automake.log

echo "1. compile patchelf"; \
cd ${OPT_DIR}/${PATCHELF} && ./bootstrap.sh >> ${MAKELOG} > /dev/null 2>&1 && \
./configure >> ${MAKELOG} > /dev/null 2>&1 && \
make >> ${MAKELOG} > /dev/null 2>&1 && \
make install >> ${MAKELOG} > /dev/null 2>&1 && \
echo "2. entering greatsql automake" ; \
su - mysql -s /bin/bash -c "cd /opt; /bin/sh /opt/greatsql-automake.sh" && \
echo "3. greatsql automake completed" ; \
ls -la ${OPT_DIR} | grep GreatSQL.*glibc.* && ${OPT_DIR}/GreatSQL*glibc*/bin/mysqld --verbose --version && \
echo "4. remove files and clean up" ;\
cd ${OPT_DIR} && rm -rf boost_1_77_0 greatsql-8.0.32-25 patchelf-0.14.5
/bin/bash
