# Index Configuration

The `index` section manages the parameters using in index.

## Sample  

```toml
# The configurations of index.
[index]

# The configurations for tantivy engine.
[index.tantivy]
# Limit of memory budget when building index.
# Default: "100MB".
build_memory = "100MB"

# The cache of index is a hybrid cache.
[index.cache]
# Capacity for memory cache.
# Setting to 0 will disable memory cache.
# Default: "0MB"
memory = "10GB"

```
