# PromQL 兼容性

## 概述

Datalayers 提供高度兼容的 PromQL 查询能力，支持绝大多数常用的选择器、运算符和函数，确保从 Prometheus 平滑迁移。

## 选择器

Datalayers 支持 Instant 选择器和 Range 选择器。

**标签匹配支持**：

|匹配运算符      | 普通标签    |  特殊标签 `__name__`  |  特殊标签 `__database__`  |
| :---          | :---       | :---                  | :---                     |
| =             | ✅ 支持     |✅ 支持                |✅ 支持                   |
| !=            | ✅ 支持     |✖ 不支持               |✖ 不支持                   |
| =~            | ✅ 支持     |✖ 不支持               |✖ 不支持                   |
| !~            | ✅ 支持     |✖ 不支持               |✖ 不支持                   |

**注**：Datalayers 支持 `offset` 修饰符，但不支持 `@` 修饰符。

## 运算符和函数

| 类型 | 支持 | 不支持 |
| :--- | :--- | :--- |
| **运算符** | `neg`, `add`, `sub`, `mul`, `div`, `mod`, `eq`, `ne`, `gt`, `lt`, `ssgt`, `sslt`, `sseq`, `ssne`, `slt`, `sle`, `sge`, `power`, `atan2`, `and`, `or`, `unless` | - |
| **聚合** | `sum`, `avg`, `min`, `max`, `stddev`, `stdvar`, `topk`, `bottomk`, `count_values`, `count`, `quantile`, `grouping`| `limitk`, `limit_ratio` |
| **Instant 函数** | `abs`, `ceil`, `exp`, `ln`, `log2`, `log10`, `sqrt`, `acos`, `asin`, `atan`, `sin`, `cos`, `tan`, `acosh`, `asinh`, `atanh`, `sinh`, `cosh`, `scalar`, `tanh`, `timestamp`, `sort`, `sort_desc`, `histogram_quantile`, `predict_linear`, `absent`, `sgn`, `pi`, `deg`, `rad`, `floor`, `clamp`, `clamp_max`, `clamp_min` | 其它 `histogram_<aggr>` 函数|
| **Range 函数** | `idelta`, `<aggr>_over_time` (如 `count_over_time`, `stddev_over_time`, `stdvar_over_time`), `changes`, `delta`, `rate`, `deriv`, `increase`, `irate`, `reset` | - |
| **其他函数** | `label_join`, `label_replace`, `sort_by_label`, `sort_by_label_desc` | - |
