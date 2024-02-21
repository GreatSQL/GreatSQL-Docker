#!/bin/bash
. /opt/greatsqlsh-setenv.sh

echo " 5.1 compiling mysqlclient and mysqlxclient" && \
cd ${OPT_DIR}/${MYSQL} && \
rm -fr bld && \
mkdir bld && \
cd bld && \
cmake .. -DBOOST_INCLUDE_DIR=${OPT_DIR}/${BOOST} \
-DLOCAL_BOOST_DIR=${OPT_DIR}/${BOOST} \
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
-DHAVE_PYTHON=1 \
-DWITH_PROTOBUF=bundled \
-DBUILD_SOURCE_PACKAGE=0 \
-DBUNDLED_ANTLR_DIR=/usr/local/antlr4/ \
-DPYTHON_LIBRARIES=/usr/lib64/python3.8 -DPYTHON_INCLUDE_DIRS=/usr/include/python3.8/ >> ${MAKELOG} 2>&1 \
&& make -j${MAKE_JOBS} >> ${MAKELOG} 2>&1 && make -j${MAKE_JOBS} install >> ${MAKELOG} 2>&1 && \
cp /usr/local/lib/libprotobuf.so.30 ${BASE_DIR}/lib/mysqlsh/
