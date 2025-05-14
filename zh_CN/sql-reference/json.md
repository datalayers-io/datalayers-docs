# Json Functions

Json 函数用于访问一个 Json 格式的字符串或字符串类型的列。

## 函数列表

我们目前提供以下 Json 函数：

- [`json_contains`](#json_contains)
- [`json_get_bool`](#json_get_bool)
- [`json_get_int`](#json_get_int)
- [`json_get_float`](#json_get_float)
- [`json_get_str`](#json_get_str)

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
select json_contains('{"city": "Chengdu"}', 'city');

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
- 如果给定的 key 存在，且 value 的类型为布尔型或可以转换为布尔型，返回（可能经过类型转换的）value。
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

功能：从 Json 字符串中提取指定 key 对应的整型 value。

语法：

``` sql
json_get_int(expression, key)
```

其中 `expression` 可以为一个字符串字面量，或字符串类型的列。

返回值：

- 如果给定的 key 不存在，返回一个空值，即 null。
- 如果给定的 key 存在，且 value 的类型为整型或可以转换为整型，返回（可能经过类型转换的）value。
- 如果给定的 key 存在，但 value 的类型不为整型且无法转换为整型，返回错误。

示例：

``` sql
-- 从字符串中提取 'age' 键对应的整数值
select json_get_int('{"name": "Alice", "age": 25}', 'age');

-- 查询表 t 中 json_col 字段的所有包含 'user.id' 键且值为整型的记录
select * from t where json_get_int(json_col, 'user.id') is not null;

-- 查询 json_col 字段的 'count' 值大于 100 的记录
select * from t where json_get_int(json_col, 'count') > 100;
```

### json_get_float

功能：从 Json 字符串中提取指定 key 对应的浮点型 value。

语法：

``` sql
json_get_bool(expression, key)
```

其中 `expression` 可以为一个字符串字面量，或字符串类型的列。

返回值：

- 如果给定的 key 不存在，返回一个空值，即 null。
- 如果给定的 key 存在，且 value 的类型为浮点型或可以转换为浮点型，返回（可能经过类型转换的）value。
- 如果给定的 key 存在，但 value 的类型不为浮点型且无法转换为浮点型，返回错误。

示例：

``` sql
-- 从字符串中提取 'price' 键对应的浮点数值
select json_get_float('{"item": "book", "price": 29.99}', 'price');

-- 查询表 t 中 json_col 字段的所有包含 'stats.rating' 键且值为数值型的记录
select * from t where json_get_float(json_col, 'stats.rating') is not null;

-- 查询 json_col 字段的 'measurements.weight' 值在 50.0 到 80.0 之间的记录
select * from t where json_get_float(json_col, 'measurements.weight') between 50.0 and 80.0;
```

### json_get_str

功能：从 Json 字符串中提取指定 key 对应的字符串型 value。

语法：

``` sql
json_get_str(expression, key)
```

其中 `expression` 可以为一个字符串字面量，或字符串类型的列。

返回值：

- 如果给定的 key 不存在，返回一个空值，即 null。
- 如果给定的 key 存在，且 value 的类型为字符串型或可以转换为字符串型，返回（可能经过类型转换的）value。
- 如果给定的 key 存在，但 value 的类型不为字符串型且无法转换为字符串型，返回错误。

示例：

``` sql
-- 从字符串中提取 'name' 键对应的字符串值
select json_get_str('{"id": 1, "name": "Charlie"}', 'name');

-- 查询表 t 中 json_col 字段的所有包含 'contact.email' 键且值为字符串型的记录
select * from t where json_get_str(json_col, 'contact.email') is not null;

-- 查询 json_col 字段的 'user.profile.bio' 值包含特定关键字的记录
select * from t where json_get_str(json_col, 'user.profile.bio') like '%developer%';
```
