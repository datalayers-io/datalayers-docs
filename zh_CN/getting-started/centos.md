# CentOS

本文将介绍 Datalayers 在 CentOS 系统中的安装及使用。

Datalayers 支持的 CentOS 版本为：
- CentOS 7
- CentOS 8

## 通过 rpm 包安装

请至<a href="https://github.com/datalayers-io/datalayers/releases" target="_blank">下载页</a>，根据你当前 CPU 架构下载对应的安装包。

:::: tabs
::: tab amd64

``` bash
sudo yum localinstall datalayers-*.x86_64.rpm
```

:::

::: tab arm64
todo
:::

::::

## 启动/停止 Datalayers


:::: tabs
::: tab systemd 方式

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
:::

::: tab 手动方式

单机模式启动
```bash
datalayers --standalone
```

集群模式启动
``` bash
datalayers -c config.toml
```
配置文件请参考[配置手册](../admin/datalayers-configuration.md)。

可通过 `Ctrl + C` 发送进程停止信号来停止服务。

:::

::::



## 卸载 Datalayers

``` bash
sudo rpm remove datalayers
```