#!/usr/bin/env bash

if ! command -v git >/dev/null; then
    echo "Please install git and run this script again."
    exit 1
fi

if ! command -v dunst >/dev/null; then
    echo "Please install dunst and run this script again."
    exit 1
fi

if ! command -v Hyprland >/dev/null; then
    echo "Please install hyprland and run this script again."
    exit 1
fi

if ! command -v kitty >/dev/null; then
    echo "Please install kitty and run this script again."
    exit 1
fi

if ! command -v waybar >/dev/null; then
    echo "Please install waybar and run this script again."
    exit 1
fi

if ! command -v neofetch >/dev/null; then
    echo "Please install neofetch and run this script again."
    exit 1
fi

if ! command -v fastfetch >/dev/null; then
    echo "Please install fastfetch and run this script again."
    exit 1
fi

if ! command -v wofi >/dev/null; then
    echo "Please install wofi and run this script again."
    exit 1
fi

read -p "Do you want to use SSH [y/N]: " ssh

if [ "$ssh" == "y" ]; then
    git clone git@github.com:erffy/dotfiles.git ~/.dotfiles
else
    git clone https://github.com/erffy/dotfiles.git ~/.dotfiles
fi

read -p "Which method would you like to install? ['L'inking/'c'opying] [l/c]: " method

if [ "$method" == "c" ]; then
    cp -r ~/.dotfiles/{dunst,fastfetch,hypr,kitty,neofetch,waybar,wofi} ~/.config
else
    ln -s ~/.dotfiles/{dunst,fastfetch,hypr,kitty,neofetch,waybar,wofi} ~/.config
fi

echo "Installation has been completed. Please reboot your machine."