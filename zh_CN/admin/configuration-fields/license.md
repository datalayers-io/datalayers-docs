# License 配置

`license` 部分管理 Datalayers 系统的许可证密钥。

## 配置示例  

```toml
# The configurations of license.
# Configuration `key` has higher priority than `file`,
# when no `key` is specified, the `file` configuration will be used.
[license]
# A trial license key which may be deprecated.
key = "eyJ2IjoxLCJ0IjoxLCJjbiI6IkRhdGFsYXllcnMiLCJjZSI6InlpbmJvLnlhbmdAZGF0YWxheWVycy5pbyIsInNkIjoiMjAyNTEyMTUiLCJ2ZCI6MTgyLCJubCI6NSwiY2wiOjEwMDAsImVsIjoxMDAwMDAwMCwiZnMiOltdfQo=.a3GoQ3tQ2q/DyZxTaX6M5HLuNT64/IoMfgEML+dZBTwEy0SNvG0nQesJhAssw9TlTyh5FKuqfWQsBmS3JMbtub+LNB1YF51TB19dd8qv3UKT/FZg4TWql+drtFxRZPPVLg1QZA7vV11OWZWSg5Id3ZDskXOw1Fn1pWTDO8GC4hfqQQvMclYmfmLYrkkEv8+cikqTiv2DU5zzV+Oca2emKTYOJ5Ti9wYtD/2gu0niekCXgjRblDFa9Yauypqo/v2oE/6R7zqPOxre1EjqdCtmURRtMdievOwubXYpBljt/LJ079sY/3wgYq65L65rdpW+/u9PdwFIz9AIsgM1dV1lkQ=="

# The path of license file,
# Default: "/var/lib/datalayers/license/key.lic"
# file = "/var/lib/datalayers/license/key.lic"
```
