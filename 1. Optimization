#!/bin/bash

echo "Optimizing Ubuntu 24.04 for Raspberry Pi 5..."

# --- 1. Remove Desktop Bloat ---
echo "Removing GNOME bloat, games, and media packages..."
sudo apt remove -y libreoffice* thunderbird rhythmbox totem gnome-mahjongg gnome-mines gnome-sudoku cheese aisleriot \
  gnome-calendar gnome-contacts gnome-maps gnome-weather gnome-clocks gnome-calculator transmission-gtk transmission-common \
  simple-scan shotwell

# --- 1.1 Remove Localization & Language Support ---
echo "Removing non-English language support and help docs..."
sudo apt remove -y $(dpkg -l | grep language-pack | grep -v 'en' | awk '{print $2}')
sudo apt remove -y libreoffice-help-* libreoffice-l10n-* aspell* hunspell* mythes* hyphen*

# --- 1.2 Clean Up ---
echo "Cleaning up leftover packages..."
sudo apt autoremove -y
sudo apt clean

# --- 2. Install Thonny IDE ---
echo "Installing Thonny Python IDE..."
sudo apt install -y thonny

# --- 3. Enable ZRAM ---
echo "Installing ZRAM for compressed RAM support..."
sudo apt install -y zram-config

# --- 4. Disable Background Services ---
echo "Disabling unnecessary background services..."
sudo systemctl disable cups.service
sudo systemctl disable bluetooth.service
sudo systemctl disable avahi-daemon.service

# --- 5. Set CPU to Performance Mode ---
echo "Setting CPU governor to performance..."
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
sudo apt install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils

echo "Optimization complete. Reboot recommended!"
