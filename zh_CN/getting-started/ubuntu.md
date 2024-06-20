# Ubuntu

本文将介绍 Datalayers 在 Ubuntu 系统中的安装及使用。

Datalayers 支持的 Ubuntu 版本为：
- Ubuntu 22.04

## 通过 deb 包安装

请<a href="https://docs.datalayers.cn/public/ubuntu/datalayers_1.0.0-1_amd64.deb" download="datalayers_1.0.0-1_amd64.deb">点击下载</a> deb 安装包。

:::: tabs
::: tab amd64

``` bash
sudo dpkg -i datalayers_*_amd64.deb
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
sudo dpkg -r datalayers
```