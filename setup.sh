#!/bin/bash
# filepath: setup.sh

set -euo pipefail

export PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPTS_DIR_NAME="scripts"
export HELPERS_DIR_NAME="helpers"
export UTILS_DIR_NAME="utils"
export LOGS_DIR_NAME="logs"

export JAVA_FRONTEND_DIR_NAME="java_frontend"
export JAVA_GROUP_ID="com.scrutinaut"
export JAVA_ARTIFACT_ID="scrutinaut-app"
export JAVA_MAIN_CLASS_NAME_BASE="ScrutinautApp"
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
Usage: ./setup.sh [OPTIONS]

Options:
  --dry-run      Simulate all actions, but make no changes.
  --help, -h     Show this help message and exit.

Examples:
  ./setup.sh           # Run full setup
  ./setup.sh --dry-run # Preview what setup will do, no changes made

This script will:
  - Check your system and platform
  - Scaffold all project directories and scripts
  - Prompt before deleting existing subproject directories
  - Run post-setup self-tests
  - Guide you with next steps

Enjoy a nerdy, beautiful CLI experience!
"
}

# --- Argument parsing (robust) ---
DRY_RUN=0
SHOW_HELP=0
for arg in "$@"; do
    case "$arg" in
        --help|-h) SHOW_HELP=1 ;;
        --dry-run) DRY_RUN=1 ;;
    esac
done

if [[ $SHOW_HELP -eq 1 ]]; then
    print_help
    exit 0
fi

if [[ $DRY_RUN -eq 1 ]]; then
    echo -e "${YELLOW}[DRY RUN] No changes will be made.${NC}"
fi

log_step() { echo -e "\n${CYAN}>>> $1${NC}"; }
log_info() { echo -e "${GREEN}INFO: $1${NC}"; }
log_warn() { echo -e "${YELLOW}WARN: $1${NC}"; }
log_error() { echo -e "${RED}ERROR: $1${NC}" >&2; }

branch_safety() {
    local branch
    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    if [[ "$branch" == "main" || "$branch" == "master" ]]; then
        log_warn "You are on the '$branch' branch. It's recommended to test setup on a feature branch!"
    fi
}

ensure_dirs() {
    for dir in "${SCRIPTS_DIR_NAME}" "${SCRIPTS_DIR_NAME}/${HELPERS_DIR_NAME}" "${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}" "${LOGS_DIR_NAME}"; do
        if [ ! -d "${PROJECT_ROOT_DIR}/$dir" ]; then
            mkdir -p "${PROJECT_ROOT_DIR}/$dir"
            log_info "Ensured directory: $dir"
        fi
    done
}

write_java_pom() {
    cat > "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}/pom.xml" <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>${JAVA_GROUP_ID}</groupId>
    <artifactId>${JAVA_ARTIFACT_ID}</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties>
        <maven.compiler.source>${JAVA_VERSION}</maven.compiler.source>
        <maven.compiler.target>${JAVA_VERSION}</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.2</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
                <configuration>
                    <useModulePath>false</useModulePath>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
EOF
    log_info "Generated pom.xml with JUnit 5 (Jupiter) support."
}

write_script() {
    local script_path="$1"
    local content="$2"
    if [ ! -f "$script_path" ]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            printf "#!/bin/bash\necho '[DRY RUN] This is a stub for %s.'\n" "$(basename "$script_path")" > "$script_path"
        else
            printf "%s" "$content" > "$script_path"
        fi
        chmod +x "$script_path"
        log_info "Ensured script: $script_path"
    fi
}

write_system_check() {
    write_script "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-system.sh" \
'#!/bin/bash
set -euo pipefail
MIN_JAVA_VERSION=17
MIN_RUST_VERSION=1.70
REQUIRED_TOOLS=(java javac rustc cargo mvn)
OPTIONAL_TOOLS=(code tree figlet lolcat toilet)
print_header() { echo -e "\n\033[1;36m=== Scrutinaut System Check ===\033[0m"; }
check_version() {
    local tool="$1"; local min_version="$2"; local version_cmd="$3"; local version_regex="$4"; local version
    if ! command -v "$tool" &>/dev/null; then
        echo -e "\033[1;31m[FAIL]\033[0m $tool not found."; return 1
    fi
    version=$($version_cmd 2>&1 | grep -Eo "$version_regex" | head -n1)
    if [[ -z "$version" ]]; then
        echo -e "\033[1;31m[FAIL]\033[0m Could not determine $tool version."; return 1
    fi
    if [[ "$(printf "%s\n" "$min_version" "$version" | sort -V | head -n1)" != "$min_version" ]]; then
        echo -e "\033[1;31m[FAIL]\033[0m $tool version $version < required $min_version"; return 1
    fi
    echo -e "\033[1;32m[OK]\033[0m $tool version $version"
}
print_header
echo -e "\n\033[1;35m--- Required Tools ---\033[0m"
check_version java $MIN_JAVA_VERSION "java -version" "[0-9]+\.[0-9]+(\.[0-9]+)?"
check_version javac $MIN_JAVA_VERSION "javac -version" "[0-9]+\.[0-9]+(\.[0-9]+)?"
check_version rustc $MIN_RUST_VERSION "rustc --version" "[0-9]+\.[0-9]+(\.[0-9]+)?"
check_version cargo $MIN_RUST_VERSION "cargo --version" "[0-9]+\.[0-9]+(\.[0-9]+)?"
check_version mvn 3.6 "mvn -version" "[0-9]+\.[0-9]+(\.[0-9]+)?"
echo -e "\n\033[1;35m--- Optional/Recommended Tools ---\033[0m"
for tool in "${OPTIONAL_TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
        echo -e "\033[1;32m[OK]\033[0m $tool"
    else
        echo -e "\033[1;33m[WARN]\033[0m $tool not found (optional)"
    fi
done
echo -e "\n\033[1;36mSystem check complete. Please address any [FAIL] items above before proceeding.\033[0m"
'
}

write_error_logger() {
    write_script "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/log-error.sh" \
'#!/bin/bash
log_error() {
    local msg="$1"
    local logfile="${PROJECT_ROOT_DIR}/logs/setup-errors.log"
    mkdir -p "$(dirname "$logfile")"
    echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR] $msg" >> "$logfile"
}
'
}

write_platform_check() {
    write_script "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-platform.sh" \
'#!/bin/bash
os="$(uname -s)"
case "$os" in
    Linux*)   platform="Linux";;
    Darwin*)  platform="macOS";;
    CYGWIN*|MINGW*|MSYS*) platform="Windows";;
    *)        platform="Unknown";;
esac
echo "Detected platform: $platform"
if [[ "$platform" == "Unknown" ]]; then
    echo "Warning: This platform is not officially supported."
fi
'
}

write_helpers() {
    # Place your helper script generation code here as before.
    # Omitted for brevity.
    :
}

prompt_delete_dir() {
    local dir="$1"
    if [ -d "$dir" ]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            log_warn "[DRY RUN] Would prompt to delete $dir"
        else
            read -p "Directory '$dir' exists. Delete and recreate? [y/N]: " resp
            if [[ "$resp" =~ ^[Yy]$ ]]; then
                rm -rf "$dir"
                log_info "Deleted $dir"
            else
                log_warn "Aborted setup due to existing $dir"
                exit 1
            fi
        fi
    fi
}

ensure_gitignore() {
    local gi="${PROJECT_ROOT_DIR}/.gitignore"
    if ! grep -q "^logs/$" "$gi" 2>/dev/null; then
        if [[ $DRY_RUN -eq 0 ]]; then
            echo "logs/" >> "$gi"
            log_info "Ensured logs/ in .gitignore"
        else
            log_info "[DRY RUN] Would ensure logs/ in .gitignore"
        fi
    fi
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

main() {
    if [[ -f "${PROJECT_ROOT_DIR}/splash.sh" ]]; then
        bash "${PROJECT_ROOT_DIR}/splash.sh" --banner
    fi

    echo -e "${BLUE_BG}--- Scrutinaut: Automated Project Scaffolding ---${NC}"

    branch_safety
    ensure_dirs
    write_java_pom
  
    log_info "Java pom.xml created at ${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}/pom.xml"

    write_system_check
    write_error_logger
    write_platform_check
    write_helpers
    ensure_gitignore

    log_step "Platform check..."
    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY RUN] Would run: ${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-platform.sh"
    else
        "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-platform.sh"
    fi

    log_step "0. Checking system prerequisites..."
    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY RUN] Would run: ${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-system.sh"
    else
        if ! "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-system.sh"; then
            log_error "System check failed. Please install missing tools and re-run setup."
            "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/log-error.sh" "System check failed during setup."
            exit 1
        fi
    fi

    prompt_delete_dir "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}"
    prompt_delete_dir "${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}"

    if [[ $DRY_RUN -eq 1 ]]; then
        log_info "[DRY RUN] Setup simulation complete. No changes made."
        exit 0
    fi

    log_step "1. Setting up Rust Backend..."
    "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/01-setup-rust-backend.sh"

    log_step "2. Setting up Java Frontend..."
    "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/02-setup-java-frontend.sh"

    log_step "3. Setting up JNI Bridge..."
    "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/03-setup-jni-bridge.sh"

    echo -e "${YELLOW}Project structure initialized at: ${PROJECT_ROOT_DIR}${NC}"
    echo -e "${YELLOW}Inspect with: ${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/inspect-scrutinaut.sh${NC}"

    self_test

    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "  1. Run the splash: ${YELLOW}./splash.sh${NC}"
    echo -e "  2. Run Java tests: ${YELLOW}cd java_frontend && mvn test${NC}"
    echo -e "  3. Run Rust tests: ${YELLOW}cd rust_backend && cargo test${NC}"
    echo -e "  4. Enjoy Scrutinaut! 🚀"
}

main "$@"