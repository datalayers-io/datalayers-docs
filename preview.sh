#!/bin/bash
set -euo pipefail

## this script is to run a docker container to
## 1. render the markdown files for vuepress
## 2. serve the rendered HTML pages in a vuepress site
##
## It takes one argument as the listener port number the
## port number which defaults to 8080

PORT="${1:-8080}"

THIS_DIR="$(cd "$(dirname "$(readlink "$0" || echo "$0")")"; pwd -P)"

docker rm datalayers-doc-preview > /dev/null 2>&1 || true

python3 "$THIS_DIR/gen.py" > directory.json
docker run -p ${PORT}:8080 -it --name datalayers-doc-preview \
-v "$THIS_DIR"/directory.json:/app/docs/.vitepress/config/directory.json \
-v "$THIS_DIR"/en_US:/app/docs/en/datalayers/latest \
-v "$THIS_DIR"/zh_CN:/app/docs/zh/datalayers/latest \
-e DOCS_TYPE=datalayers \
-e VERSION=latest \
ghcr.io/datalayers-io/docs-datalayers-frontend:latest
