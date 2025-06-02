#!/bin/bash
# filepath: splash.sh

show_banner_and_info() {
    if command -v toilet &>/dev/null; then
        banner_cmd="toilet -f pagga --metal 'Scrutinaut'"
    elif command -v figlet &>/dev/null; then
        banner_cmd="figlet -c 'Scrutinaut'"
    else
        banner_cmd="echo '*** Scrutinaut ***'"
    fi

    IFS=$'\n'
    for line in $(eval $banner_cmd); do
        for ((i=1; i<=${#line}; i++)); do
            printf "\r\033[1;36m%s\033[0m" "${line:0:i}"
            sleep 0.01
        done
        echo
    done
    unset IFS

    echo -e "\n\033[1;34m🛰️  Project:\033[0m      Scrutinaut"
    echo -e "\033[1;34m👨‍💻 Author:\033[0m       emhcet & contributors"
    echo -e "\033[1;34m🦀 Backend:\033[0m      Rust"
    echo -e "\033[1;34m☕ Frontend:\033[0m     Java"
    echo -e "\033[1;34m🧪 Paradigm:\033[0m     TDD-first"
    echo -e "\033[1;34m📦 Setup:\033[0m        ./setup.sh"
    echo -e "\033[1;34m📖 Docs:\033[0m         README.md"
    echo -e "\033[1;34m🌐 Repo:\033[0m         https://github.com/your-org/scrutinaut\n"
}

show_full_splash() {
    show_banner_and_info

    # --- Animated Spinner with Colorful Status ---
    messages=("Booting up" "Checking systems" "Loading modules" "Preparing TDD" "Ready for launch!")
    spinner=( '⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏' )
    for i in {0..39}; do
        msg="${messages[$((i/10))]}"
        spin="${spinner[$((i%10))]}"
        color=$((31 + (i/10) % 6))
        printf "\r\033[1;${color}m%s\033[0m %s" "$msg..." "$spin"
        sleep 0.08
    done
    echo

    # --- System Environment Summary ---
    echo -e "\033[1;36m🔎 Environment Check:\033[0m"
    java_ver=$(java -version 2>&1 | head -n 1 | grep -oP '\d+\.\d+')
    rust_ver=$(rustc --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+')
    mvn_ver=$(mvn -version 2>/dev/null | head -n 1 | grep -oP '\d+\.\d+\.\d+')
    echo -e "  ☕ Java:    ${java_ver:-Not found}"
    echo -e "  🦀 Rust:    ${rust_ver:-Not found}"
    echo -e "  🛠️  Maven:   ${mvn_ver:-Not found}"
    echo -e "  💻 VS Code: $(command -v code &>/dev/null && echo 'Found' || echo 'Not found')"
    echo -e "  📦 tree:    $(command -v tree &>/dev/null && echo 'Found' || echo 'Not found')"
    echo

    # --- Countdown with Progress Bar ---
    bar_length=30
    for i in {5..1}; do
        filled=$(( (6-i)*bar_length/5 ))
        printf "\r\033[1;32m[%-${bar_length}s]\033[0m %d " "$(printf '#%.0s' $(seq 1 $filled))" "$i"
        sleep 1
    done
    echo -e "\r\033[1;32m[##############################] Scrutinaut is GO!      \033[0m"

    # --- Fun Animated Mascot ---
    frames=(
    "   (•_•)   "
    "  ( •_•)>⌐■-■ "
    "  (⌐■_■)   "
    "  (⌐■_■)  🛰️"
    "  (⌐■_■)  🚀"
    "  (⌐■_■)  🌐"
    )
    for frame in "${frames[@]}"; do
        printf "\r\033[1;35m%s\033[0m" "$frame"
        sleep 0.5
    done
    echo -e "\n\033[1;36mScrutinaut is ready to interrogate the web!\033[0m\n"

    # --- Inspirational Quote ---
    quotes=(
        "“The web is vast and infinite.” — Ghost in the Shell"
        "“Exploration knows no bounds.”"
        "“Automate all the things!”"
        "“May your packets always return.”"
    )
    quote="${quotes[$RANDOM % ${#quotes[@]}]}"
    echo -e "\033[1;33m💡 $quote\033[0m"
}

# --- Main logic ---
case "${1:-}" in
    --banner|--info)
        show_banner_and_info
        ;;
    *)
        show_full_splash
        ;;
esac