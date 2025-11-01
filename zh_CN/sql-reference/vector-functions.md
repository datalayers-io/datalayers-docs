# 向量函数详解

## 功能概述
向量函数是 Datalayers 提供的专门用于处理高维向量数据的核心工具集，支持向量距离计算、向量数学运算和向量归一化等操作

## 向量距离函数
向量距离函数用于计算两个相同维度的向量之间的距离。目前提供以下向量距离函数：

- `l2_distance`：L2 距离函数。
- `cosine_distance`：余弦距离函数。
- `dot_distance`：负内积距离函数。

### L2 距离函数

L2 距离，又称欧式距离，其计算公式为：

$$
\text{l2\_distance}(\mathbf{x}, \mathbf{y}) = \sqrt{\sum_{i=1}^n (x_i - y_i)^2}
$$

语法：

```sql
l2_distance(x, y)
```

示例：

```sql
# 计算两个向量之间的 L2 距离
SELECT l2_distance([1.0, 1.0, 1.0], [1.0, 1.0, 2.5]);

# 计算向量列 `embed` 与目标向量之间的 L2 距离
SELECT l2_distance(embed, [1.0, 2.0, 3.0]) FROM t;

# 根据向量列 `embed` 与目标向量之间的 L2 距离，对数据进行排序，并输出距离最近的一行数据
SELECT * FROM t ORDER BY l2_distance(embed, [1.0, 2.0, 3.0]) LIMIT 1;
```

### 余弦距离函数

计算公式为：

$$
\text{cosine\_distance}(\mathbf{x}, \mathbf{y}) = 1 - \frac{\mathbf{x} \cdot \mathbf{y}}{\|\mathbf{x}\|_2 \cdot \|\mathbf{y}\|_2} = 1 - \frac{\sum_{i=1}^n x_i y_i}{\sqrt{\sum_{i=1}^n x_i^2} \cdot \sqrt{\sum_{i=1}^n y_i^2}}
$$

语法：

```sql
cosine_distance(x, y)
```

示例：参考 L2 距离函数的示例。

### 负内积距离函数

向量的内积（Dot Product，又称 Inner Product），定义为两个向量逐个元素的乘积之和。负内积，则为内积的负。之所以使用负内积，
是因为我们希望使得所有向量距离函数，均满足距离越小、向量相似度越大的关系。

计算公式为：

$$
\text{dot\_distance}(\mathbf{x}, \mathbf{y}) = -\mathbf{x} \cdot \mathbf{y} = -\sum_{i=1}^n x_i y_i
$$

语法：

```sql
l2_distance(x, y)
```

示例：参考 L2 距离函数的示例。

## 向量数学计算函数

向量数学计算函数用于向量的一些数学性质。目前提供以下函数：

- `dim`：维度函数，求解一个向量的维度，即向量中元素的数量。
- `l2_norm`：L2 模函数，求解一个向量的 L2 模（或称 L2 范数）。
- `l2_normalize`：L2 归一化函数，使用 L2 模对向量执行归一化。

### 维度函数

语法：

```sql
dim(x)
```

示例：

```sql
# 计算一个向量的维度，输出应为 3
SELECT dim([1.0, 2.0, 3.0]);

# 计算一个向量列中每个向量的维度
SELECT dim(embed) FROM t;
```

### L2 模函数

L2 模函数通常用于执行向量归一化，即将一个向量转换为模为 1 的单位向量，便于后续执行向量计算。一个向量的 L2 模的计算公式为：

$$
\text{l2\_norm}(\mathbf{x}) = \|\mathbf{x}\|_2 = \sqrt{\sum_{i=1}^n x_i^2}
$$

语法：

```sql
l2_norm(x)
```

示例：

```sql
# 计算一个向量的 L2 模
SELECT l2_norm([1.0, 2.0, 3.0]);

# 计算一个向量列中每个向量的 L2 模
SELECT l2_norm(embed) FROM t;
```

### L2 归一化函数

该函数使用 L2 模将向量转换为标准向量，即模长为 1 的单位向量。使用 L2 模的向量归一化公式为：

$$
\text{normalized\_vector} = \frac{\mathbf{x}}{\|\mathbf{x}\|_2} = \left[ \frac{x_1}{\sqrt{\sum x_i^2}}, \frac{x_2}{\sqrt{\sum x_i^2}}, ..., \frac{x_n}{\sqrt{\sum x_i^2}} \right]
$$

语法：

```sql
l2_normalize(x)
```

示例：

```sql
# 对一个向量执行归一化
SELECT l2_normalize([1.0, 2.0, 3.0]);

# 对一个向量列中的每个向量执行归一化
SELECT l2_normalize(embed) FROM t;
```

## 注意事项

- 向量函数只能作用与向量字面量或者向量类型的列。其中包含整型元素或浮点型元素的列表，都被视为合法的向量字面量。例如 `[1, 2, 3]` 与 `[1.0, 2.0, 3.0]` 等均合法。
- 向量距离函数要求参与计算的两个参数（向量字面量或向量列）的维度相等。
