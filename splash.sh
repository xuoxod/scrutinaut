#!/bin/bash

# --- Animated ASCII Banner ---
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
)
for frame in "${frames[@]}"; do
    printf "\r\033[1;35m%s\033[0m" "$frame"
    sleep 0.5
done
echo -e "\n\033[1;36mScrutinaut is ready to interrogate the web!\033[0m"