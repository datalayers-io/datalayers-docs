# License 配置

`license` 部分管理 Datalayers 系统的许可证密钥。

## 配置示例  

```toml
# The configurations of license.
# Configuration `key` has higher priority than `file`,
# when no `key` is specified, the `file` configuration will be used.
[license]
# A trial license key which may be deprecated.
key = "eyJ2IjoxLCJ0IjoxLCJjbiI6Iua+nOWbvuacquadpe+8iOaIkOmDve+8ieaVsOaNruenkeaKgOaciemZkOWFrOWPuCIsImNlIjoieWluYm8ueWFuZ0BkYXRhbGF5ZXJzLmlvIiwic2QiOiIyMDI1MDUwOSIsInZkIjoyMzYsIm5sIjozLCJjbCI6MzAsImVsIjoxMDAwMDAsImZzIjpbXX0K.e1gDGsCpvPA1fy/j2JUDvuug/kxJQyuAan0fIn3gGmFL1JUQ3V1bsi73jVl6R3wBkxMbJ13tWdBcTYZREVCVjqy22HvcSkGYJqKiQ0qx2jP2Zq22z2oiO/3frs0xuMdF6g5IE9C6PQq5X/OeFi6eFSTze4mcJhc5DaeB176oSqkyyAf+aKS23ncybYE2Nb55tkKwEVkWao3guMVhIsySInE0PXlaRYuAwmMsA0laYt1C1ZX+ktBu4CI/+C9tH6BvmkvPEagayjoITzjqdx9YRjM7/c8cSa159thLqYzvfQlLXX48bua5DS16KETk19BBc/uaHZxYXzSE1wYXFArjKw=="

# The path of license file,
# Default: "/var/lib/datalayers/license/key.lic"
file = "/var/lib/datalayers/license/key.lic"
```
