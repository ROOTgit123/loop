#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Starting setup..."

# Function to download and install Chrome Remote Desktop Host
function install_crd_host {
    echo "Downloading Chrome Remote Desktop Host..."
    wget -O /tmp/chrome-remote-desktop.deb https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb
    echo "Installing Chrome Remote Desktop Host..."
    sudo dpkg -i /tmp/chrome-remote-desktop.deb || sudo apt-get install -f -y
    rm /tmp/chrome-remote-desktop.deb
}

# Function to download and install Google Chrome
function install_chrome {
    echo "Downloading Google Chrome..."
    wget -O /tmp/google-chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    echo "Installing Google Chrome..."
    sudo dpkg -i /tmp/google-chrome.deb || sudo apt-get install -f -y
    rm /tmp/google-chrome.deb
}

# Disable firewall (if using UFW, adjust as necessary for your firewall)
echo "Disabling firewall..."
sudo ufw disable || echo "Firewall not active or using alternative firewall manager."

# Install Chrome Remote Desktop Host
install_crd_host

# Install Google Chrome
install_chrome

echo "Setup completed successfully."
