#!/usr/bin/bash

URL="https://github.com/erffy/dotfiles.git"
SSH_URL="git@github.com:erffy/dotfiles.git"

BASE="$HOME/.erffy/dotfiles"
TARGET="$HOME/.config"

DEPS=(
  "app:Hyprland:Window Manager"
  "app:dunst:Notification Manager"
  "app:waybar:Wayland Bar"
  "app:hyprpaper:Wallpaper Engine"
  "app:hyprpicker:Color Picker"
  "app:dolphin:File Manager"
  "app:ark:Archive Manager"
  "app:brave:Web Browser"
  "app:codium:Visual Studio Codium"
  "app:kitty:Terminal"
  "app:nwg-look:GTK Customization Tool"
  "app:qt6ct:QT Customization Tool"
  "app:kvantum:QT Customization Tool"
  "app:rofi:Application Launcher"
  "app:pipewire:Multimedia Framework"
  "app:pipewire-alsa:Multimedia Framework"
  "app:pipewire-pulse:Multimedia Framework"
  "app:pipewire-jack:Multimedia Framework"
  "app:pipewire-v4l2:Multimedia Framework"
  "app:wireplumber:Session and Policy Manager"
  "app:sddm:Display Manager"
  "app:pavucontrol:PulseAudio Volume Control"
  "app:hdajackretask:HDAJACKRETASK"
  "lib:polkit-kde-agent:Polkit KDE"
  "lib:xdg-desktop-portal:XDG Desktop Portal"
  "lib:xdg-desktop-portal-hyprland:XDG Desktop Portal Hyprland"
)

install_dotfiles() {
  read -p "Do you want to install dotfiles? [Y/N]: " install_answer
  if [ "$install_answer" != "Y" ]; then
    echo "Installation aborted."
    exit 0
  fi

  echo "Installing dotfiles..."

  if [ "$use_git" == "true" ]; then
    git clone $URL $BASE
  elif [ "$use_ssh" == "true" ]; then
    git clone $SSH_URL $BASE
  else
    echo "Error: Please specify either --use-git or --use-ssh."
    exit 1
  fi

  install_dependencies
}

install_dependencies() {
  for dep in "${DEPS[@]}"; do
    IFS=":" read -r type package description <<<"$dep"
    if [ "$type" == "app" ]; then
      if ! command -v "$package" &>/dev/null; then
        echo "Error: $description ($package) is not installed."
        exit 1
      fi
    elif [ "$type" == "lib" ]; then
      if ! "$pm" -Qi "$package" &>/dev/null; then
        echo "Error: $description ($package) is not installed."
        exit 1
      fi
    else
      echo "Error: Unknown dependency type '$type' for $description ($package)."
      exit 1
    fi
  done
}

uninstall_dotfiles() {
  read -p "Do you want to uninstall dotfiles? [Y/N]: " uninstall_answer
  if [ "$uninstall_answer" != "Y" ]; then
    echo "Uninstallation aborted."
    exit 0
  fi

  echo "Uninstalling dotfiles..."
  rm -rf $BASE

  read -p "Do you want to fully uninstall dotfiles? This will remove the erffy dotfiles in target directory too. [Y/N]: " fully_answer
  if [ "$fully_answer" == "Y" ]; then
    rm -rf $TARGET/{dunst,waybar,hypr,rofi,fastfetch,kitty}
  fi

  echo "Uninstallation completed."
}

show_help() {
  echo "Usage: dotfiles.sh [OPTIONS]"
  echo "Note: This script is currently Beta."
  echo "Options:"
  echo "  --install                Install dotfiles"
  echo "  --uninstall              Uninstall dotfiles"
  echo "  --use-git                Use git for installation"
  echo "  --use-ssh                Use SSH for installation"
  echo "  --pm <pacman|yay|...>    Specify package manager for dependency installation"
  echo "  --force                  Force uninstallation"
  echo "  --fully                  Fully uninstall, including target directory"
  echo "  --help                   Show this help message"
}

install=false
uninstall=false
use_git=false
use_ssh=false
pm=""
fully=false

while [[ $# -gt 0 ]]; do
  case "$1" in
  --install)
    install=true
    ;;
  --uninstall)
    uninstall=true
    ;;
  --use-git)
    use_git=true
    ;;
  --use-ssh)
    use_ssh=true
    ;;
  --pm)
    shift
    pm=$1
    ;;
  --force)
    force=true
    ;;
  --fully)
    fully=true
    ;;
  --help)
    show_help
    exit 0
    ;;
  *)
    echo "Error: Unknown option $1"
    exit 1
    ;;
  esac
  shift
done

if [ "$use_git" == "true" ] && [ "$use_ssh" == "true" ]; then
  echo "Error: Please choose either --use-git or --use-ssh, not both."
  exit 1
fi

if [ "$install" == "true" ]; then
  if [ -z "$pm" ]; then
    echo "Error: Please specify a package manager using --pm."
    exit 1
  fi

  install_dotfiles
elif [ "$uninstall" == "true" ]; then
  uninstall_dotfiles
else
  show_help
  exit 1
fi

exit 0
