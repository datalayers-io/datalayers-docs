# CentOS

本文将介绍 Datalayers 在 CentOS 系统中的安装及使用。

Datalayers 支持的 CentOS 版本为：

- CentOS 7
- CentOS 8

## 通过 rpm 包安装

:::: tabs
::: tab amd64

1. 下载安装包，<a href="https://docs.datalayers.cn/public/centos/datalayers-{@version_number@}-el7-amd64.rpm" download="datalayers-{@version_number@}-el7-amd64.rpm">点击下载</a>rpm安装包。

> 或者直接使用`wget`命令下载安装包：
>
> ``` bash
> wget https://docs.datalayers.cn/public/centos/datalayers-{@version_number@}-el7-amd64.rpm
> ```

2. 通过如下命令安装：

``` bash
sudo yum localinstall ./datalayers-{@version_number@}-el7-amd64.rpm
```

::: tip

您可以使用 rpm 的 `--test` 选项来测试安装，而不实际执行安装：

``` bash
sudo rpm --test -i ./datalayers-{@version_number@}-el7-amd64.rpm
```

:::

:::

::::

## 升级 Datalayers

如果您需要升级 Datalayers，将上述安装命令中的 Datalayers 版本替换为更高版本，即可执行升级。
升级过程中，旧版本的 Datalayers 包会被卸载，但是会保留用户数据。

对于配置文件，我们优先保留您修改的配置，以确保升级不会导致您的自定义配置丢失。具体而言：

1. 如果您没有修改默认的配置，则升级后会使用新版本的配置文件。
2. 如果您修改了默认的配置，则我们总是保留您的配置文件，新版本的配置文件会被命名为 `datalayers.toml.rpmnew` 存储到 `/etc/datalayers/` 目录。

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

该命令会清理数据与配置文件。

## 体验功能

安装完成后，即可使用[命令行工具](./command-line-tool.md)快速体验 Datalayers 的各项功能。
