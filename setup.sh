#!/bin/bash
# filepath: /home/emhcet/private/projects/desktop/java/scrutinaut/setup.sh

set -euo pipefail

export PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPTS_DIR_NAME="scripts"
export HELPERS_DIR_NAME="helpers"
export UTILS_DIR_NAME="utils"
export LOGS_DIR_NAME="logs"

export JAVA_FRONTEND_DIR_NAME="java_frontend"
export JAVA_GROUP_ID="com.gmail.xuoxod.scrutinaut"
export JAVA_MAIN_CLASS_NAME_BASE="ScrutinautApp"
export JAVA_CORE_PACKAGE="core"
export JAVA_ARTIFACT_ID="scrutinaut-app"
export JAVA_VERSION="23"
export MAVEN_ARCHETYPE_VERSION="1.4"

export RUST_BACKEND_DIR_NAME="rust_backend"
export RUST_CRATE_NAME="scrutinaut_native"
export JNI_CRATE_VERSION="0.21.1"

if [ -t 1 ]; then
    NC='\033[0m'
    CYAN='\033[0;36m'
    YELLOW='\033[1;33m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BLUE_BG='\033[44;37m'
else
    NC='' CYAN='' YELLOW='' GREEN='' RED='' BLUE_BG=''
fi

print_help() {
    printf "%b" "${CYAN}Scrutinaut Automated Setup${NC}
Usage: ./setup.sh [--help|-h]

Run the real project setup. For a dry run preview, use: ./dryrun-preview.sh

This script will:
  - Check your system and platform
  - Scaffold all project directories and scripts
  - Prompt before deleting existing subproject directories
  - Run post-setup self-tests
  - Guide you with next steps

Enjoy a nerdy, beautiful CLI experience!
"
}

SHOW_HELP=0
for arg in "$@"; do
    case "$arg" in
        --help|-h) SHOW_HELP=1 ;;
    esac
done

if [[ $SHOW_HELP -eq 1 ]]; then
    print_help
    exit 0
fi

main() {
    if [[ -f "${PROJECT_ROOT_DIR}/splash.sh" ]]; then
        bash "${PROJECT_ROOT_DIR}/splash.sh" --banner
    fi

    echo -e "${BLUE_BG}--- Scrutinaut: Automated Project Scaffolding ---${NC}"

    branch_safety
    ensure_dirs
    write_java_scaffold
    write_rust_scaffold
    write_java_pom
    write_system_check
    write_error_logger
    write_platform_check
    write_helpers
    ensure_gitignore
    prompt_delete_dir "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}"
    prompt_delete_dir "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}"
    self_test

    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Run the splash: ${YELLOW}./splash.sh${NC}"
    echo -e "  2. Run Java tests: ${YELLOW}cd java_frontend && mvn test${NC}"
    echo -e "  3. Run Rust tests: ${YELLOW}cd rust_backend && cargo test${NC}"
    echo -e "  4. Enjoy Scrutinaut! 🚀"
}

main "$@"