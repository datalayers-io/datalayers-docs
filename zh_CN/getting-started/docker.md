# 通过 Docker 快速体验 Datalayers

本文将介绍如何通过 Docker 快速体验 Datalayers 的各项功能。若未安装 Docker，请至<a href="https://docs.docker.com/get-docker/" target="_blank">Docker官方文档</a>查看并安装。


## 通过 Docker 启动 Datalayers

首先，请执行以下命令拉取最新的 Datalayers 镜像：

``` bash
docker pull datalayers/datalayers:nightly
```

或者拉取指定版本的镜像：

``` bash
docker pull datalayers/datalayers:v{@version_number@}
```

执行以下命令，启动一个 Datalayers 容器：

``` bash
docker run --name datalayers -d \
  -v ~/data:/var/lib/datalayers \
  -p 8360:8360 -p 8361:8361 \
  datalayers/datalayers:nightly 
```

::: tip
其中`~/data`是指定容器运行数据能持久化的目录。

Datalayers 默认将启动 `8360` 与 `8361` 端口：
- `8360`端口用于提供 gRPC 服务；
- `8361`端口用于提供 HTTP 服务；
:::

可以通过`docker ps -a`命令来查看容器运行状态。


此外，也可以执行以下命令进入容器：

``` bash
docker exec -it datalayers bash
```

## 体验功能
当进入容器后，即可使用[命令行工具](./command-line-tool.md)，从而快速体验 Datalayers 的各项丰富功能。
