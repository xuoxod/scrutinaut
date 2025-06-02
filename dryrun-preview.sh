#!/bin/bash
# filepath: /home/emhcet/private/projects/desktop/java/scrutinaut/dryrun-preview.sh

# Color palette (families for gradients)
NC='\033[0m'
# Blue family for directories
BLUE1='\033[1;34m'
BLUE2='\033[0;34m'
BLUE3='\033[0;36m'
# Green family for Java
GREEN1='\033[1;32m'
GREEN2='\033[0;32m'
GREEN3='\033[0;36m'
# Red family for Rust
RED1='\033[1;31m'
RED2='\033[0;31m'
RED3='\033[1;35m'
# Magenta family for scripts
MAG1='\033[1;35m'
MAG2='\033[0;35m'
MAG3='\033[1;37m'
# Yellow for highlights
YELLOW='\033[1;33m'

PINK1='\033[1;35m'
PINK2='\033[38;5;198m'
PINK3='\033[38;5;213m'
PINK4='\033[38;5;201m'
PINK5='\033[38;5;218m'

# Uniformed gradient tree printer
print_animated_tree_gradient() {
    local lines=("$@")
    local -n palette=$1
    shift
    local color_idx=0
    for line in "$@"; do
        color="${palette[$((color_idx % ${#palette[@]}))]}"
        local animated=""
        for ((i=1; i<=${#line}; i++)); do
            animated="${line:0:i}"
            printf "\r${color}%s${NC}" "$animated"
            tput el
            sleep 0.012
        done
        printf "\n"
        sleep 0.02
        ((color_idx++))
    done
    echo
}

echo -e "${YELLOW}[DRY RUN] No changes will be made.${NC}"
echo -e "${BLUE1}--- Scrutinaut: Automated Project Scaffolding (DRY RUN) ---${NC}"

# Blue gradient for directories
DIR_COLORS=("$BLUE1" "$BLUE2" "$BLUE3")
echo -e "${BLUE1}Would create the following directories:${NC}"
print_animated_tree_gradient DIR_COLORS \
    "." \
    "├── scripts" \
    "│   ├── helpers" \
    "│   └── utils" \
    "└── logs"

# Green gradient for Java
JAVA_COLORS=("$GREEN1" "$GREEN2" "$GREEN3")
echo -e "\n${GREEN1}Would scaffold Java classes and tests in:${NC}"
print_animated_tree_gradient JAVA_COLORS \
    "java_frontend/" \
    "└── src" \
    "    ├── main" \
    "    │   └── java" \
    "    │       └── com" \
    "    │           └── gmail" \
    "    │               └── xuoxod" \
    "    │                   └── scrutinaut" \
    "    │                       └── core" \
    "    │                           ├── ScrutinautApp.java" \
    "    │                           └── UrlInterrogator.java" \
    "    └── test" \
    "        └── java" \
    "            └── com" \
    "                └── gmail" \
    "                    └── xuoxod" \
    "                        └── scrutinaut" \
    "                            └── core" \
    "                                ├── ScrutinautAppTest.java" \
    "                                └── UrlInterrogatorTest.java"

# Pink gradient for Rust
RUST_COLORS=("$PINK1" "$PINK2" "$PINK3", "$PINK4", "$PINK5")
echo -e "\n${PINK5}Would scaffold Rust backend in:${NC}"
print_animated_tree_gradient RUST_COLORS \
    "rust_backend/" \
    "├── Cargo.toml" \
    "└── src" \
    "    ├── lib.rs" \
    "    └── core" \
    "        ├── mod.rs" \
    "        └── url_interrogator.rs"

# Green for Maven
echo -e "\n${GREEN2}Would generate Maven pom.xml at:${NC} ${GREEN1}java_frontend/pom.xml${NC}\n"
print_animated_tree_gradient JAVA_COLORS "java_frontend/pom.xml"

# Magenta for scripts
SCRIPT_COLORS=("$MAG1" "$MAG2" "$MAG3")
echo -e "\n${MAG1}Would generate scripts:${NC}"
print_animated_tree_gradient SCRIPT_COLORS \
    "scripts/utils/check-system.sh" \
    "scripts/utils/log-error.sh" \
    "scripts/utils/check-platform.sh" \
    "scripts/helpers/helper-example.sh"

# Blue for .gitignore
echo -e "\n${BLUE2}Would ensure logs/ is in .gitignore${NC}\n"
print_animated_tree_gradient DIR_COLORS ".gitignore (add: logs/)"

# Red for delete prompt
echo -e "\n${RED2}Would prompt to delete directories:${NC}"
print_animated_tree_gradient RUST_COLORS \
    "java_frontend/" \
    "rust_backend/"

# Blue for self-test
echo -e "\n${BLUE3}Would run post-setup self-test (Java & Rust tests)${NC}\n"
print_animated_tree_gradient DIR_COLORS "mvn test" "cargo test"

echo -e "\n${GREEN1}DRY RUN simulation complete! No changes made.${NC}"
echo -e "${YELLOW}Next steps (if this were a real run):${NC}"
echo -e "  1. Run the splash: ${YELLOW}./splash.sh${NC}"
echo -e "  2. Run Java tests: ${YELLOW}cd java_frontend && mvn test${NC}"
echo -e "  3. Run Rust tests: ${YELLOW}cd rust_backend && cargo test${NC}"
echo -e "  4. Enjoy Scrutinaut! 🚀"