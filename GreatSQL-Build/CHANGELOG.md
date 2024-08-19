# 8.0.32-26 更新日志

## 2024.8.19
* 不再采用多阶段打包
* 改成只初始化编译环境，由用户自行启动编译工作
* 进一步压缩镜像尺寸

## 2024.8
* 采用多阶段打包，降低镜像大小
* 从centos改为oraclelinux
* 调整dnf clean all位置，放在后面，以清除更多cache
* 构建过程中所有日志都打印出来

## 2024.7
* 更新到GreatSQL 8.0.32-26
* 去掉龙芯判断处理逻辑

[8.0.32-26]: https://gitee.com/GreatSQL/GreatSQL-Docker/tree/greatsql-8.0.32-26/GreatSQL-Build
