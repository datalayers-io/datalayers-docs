# Ubuntu 系统安装指南

本文详细介绍在 Ubuntu 系统中安装、使用 Datalayers 数据库的完整流程。

Datalayers 支持的 Ubuntu 版本包括：

- Ubuntu 20.04
- Ubuntu 22.04
- Ubuntu 24.04

## 安装 Datalayers

:::: tabs
::: tab amd64

1. 下载安装包, <a href="https://docs.datalayers.cn/public/ubuntu/datalayers-{@version_number@}-ubuntu24.04-amd64.deb" download="datalayers-{@version_number@}-ubuntu24.04-amd64.deb">点击下载</a>deb安装包。

> 或者直接使用`wget`命令下载安装包：
>
> ``` bash
> wget https://docs.datalayers.cn/public/ubuntu/datalayers-{@version_number@}-ubuntu24.04-amd64.deb
> ```

2. 通过如下命令安装：

``` bash
sudo dpkg -i ./datalayers-{@version_number@}-ubuntu24.04-amd64.deb
```

:::

::: tab arm64

1. 下载安装包, <a href="https://docs.datalayers.cn/public/ubuntu/datalayers-{@version_number@}-ubuntu24.04-arm64.deb" download="datalayers-{@version_number@}-ubuntu24.04-arm64.deb">点击下载</a>deb安装包。

> 或者直接使用`wget`命令下载安装包：
>
> ``` bash
> wget https://docs.datalayers.cn/public/ubuntu/datalayers-{@version_number@}-ubuntu24.04-arm64.deb
> ```

2. 通过如下命令安装：

``` bash
sudo dpkg -i ./datalayers-{@version_number@}-ubuntu24.04-arm64.deb
```
:::

::::

## 升级 Datalayers

如果您需要升级 Datalayers，将上述安装命令中的 Datalayers 版本替换为更高版本，即可执行升级。
升级过程中，旧版本的 Datalayers 包会被卸载，但是会保留用户数据。

对于配置文件，我们优先保留您修改的配置，以确保升级不会导致您的自定义配置丢失。

**配置文件冲突处理策略**
1. 如果您没有修改默认的配置，则升级后会使用新版本的配置文件。
2. 如果您修改了默认的配置，但是修改内容与新版本的配置文件不冲突，我们保留您所修改的配置，同时会加入新的配置。
3. 如果您修改了默认的配置，且修改内容与新版本的配置文件冲突了，我们会弹出提示框，要求您采取某一种 dpkg 支持的冲突化解策略。示例如下：

``` bash
Configuration file '/etc/datalayers/datalayers.toml'
 ==> Modified (by you or by a script) since installation.
 ==> Package distributor has shipped an updated version.
   What would you like to do about it ?  Your options are:
    Y or I  : install the package maintainer's version
    N or O  : keep your currently-installed version
      D     : show the differences between the versions
      Z     : start a shell to examine the situation
 The default action is to keep your current version.
*** datalayers.toml (Y/I/N/O/D/Z) [default=N] ? 
```

**强制处理选项​​**
- 强制保留您的配置文件
```shell
shell sudo dpkg --force-confold -i datalayers-{@version_number@}-ubuntu24.04-amd64.deb
```

- 使用新版本配置
```shell 
sudo dpkg --force-confnew -i datalayers-{@version_number@}-ubuntu24.04-amd64.deb
```

## 服务管理

### 启动服务
执行以下命令，将以 systemd 方式启动（单机模式）：

``` bash
sudo systemctl start datalayers
```

### 查看服务状态
可通过以下命令查看其启动状态：

``` bash
systemctl status datalayers
```

### 停止服务
可通过以下命令停止服务：

``` bash
sudo systemctl stop datalayers
```

### 重启服务
可通过以下命令重启服务：

``` bash
sudo systemctl restart datalayers
```

## 卸载 Datalayers

如需卸载 Datalayers，可以通过以下两种方式：

### 普通模式卸载

``` bash
sudo dpkg -r datalayers 
```
此模式仅删除二进制文件的软链接，保留配置文件和数据文件

> 注意，普通模式会将 `/usr/local/bin/` 目录下的二进制文件的软链接删除，而不会删除 `/usr/lib/datalayers/bin/` 目录下的二进制文件。

### 纯净模式卸载

``` bash
sudo dpkg -P datalayers 
```
此模式将彻底删除所有相关文件，包括配置和数据

## 体验功能

成功启动容器后，您可以通过以下方式体验 Datalayers：
- 使用命[命令行工具](./command-line-tool.md)连接数据库进行操作
- 使用 [DBeaver](../integration/datalayers-with-dbeaver.md) 连接数据库进行操作
- 使用 [HTTP](../development-guide/rest-api/overview.md) 协议连接数据库进行操作
