# 运维工具
Datalayers 提供 `dlctl`（Datalayers Control）作为运维工具包。目前，工具包里面包含数据转储工具，更多工具正在开发中。

## 安装 `dlctl`
我们目前只提供从源码编译 `dlctl` 的安装方式，我们预计在近期发布包含 `dlctl` 的安装包和镜像。

在项目根目录执行以下命令以编译 `dlctl`：
``` shell
cargo build --release --bin dlctl --features "dlctl"
```
该命令会以 release 模式编译 `dlctl`，编译产物默认位于项目根目录的 `target/release/dlctl` 路径。

## 工具概览
`dlctl` 提供了以下工具：
- 数据转储工具：用来执行 Datalayers 的数据转储，包括将数据从 Datalayers 转出，以及将数据转入 Datalayers。基于转储功能，我们可以实现数据导出与导入、数据备份与恢复。您可以访问 [数据转储工具](./datalayers-ctl-dump.md) 以了解如何使用该工具。

## 使用说明
假设您已经将 `dlctl` 引入了系统 PATH，执行命令 `dlctl --help` 可以查看 `dlctl` 的基础使用方式。该命令会在终端打印如下信息：
```
Datalayers operation tools

Usage: dlctl [OPTIONS] <COMMAND>

Commands:
  export   
  import   
  help     Print this message or the help of the given subcommand(s)

Options:
      --log-level <LOG_LEVEL>  The logging level [default: info]
  -h, --help                   Print help
  -V, --version                Print version
```
除了 `help` 之外，`dlctl` 提供如下子命令和选项：
- `export`：执行数据转出，基本使用方式为 `dlctl export --path "<export_path>"`，该命令会将 Datalayers 的数据导出到指定的 `export_path` 目录。
- `import`：执行数据转入，基本使用方式为 `dlctl import --path "<import_path>"`，该命令会从指定的 `import_path` 目录加载数据，然后导入到 Datalayes。
- `--log-level`：指定日志级别，可选的日志级别为 trace、debug、info、warn、error，默认的日志级别为 info。
- `-V`, `--version`：打印 `dlctl` 的版本，包括版本号、二进制构建日期、源码的 git revision。
