# INCLUDE Statement

消除被 EXCLUDE 节点的被排除状态，可以分配 partition 到 INCLUDE 的节点上。

## 语法

```SQL
INCLUDE NODE 'node_name'

# 示例：将 node name 为：datalayers-1:8360 的节点重新加回集群
INCLUDE NODE 'datalayers-1:8360'
```

被排除节点的名字可以通过 `SHOW CLUSTER` 指令查询到。

## 注意事项

* 只允许 INCLUDE 被 EXCLUDE 排除的节点。

```tips
仅支持在集群模式下使用。
```
