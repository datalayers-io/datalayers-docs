# CentOS

本文将介绍 Datalayers 在 CentOS 系统中的安装及使用。

Datalayers 支持的 CentOS 版本为：
- CentOS 7
- CentOS 8

## 通过 rpm 包安装

请<a href="../assets/datalayers-0.0.3-1.el7.x86_64.rpm" download="datalayers-0.0.3-1.el7.x86_64.rpm">点击下载</a> rpm 安装包。

:::: tabs
::: tab amd64

``` bash
sudo yum localinstall datalayers-*.x86_64.rpm
```

:::

::::

## 启动/停止 Datalayers

执行以下命令，将以 systemd 方式启动（单机模式）：
``` bash
sudo systemctl start datalayers
```

启动后可通过以下命令来确认启动状态：
``` bash
sudo systemctl status datalayers
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

``` bash
sudo rpm remove datalayers
```