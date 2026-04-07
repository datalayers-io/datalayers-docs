---
title: "INFORMATION_SCHEMA 元数据参考指南"
description: "INFORMATION_SCHEMA 是 Datalayers 提供的标准元数据目录，包含数据库、表、列、索引、后台任务、权限等系统视图。"
---
# INFORMATION_SCHEMA 元数据参考指南

## 概述

`INFORMATION_SCHEMA` 是 Datalayers 提供的系统元数据目录，包含数据库、表、列、索引、分区、任务、权限与集群状态等只读视图。

部分 system table 会根据当前用户的权限对结果进行裁剪，因此不同用户看到的内容可能不同。

## schemata

`schemata` 用于列出当前 catalog 下可见的数据库。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `database` | `STRING` | 数据库名称 |
| `created_time` | `STRING` | 数据库创建时间 |

## tables

`tables` 用于列出当前用户可见的表及其基础元信息。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `database` | `STRING` | 数据库名称 |
| `table` | `STRING` | 表名称 |
| `engine` | `STRING` | 表引擎类型 |
| `version` | `UINT32` | 表版本号，每次表结构变更后递增 |
| `created_time` | `STRING` | 表创建时间 |
| `updated_time` | `STRING` | 表最近一次更新时间 |

## columns

`columns` 用于查看列级元数据，包括类型、默认值、注释、编码与压缩设置。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `database` | `STRING` | 所属数据库名称 |
| `table` | `STRING` | 所属表名称 |
| `column` | `STRING` | 列名称 |
| `data_type` | `STRING` | 列的数据类型 |
| `is_nullable` | `STRING` | 列是否允许为 `NULL`，常见值为 `YES` 或 `NO` |
| `default` | `STRING` | 列的默认值表达式 |
| `ordinal_position` | `UINT32` | 列在表中的顺序位置，从 0 开始 |
| `comment` | `STRING` | 列注释 |
| `encoding` | `STRING` | 列编码算法 |
| `compression` | `STRING` | 列压缩算法 |

## indexes

`indexes` 用于查看表上的索引定义，包括索引类型、索引列和索引选项。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `database` | `STRING` | 所属数据库名称 |
| `table` | `STRING` | 所属表名称 |
| `non_unique` | `STRING` | 索引是否允许重复值 |
| `index_name` | `STRING` | 索引名称 |
| `seq_in_index` | `UINT64` | 当前列在索引中的顺序 |
| `index_column` | `STRING` | 索引列名称 |
| `null` | `STRING` | 索引列是否允许为 `NULL` |
| `index_id` | `UINT64` | 索引内部 ID |
| `index_type` | `STRING` | 索引类型，如倒排索引、向量索引等 |
| `index_options` | `STRING` | 索引创建时的选项 |
| `index_comment` | `STRING` | 索引注释 |

## index_files

`index_files` 用于查看索引文件级别的元数据，可用于排查索引存储占用和索引文件分布。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `database` | `STRING` | 所属数据库名称 |
| `table` | `STRING` | 所属表名称 |
| `partition_id` | `UINT64` | 分区 ID |
| `file_id` | `UINT64` | 索引文件 ID |
| `index_name` | `STRING` | 索引名称 |
| `index_id` | `UINT64` | 索引内部 ID |
| `index_type` | `STRING` | 索引类型 |
| `storage_type` | `STRING` | 索引文件使用的存储类型 |
| `file_size` | `UINT64` | 索引文件大小，单位为字节 |

## table_partitions

`table_partitions` 用于查看表分区到节点的分配情况和分区状态。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `database` | `STRING` | 所属数据库名称 |
| `table` | `STRING` | 所属表名称 |
| `node` | `STRING` | 当前分区所在节点 |
| `partition_id` | `UINT64` | 分区 ID |
| `version` | `UINT64` | 分区版本号 |
| `created_time` | `STRING` | 分区创建时间 |
| `updated_time` | `STRING` | 分区最近更新时间 |
| `state` | `STRING` | 分区状态 |

## partition_manifests

`partition_manifests` 用于查看分区 manifest 的版本和刷盘进度等元数据。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `database` | `STRING` | 所属数据库名称 |
| `table` | `STRING` | 所属表名称 |
| `partition_id` | `UINT64` | 分区 ID |
| `manifest_version` | `UINT32` | manifest 当前版本号 |
| `read_version` | `UINT32` | 分区当前可读版本号 |
| `flushed_wal_entry_id` | `UINT64` | 已刷盘的 WAL entry ID |
| `flushed_wal_offset` | `UINT64` | 已刷盘的 WAL offset |
| `flushed_seq_id` | `UINT64` | 已刷盘的序列号 |
| `max_ts_in_ssts` | `INT64` | 已落盘 SST 中的最大时间戳 |
| `schema_version` | `UINT32` | 分区使用的 schema 版本号 |

## sst_files

`sst_files` 用于查看表数据文件级别的元数据，包括文件大小、行数、时间范围和存储层信息。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `database` | `STRING` | 所属数据库名称 |
| `table` | `STRING` | 所属表名称 |
| `partition_id` | `UINT64` | 分区 ID |
| `file_name` | `STRING` | SST 文件名 |
| `file_id` | `UINT64` | SST 文件 ID |
| `file_size` | `UINT64` | 压缩后文件大小，单位为字节 |
| `unzip_size` | `UINT64` | 解压后数据大小，单位为字节 |
| `num_rows` | `UINT64` | 文件中的行数 |
| `min_ts` | `INT64` | 文件中的最小时间戳 |
| `max_ts` | `INT64` | 文件中的最大时间戳 |
| `storage_type` | `STRING` | 文件使用的存储类型 |
| `level` | `UINT64` | 文件所在层级 |
| `read_version` | `UINT64` | 文件所属读版本 |
| `schema_version` | `UINT32` | 文件对应的 schema 版本 |
| `is_delta` | `BOOLEAN` | 是否为 delta 文件 |

可以使用该系统表计算表数据的原始大小和压缩后的空间占用，例如：

```sql
select sum(file_size),sum(unzip_size) from sst_files where table = 'sx1'
```

## tasks

`tasks` 用于查看后台任务的聚合统计信息。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `node` | `STRING` | 任务所属节点；单机模式下该列可能不展示 |
| `type` | `STRING` | 任务类型，如 `flush`、`compact`、`gc` |
| `running` | `UINT32` | 当前运行中的任务数量 |
| `pending` | `UINT32` | 当前排队中的任务数量 |
| `concurrence_limit` | `UINT32` | 该类任务的并发上限 |
| `queue_limit` | `UINT32` | 该类任务的队列长度上限 |
| `description` | `STRING` | 任务类型说明 |

## tasks_detail

`tasks_detail` 用于查看后台任务实例的明细信息。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `node` | `STRING` | 任务所属节点；单机模式下该列可能不展示 |
| `type` | `STRING` | 任务类型 |
| `status` | `STRING` | 任务状态 |
| `submit_time` | `STRING` | 任务提交时间 |
| `start_time` | `STRING` | 任务开始执行时间 |
| `database` | `STRING` | 任务关联的数据库名称 |
| `table` | `STRING` | 任务关联的表名称 |
| `partition_id` | `UINT64` | 任务关联的分区 ID |

## users_privileges

`users_privileges` 用于查看用户或角色的全局权限及认证相关信息。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `user` | `STRING` | 用户名或角色名 |
| `host` | `STRING` | 主机匹配规则 |
| `privileges` | `STRING` | 已授予的全局权限集合 |
| `authentication_string` | `STRING` | 认证字符串 |
| `created_time` | `STRING` | 记录创建时间 |
| `updated_time` | `STRING` | 记录更新时间 |
| `password_past` | `STRING` | 密码已使用时长或密码过期相关信息 |
| `is_role` | `BOOLEAN` | 是否为角色 |

## dbs_privileges

`dbs_privileges` 用于查看数据库级权限授予情况。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `user` | `STRING` | 用户名或角色名 |
| `host` | `STRING` | 主机匹配规则 |
| `db` | `STRING` | 数据库名称 |
| `privileges` | `STRING` | 已授予的数据库级权限集合 |
| `created_time` | `STRING` | 记录创建时间 |
| `updated_time` | `STRING` | 记录更新时间 |

## tables_privileges

`tables_privileges` 用于查看表级权限授予情况。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `user` | `STRING` | 用户名或角色名 |
| `host` | `STRING` | 主机匹配规则 |
| `db` | `STRING` | 数据库名称 |
| `table` | `STRING` | 表名称 |
| `privileges` | `STRING` | 已授予的表级权限集合 |
| `created_time` | `STRING` | 记录创建时间 |
| `updated_time` | `STRING` | 记录更新时间 |

## user_role_edges

`user_role_edges` 用于查看用户与角色之间的授予关系。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `from_user` | `STRING` | 被授予角色的用户 |
| `from_host` | `STRING` | 被授予角色的用户主机匹配规则 |
| `to_user` | `STRING` | 被授予出去的角色名 |
| `to_host` | `STRING` | 角色对应的主机匹配规则 |
| `with_admin_option` | `BOOLEAN` | 是否携带 `WITH ADMIN OPTION` |
| `created_time` | `STRING` | 记录创建时间 |
| `updated_time` | `STRING` | 记录更新时间 |

## cluster

`cluster` 用于查看集群节点的运行状态和版本信息。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `node_name` | `STRING` | 节点名称 |
| `uptime` | `STRING` | 节点运行时长 |
| `node_state` | `STRING` | 节点状态 |
| `control_state` | `STRING` | 节点控制状态 |
| `created_time` | `TIMESTAMP(SECOND)` | 节点创建时间 |
| `last_alive` | `TIMESTAMP(SECOND)` | 最近一次心跳时间 |
| `version` | `STRING` | 节点版本号 |
| `cpu` | `STRING` | CPU 信息 |
| `memory` | `STRING` | 内存信息 |
| `build_time` | `STRING` | 构建时间 |
| `source_version` | `STRING` | 源码版本信息 |

## migration_history

`migration_history` 用于查看分区迁移任务的历史记录。

| 字段 | 类型 | 含义 |
| --- | --- | --- |
| `id` | `UINT64` | 迁移记录 ID |
| `trigger` | `STRING` | 迁移触发来源 |
| `database` | `STRING` | 迁移涉及的数据库名称 |
| `table` | `STRING` | 迁移涉及的表名称 |
| `partition_id` | `UINT64` | 迁移涉及的分区 ID |
| `start_time` | `TIMESTAMP(SECOND)` | 迁移开始时间 |
| `end_time` | `TIMESTAMP(SECOND)` | 迁移结束时间 |
| `src` | `STRING` | 源节点 |
| `dst` | `STRING` | 目标节点 |
| `state` | `STRING` | 迁移状态 |
| `details` | `STRING` | 迁移详情 |
