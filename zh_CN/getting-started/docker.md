# Docker 环境安装指南

本文介绍如何使用 Docker 快速部署和体验 Datalayers 数据库。若未安装 Docker，请至<a href="https://docs.docker.com/get-docker/" target="_blank"> Docker官方文档 </a>查看并安装。

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

**参数说明​​**
- -v ~/data:/var/lib/datalayers：将主机目录挂载至容器，确保数据持久化
- -p 8360:8360：映射 gRPC 服务端口
- -p 8361:8361：映射 HTTP 服务端口

> **重要提示**​​：
> 请将 ~/data替换为您希望持久化存储数据的实际目录路径。


### 验证服务状态

可以通过`docker ps -a`命令来查看容器运行状态。

此外，也可以执行以下命令进入容器：

``` bash
docker exec -it datalayers bash
```

## 体验功能

成功启动容器后，您可以通过以下方式体验 Datalayers：
- 使用命[命令行工具](./command-line-tool.md)连接数据库进行操作
- 使用 [DBeaver](../integration/datalayers-with-dbeaver.md) 连接数据库进行操作
- 使用 [HTTP](../development-guide/insert-with-restapi.md) 协议连接数据库进行操作
