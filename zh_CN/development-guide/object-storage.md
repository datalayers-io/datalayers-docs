---
title: "对象存储配置指南"
description: "Datalayers 对象存储配置指南：介绍存算分离架构优势、S3 兼容存储接入方式、前置条件与默认对象存储配置，帮助你在生产环境中完成弹性扩展与成本优化。"
---
# 对象存储配置指南

## 概述

Datalayers 采用存算分离架构，将计算层和存储层完全解耦，使得能够根据业务需求独立扩展计算和存储资源。这种架构不仅避免了资源浪费，优化了成本效益，同时显著提升了系统的整体性能、安全性和可维护性。因此，在具备对象存储服务的条件下，我们推荐用户优先选择 **存算分离** 的部署方案。

## 架构优势

- **弹性扩展**：计算与存储解耦，支持独立按需扩展
- **运维简单**：使用公有云对象存储时，存储运维由云服务商保障，极大降低运维成本
- **快速扩容**：在公有云环境中可通过简单操作实现存储容量的快速扩展
- **高可用性**：公有云对象存储通常提供高达 99.999999999%（11个9）的数据持久性，并支持跨区域容灾

## 支持的对象存储服务

目前，Datalayers 已支持主流公有云的对象存储服务，包括 AWS、GCP、Azure、阿里云、腾讯云、华为云等。同时，对于兼容 S3 协议的对象存储服务（如 MinIO）也可直接接入。

## 配置对象存储服务

### S3 兼容存储配置

在使用对象存储前，请先确认以下前置条件：

- 已创建对象存储桶（bucket）并确认读写权限可用
- 已获取访问凭证（Access Key / Secret Key 或等效凭证）
- Datalayers 节点可访问对象存储 endpoint
- 已确认对象存储区域（region）与 endpoint 配置一致

满足前置条件后，请修改配置文件并填写对象存储服务地址。以下以 S3 为例：

```toml
# The configurations of the S3 object store.
# We support both virtual-hosted–style and path-style URL access in S3 service.
# Set to true to enable virtual-hosted–style request.
# In a virtual-hosted–style URI, the bucket name is part of the domain name in the URL,
# the endpoint use the following format: https://bucket-name.s3.region-code.amazonaws.com.
# In a path-style URI, the bucket is the first slash-delimited component of the Request-URI,
# the endpoint use the following format: https://s3.region-code.amazonaws.com/bucket-name.
# We support path-style URL access in minio even though your minio service does not enable this feature,
# and you are also allowed accessing with path-style like http://<ip>:<port> or http://minio.example.net
# if you set `virtual_hosted_style` to false
[storage.object_store.s3]
bucket = "datalayers"
access_key = "PLEASE_CHANGE_ME"
secret_key = "PLEASE_CHANGE_ME"
endpoint = "https://bucket-name.s3.region-code.amazonaws.com"
# region = "region-code"
# write_rate_limit = "0MB"
virtual_hosted_style = true

# [storage.object_store.azure]
# container = "datalayers" # you can customize this value
# account_name = "PLEASE CHANGE ME"
# account_key = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"
# write_rate_limit = "0MB"

# [storage.object_store.gcs]
# bucket = "datalayers" # you can customize this value
# scope = "PLEASE CHANGE ME"
# credential_path = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"
# write_rate_limit = "0MB"
```

### 指定使用对象存储服务

完成对象存储服务配置后，可通过以下参数让新建表默认使用对象存储。以下以 S3 为例：

```toml
[storage.object_store]
# Supported (the case is not sensitive):
# - s3.
# - azure.
# - gcs.
# - local (only working in standalone mode)
# Default: local|fdb
default_storage_type = "s3"
```

通过合理配置对象存储服务，可以充分发挥存算分离架构的优势，实现弹性扩展和成本优化。
