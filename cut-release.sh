#!/bin/bash

set -euo pipefail

TODAY="$(date +%Y%m%d)"

TAG="${PREFIX}${VSN}-${TODAY}"
git tag -f "$TAG"

echo "$TAG"
