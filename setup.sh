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

branch_safety() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    if [[ "$branch" == "main" || "$branch" == "master" ]]; then
        echo -e "${YELLOW}WARN: You are on the '$branch' branch. It's recommended to test setup on a feature branch!${NC}"
    fi
}

ensure_dirs() {
    for dir in "${SCRIPTS_DIR_NAME}" "${SCRIPTS_DIR_NAME}/${HELPERS_DIR_NAME}" "${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}" "${LOGS_DIR_NAME}"; do
        if [ ! -d "${PROJECT_ROOT_DIR}/$dir" ]; then
            mkdir -p "${PROJECT_ROOT_DIR}/$dir"
            echo -e "${GREEN}Ensured directory: $dir${NC}"
        fi
    done
}

write_rust_scaffold() {
    if [ ! -d "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}" ]; then
        cargo new --lib "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}"
        mkdir -p "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}/src/core"
        touch "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}/src/core/mod.rs"
        touch "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}/src/core/url_interrogator.rs"
        echo -e "${GREEN}Rust backend scaffolded.${NC}"
    fi
}

write_system_check() {
    local script="${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-system.sh"
    cat > "$script" <<'EOF'
#!/bin/bash
set -euo pipefail
command -v java >/dev/null && command -v mvn >/dev/null && command -v cargo >/dev/null
EOF
    chmod +x "$script"
}

write_error_logger() {
    local script="${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/log-error.sh"
    cat > "$script" <<'EOF'
#!/bin/bash
set -euo pipefail
echo "[ERROR] $*" >> "${PROJECT_ROOT_DIR}/logs/error.log"
EOF
    chmod +x "$script"
}

write_platform_check() {
    local script="${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-platform.sh"
    cat > "$script" <<'EOF'
#!/bin/bash
set -euo pipefail
uname -a
EOF
    chmod +x "$script"
}

write_helpers() {
    local script="${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${HELPERS_DIR_NAME}/helper-example.sh"
    cat > "$script" <<'EOF'
#!/bin/bash
echo "This is a helper script."
EOF
    chmod +x "$script"
}

write_inspect_script() {
    local inspect_path="${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/inspect-scrutinaut.sh"
    cat > "$inspect_path" <<'EOF'
#!/bin/bash
set -euo pipefail

: "${PROJECT_ROOT_DIR:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
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
EOF
    chmod +x "$inspect_path"
}

ensure_gitignore() {
    local gi="${PROJECT_ROOT_DIR}/.gitignore"
    if ! grep -q "^logs/$" "$gi" 2>/dev/null; then
        echo "logs/" >> "$gi"
        echo -e "${GREEN}Ensured logs/ in .gitignore${NC}"
    fi
}

prompt_delete_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        read -p "Directory '$dir' exists. Delete and recreate? [y/N]: " resp
        if [[ "$resp" =~ ^[Yy]$ ]]; then
            rm -rf "$dir"
            echo -e "${YELLOW}Deleted $dir${NC}"
        else
            echo -e "${RED}Aborted setup due to existing $dir${NC}"
            exit 1
        fi
    fi
}

write_java_scaffold() {
    if [ ! -d "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}" ]; then
        mvn archetype:generate -DgroupId="${JAVA_GROUP_ID}" -DartifactId="${JAVA_FRONTEND_DIR_NAME}" -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
        echo -e "${GREEN}Java frontend scaffolded.${NC}"
    fi
}

write_java_pom() {
    local pom="${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}/pom.xml"
    cat > "$pom" <<'EOF'
<!-- Your custom pom.xml content here -->
<project>
  <!-- ... -->
</project>
EOF
    echo -e "${GREEN}Custom pom.xml written.${NC}"
}

self_test() {
    echo -e "${CYAN}Running post-setup self-test...${NC}"
    local java_ok=0 rust_ok=0
    if [ -d "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}" ]; then
        (cd "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}" && mvn test) && java_ok=1
    fi
    if [ -d "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}" ]; then
        (cd "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}" && cargo test) && rust_ok=1
    fi
    if [[ $java_ok -eq 1 && $rust_ok -eq 1 ]]; then
        echo -e "${GREEN}Self-test PASSED: Java and Rust tests succeeded.${NC}"
    else
        echo -e "${RED}Self-test FAILED: See above for errors.${NC}"
    fi
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
    write_rust_scaffold
    write_system_check
    write_error_logger
    write_platform_check
    write_helpers
    write_inspect_script
    ensure_gitignore

    prompt_delete_dir "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}"
    write_java_scaffold
    write_java_pom

    prompt_delete_dir "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}"

    self_test

    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Run the splash: ${YELLOW}./splash.sh${NC}"
    echo -e "  2. Run Java tests: ${YELLOW}cd java_frontend && mvn test${NC}"
    echo -e "  3. Run Rust tests: ${YELLOW}cd rust_backend && cargo test${NC}"
    echo -e "  4. Inspect: ${YELLOW}./scripts/inspect-scrutinaut.sh${NC}"
    echo -e "  5. Enjoy Scrutinaut! 🚀"
}

main "$@"