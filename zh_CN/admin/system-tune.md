# Datalayers 系统调优指南

## 概述
Datalayers 作为高性能数据处理系统，其性能表现与底层操作系统配置密切相关。通过合理的系统参数调优，可以显著提升系统处理能力和稳定性。本文档提供针对 Datalayers 的系统级优化配置方案。

## 关闭交换分区

Linux 交换分区会给 Datalayers 带来严重的性能问题，因此需要禁用交换分区。

```shell
echo "vm.swappiness = 0">> /etc/sysctl.conf
swapoff -a && swapon -a
sysctl -p
```


## 设置系统最大打开文件数

```shell
echo "* soft nofile 65535" >>  /etc/security/limits.conf
echo "* hard nofile 65535" >>  /etc/security/limits.conf
```

## 时钟同步

时序数据在处理时，很多数据处理逻辑是与时间信息强相关，因此需确保系统时间正确。
