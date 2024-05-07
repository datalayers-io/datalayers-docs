# System Functions


## 函数列表

|  Function             |      Description                                           |
|  -----------------    |------------------------------------------------------------|
| server_version()      |  返回当前连接节点的相关指标                                    |
| server_status()       |  返回当前连接节点的相关指标                                    |


## 示例
```SQL
-- 返回当前连接节点的版本信息
SELECT server_version();
-- 返回当前连接节点的状态信息
SELECT server_status();
```
