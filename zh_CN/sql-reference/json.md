# Json Functions

Json 函数用于访问一个 Json 格式的字符串或字符串类型的列。

## 函数列表

### json_contains

功能：检查 Json 字符串中是否包含指定的 key。

语法：

``` sql
json_contains(expression, key)
```

其中 `expression` 可以为一个字符串字面量，或字符串类型的列。

示例：

``` sql
-- 检视字符串 "{"city": "Chengdu"}" 中是否包含一个 'city' 键
select json_contains("{"city": "Chengdu"}", 'city');

-- 查询表 t 中 json_col 字段包含 'city' 键的所有记录
select * from t where json_contains(json_col, 'city') = true;

-- 查询表 t 中 json_col 字段包含 'name.first' 键的所有记录
select * from t where json_contains(json_col, 'name.first') = true;
```
