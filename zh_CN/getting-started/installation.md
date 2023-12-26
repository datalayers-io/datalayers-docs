# 安装部署
DataLayers 基于存算分离的架构，在部署过程中需涉及存储层与计算层等组件。为了快速体验功能，本章节提供 docker-compose 的方式进行一键部署。如你需要构建集群，请参考[集群构建](../cluster/introduction.md)章节。

如需了解更详细部署信息，可参考运维指南中： [配置手册](../admin/datalayers-configuration.md)。


## docker-compose

```bash
$ git clone //github.com/datalayers-io/datalayers.git
$ cd datalayers/deploy/docker-compose
## 拉取镜像
$ docker compose pull
## 启动服务
$ docker compose up -d
```
