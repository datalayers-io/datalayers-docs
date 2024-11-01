# CentOS

本文将介绍 Datalayers 在 CentOS 系统中的安装及使用。

Datalayers 支持的 CentOS 版本为：
- CentOS 7
- CentOS 8

## 通过 rpm 包安装

:::: tabs
::: tab amd64
1. 下载安装包，<a href="https://docs.datalayers.cn/public/centos/datalayers-{@version_number@}-el7-amd64.rpm" download="datalayers-{@version_number@}-el7-amd64.rpm">点击下载</a>rpm安装包。

2. 通过如下命令安装：
``` bash
sudo yum localinstall ./datalayers-{@version_number@}-el7-amd64.rpm
```
:::


::::

## 启动/停止 Datalayers

执行以下命令，将以 systemd 方式启动（单机模式）：
``` bash
sudo systemctl start datalayers
```

可通过以下命令查看其启动状态：
``` bash
systemctl status datalayers
```

可通过以下命令停止服务：
``` bash
sudo systemctl stop datalayers
```

可通过以下命令重启服务：
``` bash
sudo systemctl restart datalayers
```

## 卸载 Datalayers
如需卸载 Datalayers，可执行以下命令：
``` bash
sudo yum remove datalayers
```


## 体验功能

安装完成后，即可使用[命令行工具](./command-line-tool.md)快速体验 Datalayers 的各项功能。
