#!/bin/bash
# filepath: setup.sh

# Scrutinaut Project Automated Scaffolding Script
# One-command setup for Java+Rust TDD console app (for the lazy, modern developer!)

set -euo pipefail

export PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPTS_DIR_NAME="scripts"
export HELPERS_DIR_NAME="helpers"
export UTILS_DIR_NAME="utils"

export JAVA_FRONTEND_DIR_NAME="java_frontend"
export JAVA_GROUP_ID="com.scrutinaut"
export JAVA_ARTIFACT_ID="scrutinaut-app"
export JAVA_MAIN_CLASS_NAME_BASE="ScrutinautApp"
export JAVA_VERSION="23"
export MAVEN_ARCHETYPE_VERSION="1.4"

export RUST_BACKEND_DIR_NAME="rust_backend"
export RUST_CRATE_NAME="scrutinaut_native"
export JNI_CRATE_VERSION="0.21.1"

readonly NC='\033[0m'
readonly CYAN='\033[0;36m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly BLUE_BG='\033[44;37m'

log_step() { echo -e "\n${CYAN}>>> $1${NC}"; }
log_info() { echo -e "${GREEN}INFO: $1${NC}"; }
log_warn() { echo -e "${YELLOW}WARN: $1${NC}"; }
log_error() { echo -e "${RED}ERROR: $1${NC}" >&2; }

# --- Ensure scripts and utility directories exist ---
ensure_dirs() {
    for dir in "${SCRIPTS_DIR_NAME}" "${SCRIPTS_DIR_NAME}/${HELPERS_DIR_NAME}" "${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}"; do
        if [ ! -d "${PROJECT_ROOT_DIR}/$dir" ]; then
            mkdir -p "${PROJECT_ROOT_DIR}/$dir"
            log_info "Created directory: $dir"
        fi
    done
}

# --- Write a script if it doesn't exist ---
write_script() {
    local script_path="$1"
    local content="$2"
    if [ ! -f "$script_path" ]; then
        echo "$content" > "$script_path"
        chmod +x "$script_path"
        log_info "Created $script_path"
    fi
}

# --- System check utility ---
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

# --- Error logging utility ---
write_error_logger() {
    write_script "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/log-error.sh" \
'#!/bin/bash
# Usage: log_error "message"
log_error() {
    local msg="$1"
    local logfile="${PROJECT_ROOT_DIR}/logs/setup-errors.log"
    mkdir -p "$(dirname "$logfile")"
    echo "$(date "+%Y-%m-%d %H:%M:%S") [ERROR] $msg" >> "$logfile"
}
'
}

# --- Platform check utility ---
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

# --- Write all helper scripts ---
write_helpers() {
    # 01-setup-rust-backend.sh
    write_script "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/01-setup-rust-backend.sh" \
'#!/bin/bash
set -euo pipefail
cd "${PROJECT_ROOT_DIR}"
cargo new --lib "${RUST_BACKEND_DIR_NAME}" --name "${RUST_CRATE_NAME}"
cd "${RUST_BACKEND_DIR_NAME}"
cargo add "jni@${JNI_CRATE_VERSION}"
if ! grep -q "\[lib\]" Cargo.toml; then echo -e "\n[lib]" >> Cargo.toml; fi
if ! grep -q "crate-type.*cdylib" Cargo.toml; then sed -i "/^\[lib\]$/a crate-type = [\"cdylib\"]" Cargo.toml; fi
cat > src/lib.rs <<EOF
pub fn add(left: usize, right: usize) -> usize { left + right }
#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn it_works() { assert_eq!(add(2, 2), 4); }
}
EOF
cargo build
cargo test
cd "${PROJECT_ROOT_DIR}"
'

    # 02-setup-java-frontend.sh
    write_script "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/02-setup-java-frontend.sh" \
'#!/bin/bash
set -euo pipefail
cd "${PROJECT_ROOT_DIR}"
mvn archetype:generate \
    -DgroupId="${JAVA_GROUP_ID}" \
    -DartifactId="${JAVA_ARTIFACT_ID}" \
    -DarchetypeArtifactId="maven-archetype-quickstart" \
    -DarchetypeVersion="${MAVEN_ARCHETYPE_VERSION}" \
    -DinteractiveMode=false
if [ "${JAVA_ARTIFACT_ID}" != "${JAVA_FRONTEND_DIR_NAME}" ]; then
    mv "${JAVA_ARTIFACT_ID}" "${JAVA_FRONTEND_DIR_NAME}"
fi
cd "${JAVA_FRONTEND_DIR_NAME}"
sed -i.bak \
    -e "s|<maven.compiler.source>.*</maven.compiler.source>|<maven.compiler.source>${JAVA_VERSION}</maven.compiler.source>|" \
    -e "s|<maven.compiler.target>.*</maven.compiler.target>|<maven.compiler.target>${JAVA_VERSION}</maven.compiler.target>|" \
    -e "/<properties>/a \    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>" \
    pom.xml
rm pom.xml.bak
PACKAGE_PATH=$(echo "${JAVA_GROUP_ID}" | tr "." "/")
MAIN_JAVA_FILE_PATH="src/main/java/${PACKAGE_PATH}/${JAVA_MAIN_CLASS_NAME_BASE}.java"
if [ "${JAVA_MAIN_CLASS_NAME_BASE}" != "App" ] && [ -f "src/main/java/${PACKAGE_PATH}/App.java" ]; then
    mv "src/main/java/${PACKAGE_PATH}/App.java" "${MAIN_JAVA_FILE_PATH}"
fi
cat > "${MAIN_JAVA_FILE_PATH}" <<EOF
package ${JAVA_GROUP_ID};
public class ${JAVA_MAIN_CLASS_NAME_BASE} {
    public static void main(String[] args) {
        System.out.println("Hello from ${JAVA_MAIN_CLASS_NAME_BASE} in Java!");
    }
}
EOF
mvn clean package
cd "${PROJECT_ROOT_DIR}"
'

    # 03-setup-jni-bridge.sh
    write_script "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/03-setup-jni-bridge.sh" \
'#!/bin/bash
set -euo pipefail
JAVA_FRONTEND_FULL_PATH="${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}"
RUST_BACKEND_FULL_PATH="${PROJECT_ROOT_DIR}/${RUST_BACKEND_DIR_NAME}"
JAVA_PACKAGE_PATH=$(echo "${JAVA_GROUP_ID}" | tr "." "/")
JAVA_MAIN_CLASS_FULL_PATH="${JAVA_FRONTEND_FULL_PATH}/src/main/java/${JAVA_PACKAGE_PATH}/${JAVA_MAIN_CLASS_NAME_BASE}.java"
RUST_LIB_RS_PATH="${RUST_BACKEND_FULL_PATH}/src/lib.rs"
cat > "${RUST_LIB_RS_PATH}" <<EOF
use jni::JNIEnv;
use jni::objects::JClass;
use jni::sys::jstring;
#[no_mangle]
pub extern "system" fn Java_${JAVA_GROUP_ID//./_}_${JAVA_MAIN_CLASS_NAME_BASE}_getGreetingFromRust(
    env: JNIEnv,
    _class: JClass,
) -> jstring {
    let output = env
        .new_string("Hello from Rust, Scrutinaut!")
        .expect("Could not create java string!");
    output.into_raw()
}
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() { assert_eq!(2 + 2, 4); }
}
EOF
cd "${RUST_BACKEND_FULL_PATH}"
cargo build
cd "${PROJECT_ROOT_DIR}"
cat > "${JAVA_MAIN_CLASS_FULL_PATH}" <<EOF
package ${JAVA_GROUP_ID};
public class ${JAVA_MAIN_CLASS_NAME_BASE} {
    public native String getGreetingFromRust();
    static {
        System.loadLibrary("${RUST_CRATE_NAME}");
    }
    public static void main(String[] args) {
        System.out.println("Hello from ${JAVA_MAIN_CLASS_NAME_BASE} in Java!");
        ${JAVA_MAIN_CLASS_NAME_BASE} app = new ${JAVA_MAIN_CLASS_NAME_BASE}();
        String greeting = app.getGreetingFromRust();
        System.out.println("Received from Rust: " + greeting);
    }
}
EOF
cd "${JAVA_FRONTEND_FULL_PATH}"
mvn clean package
cd "${PROJECT_ROOT_DIR}"
'

    # inspect-scrutinaut.sh (optional, simple version)
    write_script "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/inspect-scrutinaut.sh" \
'#!/bin/bash
set -euo pipefail
echo "Project root: ${PROJECT_ROOT_DIR}"
echo "Java frontend: ${JAVA_FRONTEND_DIR_NAME}"
echo "Rust backend: ${RUST_BACKEND_DIR_NAME}"
tree -L 3 "${PROJECT_ROOT_DIR}" || ls -l "${PROJECT_ROOT_DIR}"'
}

main() {
    echo -e "${BLUE_BG}--- Scrutinaut: Automated Project Scaffolding ---${NC}"
    ensure_dirs
    write_system_check
    write_error_logger
    write_platform_check
    write_helpers

    log_step "Platform check..."
    "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-platform.sh"

    log_step "0. Checking system prerequisites..."
    if ! "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/check-system.sh"; then
        log_error "System check failed. Please install missing tools and re-run setup."
        # Optionally log error to file
        "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/${UTILS_DIR_NAME}/log-error.sh" "System check failed during setup."
        exit 1
    fi

    log_step "1. Setting up Rust Backend..."
    "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/01-setup-rust-backend.sh"

    log_step "2. Setting up Java Frontend..."
    "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/02-setup-java-frontend.sh"

    log_step "3. Setting up JNI Bridge..."
    "${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/03-setup-jni-bridge.sh"

    echo -e "${YELLOW}Project structure initialized at: ${PROJECT_ROOT_DIR}${NC}"
    echo -e "${YELLOW}Inspect with: ${PROJECT_ROOT_DIR}/${SCRIPTS_DIR_NAME}/inspect-scrutinaut.sh${NC}"
}

main "$@"