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

返回值：一个 bool 值，表示给定的 key 是否存在。如果存在，返回 `true`；否则返回 `false`。

示例：

``` sql
-- 检视字符串 "{"city": "Chengdu"}" 中是否包含一个 'city' 键
select json_contains("{"city": "Chengdu"}", 'city');

-- 查询表 t 中 json_col 字段包含 'city' 键的所有记录
select * from t where json_contains(json_col, 'city') = true;

-- 查询表 t 中 json_col 字段包含 'name.first' 键的所有记录
select * from t where json_contains(json_col, 'name.first') = true;
```

### json_get_bool

功能：从 Json 字符串中提取指定 key 对应的布尔型 value。

语法：

``` sql
json_get_bool(expression, key)
```

其中 `expression` 可以为一个字符串字面量，或字符串类型的列。

返回值：

- 如果给定的 key 不存在，返回一个空值，即 null。
- 如果给定的 key 存在，且 value 的类型为布尔型或可以转换为布尔型，返回（可能经过类型转换的） value。
- 如果给定的 key 存在，但 value 的类型不为布尔型且无法转换为布尔型，返回错误。

示例：

``` sql
-- 从字符串中提取 'active' 键对应的布尔值
select json_get_bool('{"name": "Bob", "active": true}', 'active');

-- 查询 json_col 字段的所有包含 'active' 键且 'active' 键的值为布尔型、或可转换为布尔型的记录
select * from t where json_get_bool(json_col, 'active') is not null;

-- 查询 json_col 字段的 'settings.enabled' 为 true 的记录
select * from t where json_get_bool(json_col, 'settings.enabled') = true;
```

### json_get_int

### json_get_float

### json_get_str
