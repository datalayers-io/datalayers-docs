# License 配置

`license` 部分管理 Datalayers 系统的许可证密钥。

## 配置示例  

```toml
# The configurations of license.
# Configuration `key` has higher priority than `file`,
# when no `key` is specified, the `file` configuration will be used.
[license]
# A trial license key which may be deprecated.
key = "eyJ2IjoxLCJ0IjoxLCJjbiI6InRlc3QiLCJjZSI6bnVsbCwic2QiOiIyMDI0MDUxNyIsInZkIjozNjUsIm5sIjoxMDAsImNsIjoyNTYsImVsIjoxMDAwLCJmcyI6W119.dLBEUr9WDhuTBllPiZ3lNXOL2YtjuvFVUYQvmc85Ak0jgqHhtoCVz09GHAqdPs8yrzMxnQRiGeK49/Puzvqi6X5X0rYEOx5eiKuifWEkYnXDjtUfdvY79Z4p1SWi5h56hyyyvgrc6lPCWnccqM+JWNWA1a3QHo6V288KBQPFZvOcUY1Kl6F9lHHs5NVx/Wq+92cqg+VJ+ONivxwt3Y35VRelFczARLrpYdngpUQtvXud4nRGuDTj4YkhEZAgpjZXg7WMS8w54zboDOPKcLL5bhUTYa4WSinhSeWLEniISPu0/TihSlXsp/UqamUnb+NHa2sjMTKzAp0CeOZwZA++fQ=="

# The path of license file,
# Default: "/var/lib/datalayers/license/key.lic"
file = "/var/lib/datalayers/license/key.lic"
```
