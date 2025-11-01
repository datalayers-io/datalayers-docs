# INCLUDE NODE 语句详解

## 功能概述
INCLUDE NODE 语句用于恢复被排除节点的集群参与资格。执行后，目标节点将重新成为集群的活跃成员，可以接收新的数据分区分配，实现集群的动态扩容或故障恢复。

## 语法

```SQL
INCLUDE NODE 'node_name'

# 示例：将 node name 为：datalayers-1:8360 的节点重新加回集群
INCLUDE NODE 'datalayers-1:8360'
```

被排除节点的名字可以通过 `SHOW CLUSTER` 指令查询到。

## 注意事项

* 只允许 INCLUDE 被 EXCLUDE 排除的节点；
* 仅支持在集群模式下使用。

