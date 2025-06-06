#!/bin/bash
set -euo pipefail
echo "[ERROR] $*" >> "${PROJECT_ROOT_DIR}/logs/error.log"
