#!/bin/bash
set -euo pipefail

: : "${PROJECT_ROOT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
: "${JAVA_FRONTEND_DIR_NAME:=java_frontend}"
: "${RUST_BACKEND_DIR_NAME:=rust_backend}"

echo "Inspecting Scrutinaut project structure..."

if [[ -d "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}" ]]; then
    echo "Java frontend exists: ${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}"
    tree "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}" || ls -R "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}"
else
    echo "Java frontend directory not found."
fi

if [[ -d "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}" ]]; then
    echo "Rust backend exists: ${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}"
    tree "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}" || ls -R "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}"
else
    echo "Rust backend directory not found."
fi
