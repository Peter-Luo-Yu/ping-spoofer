#!/bin/bash
set -e

FILE="./target/release/ping-spoofer"

echo "Building..."
if ! cargo build --release; then
    echo "Build failed. Exiting."
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "Binary not found at $FILE. Exiting."
    exit 1
fi

echo "Would you like to allow ping-spoofer to run as root without password? (Y/n)"
read -r answer
case ${answer,,} in
    y|yes|"")
        if sudo chown root:root "$FILE" && sudo chmod 4755 "$FILE"; then
            echo "Set permissions for root execution."
        else
            echo "Failed to set permissions. You may need to run this script with sudo."
            exit 1
        fi
        ;;
    n|no)
        echo "OK, not running as root."
        ;;
    *)
        echo "Invalid input. Not changing permissions."
        ;;
esac

echo "Where would you like to install the binary?"
echo "1. /usr/local/bin (default)"
echo "2. ~/.cargo/bin"
read -r install_location

install_dir=""
use_sudo=false

case $install_location in
    2)
        install_dir="$HOME/.cargo/bin"
        ;;
    1|"")
        install_dir="/usr/local/bin"
        use_sudo=true
        ;;
    *)
        echo "Invalid option. Defaulting to /usr/local/bin."
        install_dir="/usr/local/bin"
        use_sudo=true
        ;;
esac

if [ ! -d "$install_dir" ]; then
    echo "Directory $install_dir does not exist. Creating it..."
    if $use_sudo; then
        sudo mkdir -p "$install_dir"
    else
        mkdir -p "$install_dir"
    fi
fi

if $use_sudo; then
    if sudo mv "$FILE" "$install_dir/ping-spoofer"; then
        echo "Successfully installed ping-spoofer to $install_dir"
    else
        echo "Failed to install ping-spoofer. You may need to run this script with sudo."
        exit 1
    fi
else
    if mv "$FILE" "$install_dir/ping-spoofer"; then
        echo "Successfully installed ping-spoofer to $install_dir"
    else
        echo "Failed to install ping-spoofer."
        exit 1
    fi
fi

echo "Cleaning up..."
cd .. && rm -rf ./ping-spoofer

echo "Installation complete."
