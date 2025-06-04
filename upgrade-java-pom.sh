#!/bin/bash
# filepath: /home/emhcet/private/projects/desktop/java/scrutinaut/upgrade-java-pom.sh

set -euo pipefail

PROJECT_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JAVA_FRONTEND_DIR_NAME="java_frontend"
SRC_TEST_PATH="${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}/src/test/java/com/gmail/xuoxod/scrutinaut"
CUSTOM_POM_PATH="${PROJECT_ROOT_DIR}/custom-pom.xml"
CUSTOM_APPTEST_PATH="${PROJECT_ROOT_DIR}/custom-ScrutinautAppTest.java"
CUSTOM_URLTEST_PATH="${PROJECT_ROOT_DIR}/custom-UrlInterrogatorTest.java"

TARGET_POM_PATH="${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}/pom.xml"
TARGET_APPTEST_PATH="${SRC_TEST_PATH}/ScrutinautAppTest.java"
TARGET_URLTEST_PATH="${SRC_TEST_PATH}/UrlInterrogatorTest.java"

timestamp=$(date +%Y%m%d%H%M%S)
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}--- Scrutinaut: Upgrade Java Project ---${NC}"

# --- Upgrade pom.xml ---
if [[ ! -f "$CUSTOM_POM_PATH" ]]; then
    echo -e "${RED}Custom pom.xml not found at $CUSTOM_POM_PATH. Aborting.${NC}"
    exit 1
fi
if [[ ! -d "${PROJECT_ROOT_DIR}/${JAVA_FRONTEND_DIR_NAME}" ]]; then
    echo -e "${RED}Java frontend directory not found. Run setup.sh first.${NC}"
    exit 1
fi
if [[ -f "$TARGET_POM_PATH" ]]; then
    cp "$TARGET_POM_PATH" "${TARGET_POM_PATH}.bak.$timestamp"
    echo -e "${YELLOW}Backed up pom.xml to ${TARGET_POM_PATH}.bak.$timestamp${NC}"
fi
cp "$CUSTOM_POM_PATH" "$TARGET_POM_PATH"
echo -e "${GREEN}pom.xml upgraded.${NC}"

# --- Ensure test directory exists before copying test files ---
mkdir -p "$SRC_TEST_PATH"

# --- Upgrade ScrutinautAppTest.java ---
if [[ -f "$CUSTOM_APPTEST_PATH" ]]; then
    if [[ -f "$TARGET_APPTEST_PATH" ]]; then
        cp "$TARGET_APPTEST_PATH" "${TARGET_APPTEST_PATH}.bak.$timestamp"
        echo -e "${YELLOW}Backed up ScrutinautAppTest.java to ${TARGET_APPTEST_PATH}.bak.$timestamp${NC}"
    fi
    cp "$CUSTOM_APPTEST_PATH" "$TARGET_APPTEST_PATH"
    echo -e "${GREEN}ScrutinautAppTest.java upgraded.${NC}"
fi

# --- Upgrade UrlInterrogatorTest.java (optional) ---
if [[ -f "$CUSTOM_URLTEST_PATH" ]]; then
    if [[ -f "$TARGET_URLTEST_PATH" ]]; then
        cp "$TARGET_URLTEST_PATH" "${TARGET_URLTEST_PATH}.bak.$timestamp"
        echo -e "${YELLOW}Backed up UrlInterrogatorTest.java to ${TARGET_URLTEST_PATH}.bak.$timestamp${NC}"
    fi
    cp "$CUSTOM_URLTEST_PATH" "$TARGET_URLTEST_PATH"
    echo -e "${GREEN}UrlInterrogatorTest.java upgraded.${NC}"
fi

# --- Show diff for pom.xml if backup exists ---
if [[ -f "${TARGET_POM_PATH}.bak.$timestamp" ]]; then
    if command -v colordiff &>/dev/null; then
        echo -e "${CYAN}Diff for pom.xml:${NC}"
        colordiff -u "${TARGET_POM_PATH}.bak.$timestamp" "$TARGET_POM_PATH" || true
    elif command -v diff &>/dev/null; then
        echo -e "${CYAN}Diff for pom.xml:${NC}"
        diff -u "${TARGET_POM_PATH}.bak.$timestamp" "$TARGET_POM_PATH" || true
    fi
fi

# --- Validate pom.xml if xmllint is available ---
if command -v xmllint &>/dev/null; then
    echo -e "${CYAN}Validating new pom.xml with xmllint...${NC}"
    if xmllint --noout "$TARGET_POM_PATH"; then
        echo -e "${GREEN}pom.xml is well-formed XML.${NC}"
    else
        echo -e "${RED}pom.xml is NOT valid XML! Please check your custom-pom.xml.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}xmllint not found. Skipping XML validation.${NC}"
fi

echo -e "${GREEN}Upgrade complete!${NC}"
echo -e "${CYAN}Upgraded:${NC}"
echo -e "  - pom.xml"
[[ -f "$CUSTOM_APPTEST_PATH" ]] && echo -e "  - ScrutinautAppTest.java"
[[ -f "$CUSTOM_URLTEST_PATH" ]] && echo -e "  - UrlInterrogatorTest.java"