---
title: "Datalayers Docker 安装指南"
description: "介绍如何通过 Docker 快速部署 Datalayers，包括镜像拉取、容器启动、端口映射、数据持久化与基础连接验证。"
---
# Datalayers Docker 安装指南

本文介绍如何通过 Docker 快速部署 Datalayers，适用于本地体验、开发测试和功能验证。若尚未安装 Docker，请前往 [Docker 官方文档](https://docs.docker.com/get-docker/) 查看安装说明。

## 通过 Docker 启动

### 拉取 Datalayers 镜像

首先，请执行以下命令拉取最新的 Datalayers 镜像：

``` bash
docker pull datalayers/datalayers:latest
```

或者拉取指定版本的镜像：

``` bash
docker pull datalayers/datalayers:v{@version_number@}
```

### 启动 Datalayers

执行以下命令，启动一个 Datalayers 容器：

``` bash
docker run --name datalayers -d \
  -v ~/data:/var/lib/datalayers \
  -p 8360:8360 -p 8361:8361 \
  datalayers/datalayers:v{@version_number@} 
```

### 参数说明

- -v ~/data:/var/lib/datalayers：将主机目录挂载至容器，确保数据持久化
- -p 8360:8360：映射 gRPC 服务端口
- -p 8361:8361：映射 HTTP 服务端口

> **重要提示**：
> 请将 `~/data` 替换为您希望持久化存储数据的实际目录路径。

### 验证服务状态

可以通过 `docker ps -a` 查看容器运行状态。

如需进一步检查容器内部环境，也可以执行以下命令进入容器：

``` bash
docker exec -it datalayers bash
```

如果需要验证数据库是否已正常对外提供服务，可以继续使用 [命令行工具](./command-line-tool.md) 或 [HTTP REST API](../development-guide/rest-api/overview.md) 连接实例。

## 体验功能

成功启动容器后，您可以通过以下方式体验 Datalayers：

- 使用[命令行工具](./command-line-tool.md)连接数据库进行操作
- 使用 [DBeaver](../integration/datalayers-with-dbeaver.md) 连接数据库进行操作
- 使用 [HTTP](../development-guide/rest-api/overview.md) 协议连接数据库进行操作

## 相关文档

- 如果你需要长期运行或托管为系统服务，请参考 [Datalayers Ubuntu 安装指南](./ubuntu.md)
- 如果你希望验证交互式 SQL 操作，请参考 [Datalayers 命令行工具 dlsql 使用指南](./command-line-tool.md)
