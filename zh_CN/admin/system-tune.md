# 系统调优
根据 `Datalayers` 特点，适当的调整操作系统参数能够获得更好的性能。

## 关闭交换分区

```shell
echo "vm.swappiness = 0">> /etc/sysctl.conf

swapoff -a && swapon -a

sysctl -p

free -m
```


## 设置系统最大打开文件数

```shell
echo "* soft nofile 65535" >>  /etc/security/limits.conf
echo "* hard nofile 65535" >>  /etc/security/limits.conf
```
