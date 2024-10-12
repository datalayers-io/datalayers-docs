# Ubuntu

本文将介绍 Datalayers 在 Ubuntu 系统中的安装及使用。

Datalayers 支持的 Ubuntu 版本为：
- Ubuntu 22.04

## 通过 deb 包安装


:::: tabs
::: tab amd64
1. 下载安装包, <a href="https://docs.datalayers.cn/public/ubuntu/datalayers-{@version_number@}-ubuntu22.04-amd64.deb" download="datalayers-{@version_number@}-ubuntu22.04-amd64.deb">点击下载</a>deb安装包。

2. 通过如下命令安装：

``` bash
sudo dpkg -i ./datalayers-{@version_number@}-ubuntu22.04-amd64.deb
```
:::

::: tab arm64
1. 下载安装包, <a href="https://docs.datalayers.cn/public/ubuntu/datalayers-{@version_number@}-ubuntu22.04-arm64.deb" download="datalayers-{@version_number@}-ubuntu22.04-arm64.deb">点击下载</a>deb安装包。

2. 通过如下命令安装：

``` bash
sudo dpkg -i ./datalayers-{@version_number@}-ubuntu22.04-arm64.deb
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

## 体验功能

安装完成后，可通过[命令行工具](./command-line-tool.md)快速体验 Datalayers 的各项功能。

## 卸载 Datalayers

普通模式卸载(保留二进制文件、配置文件)：

``` bash
sudo dpkg -r datalayers 
```

纯净模式卸载(不保留二进制文件、配置文件)：

``` bash
sudo dpkg -P datalayers 
```