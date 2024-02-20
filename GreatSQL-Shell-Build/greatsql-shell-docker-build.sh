#!/bin/bash
##
## 自动构建GreatSQL Shell Docker编译环境
## 并创建一个新容器用于编译GreatSQL Shell
##

if [ ! -z "$1" ] ; then
  if [ "$1" == "aarch64" ] ; then
    sed -i 's/\(FROM centos:8\)/#\1/ig;s/#\(FROM.*arm64v8\/centos\)/\1/ig' Dockerfile
  fi
fi

echo "1. Docker images **greatsql_shell_build** build start"
docker build -t greatsql_shell_build .

echo
echo
echo

if [ $? -ne 0 ];then
  echo "Docker images **greatsql_shell_build** build error!"
else 
  echo "Docker build success!"
fi

echo
echo
echo
echo "2. Creating docker container to build GreatSQL Shell"
echo "docker run -td --hostname greatsqlsh --name greatsqlsh greatsql_shell_build"
docker run -td --hostname greatsqlsh --name greatsqlsh greatsql_shell_build bash

while [ -z "`docker logs greatsqlsh|grep 'MySQL Shell.*GreatSQL.*completed.*TARBALL is'`" ]
do
 sleep 10
 echo "GreatSQL Shell on builing ... sleep 10 sec"
done

echo
echo
echo

if [ $? -ne 0 ];then
  echo "GreatSQL Shell build error!"
else 
  echo "GreatSQL Shell build success!"
fi

echo "3. Copy GreatSQL-Shell TARBALL to the current directory"
echo
echo
TARFILE=`docker logs greatsqlsh|tail -n 1|awk '{print $NF}'|sed 's/\n//ig;s/\r//ig'`
docker cp greatsqlsh:/opt/${TARFILE} .
ls -la ${TARFILE}
