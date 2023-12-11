# Date Functions


## 函数列表
下表显示了`DATE`类型的可用函数。
|  Function         |Return Type    |      Description                                           |
|  -----------------|-------------- |------------------------------------------------------------|
| now()             | TIMESTAMP     |  返回当前时间, 时序与精度与 配置 保持一致                        |

::: tip
支持对时间进行加减操作， 如：NOW() - interval '7 day'
:::

## 日期函数运算
下表展示了`DATE`类型可用的数学运算符
|  Operator     |Description    |   Example                      |  结果                           |
|  -------------|-------------- |--------------------------------| -------------------------------|
|  +            |               |                                |                                 |
|  -            |               |                                |                                 |


## 示例
```SQL
-- 返回当前连接节点的版本信息
SELECT speed,temperature FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval '7 day';
```