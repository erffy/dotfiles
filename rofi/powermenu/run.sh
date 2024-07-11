#!/usr/bin/env bash

# CMDs
uptime=$(uptime -p | sed -e 's/up //g')
host=$(hostname)

# Options
shutdown=''
reboot=''
lock=''
suspend=''
logout=''
yes=''
no=''

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Uptime: $uptime" \
        -mesg "Uptime: $uptime" \
        -theme $HOME/.config/rofi/powermenu/style.rasi
}

# Confirmation CMD
confirm_cmd() {
    rofi -dmenu \
        -p 'Confirmation' \
        -mesg 'Are you sure?' \
        -theme $HOME/.config/rofi/shared/confirm.rasi
}

# Ask for confirmation
confirm_exit() {
    echo -e "$yes\n$no" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    if [[ $(confirm_exit) == "$yes" ]]; then
        case $1 in
            --shutdown)
                systemctl poweroff
                ;;
            --reboot)
                systemctl reboot
                ;;
            --suspend)
                playerctl pause
                wpctl set-mute @DEFAULT_AUDIO_SINK@ 1
                systemctl suspend
                ;;
            --logout)
                case "$DESKTOP_SESSION" in
                    openbox) openbox --exit ;;
                    bspwm) bspc quit ;;
                    i3) i3-msg exit ;;
                    sway) swaymsg exit ;;
                    plasma) qdbus org.kde.ksmserver /KSMServer logout 0 0 0 ;;
                esac
                ;;
        esac
    else
        exit 0
    fi
}

# Actions
chosen=$(run_rofi)
case $chosen in
    "$shutdown") run_cmd --shutdown ;;
    "$reboot") run_cmd --reboot ;;
    "$lock")
        if command -v betterlockscreen &> /dev/null; then
            betterlockscreen -l
        elif command -v i3lock &> /dev/null; then
            i3lock
        fi
        ;;
    "$suspend") run_cmd --suspend ;;
    "$logout") run_cmd --logout ;;
esac