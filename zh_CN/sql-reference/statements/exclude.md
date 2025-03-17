# EXCLUDE Statement

将指定的计算节点从集群中排除，被排除节点上的 partition 会迁移到其它节点，被排除的节点被 include 之前，不能分配新的 partition 到该节点上。

## 语法

### EXCLUDE NODE 'node_name'

```SQL
EXCLUDE NODE '127.0.0.1:8360'
```

待排除节点的名字可以通过 ```SHOW CLUSTER``` 指令查询到。

## 注意事项

* 被排除的节点不是必须处于 READY 状态，可以排除异常离线的节点；
* 不能重复 EXCLUDE 已经被 EXCLUDE 的节点，可以 INCLUDE 后再进行 EXCLUDE；
* 如果剩余节点不足以支持 partition 迁移，EXCLUDE 会失败；
* 仅支持在集群模式下使用。
