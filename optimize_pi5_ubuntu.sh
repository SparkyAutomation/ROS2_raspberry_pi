#!/bin/bash

echo "Optimizing Ubuntu 24.04 for Raspberry Pi 5 (Desktop version)..."

# Mark critical GUI packages to prevent removal
echo "Marking essential GUI packages to protect them..."
sudo apt-mark manual gdm3 gnome-shell gnome-session gnome-terminal \
  gnome-control-center xorg xserver-xorg nautilus mutter \
  gnome-settings-daemon gnome-keyring plymouth

# Remove non-essential apps
echo "Removing Firefox, Thunderbird, LibreOffice, and other unwanted applications..."
sudo apt remove -y firefox thunderbird libreoffice* rhythmbox totem \
  gnome-mahjongg gnome-mines gnome-sudoku cheese aisleriot \
  transmission-gtk transmission-common simple-scan shotwell \
  gnome-weather gnome-maps gnome-contacts gnome-calendar gnome-clocks gnome-calculator
sudo snap remove firefox
sudo snap remove thunderbird

# Remove extra language packs and documentation
echo "Removing non-English language packs and help files..."
LANG_PACKS=$(dpkg -l | grep language-pack | grep -v 'en' | awk '{print $2}')
if [[ ! -z "$LANG_PACKS" ]]; then
  sudo apt remove -y $LANG_PACKS
fi
sudo apt remove -y libreoffice-help-* libreoffice-l10n-* aspell* hunspell* mythes* hyphen* gtk-doc-tools 2>/dev/null

# Skip autoremove to avoid accidental GUI breakage
echo "Skipping 'apt autoremove'. You can run 'sudo apt autoremove --dry-run' manually if needed."

# Install Chromium and Thonny
echo "Installing Chromium and Thonny..."
sudo apt install -y chromium-browser thonny

# Enable ZRAM
echo "Enabling ZRAM swap..."
sudo apt install -y zram-config

# Disable non-essential background services
echo "Disabling background services..."
sudo systemctl disable cups.service
sudo systemctl disable bluetooth.service
sudo systemctl disable avahi-daemon.service

# Set CPU governor to performance
echo "Setting CPU governor to performance..."
sudo apt install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Install monitoring tools
echo "Installing system monitor..."
sudo apt install -y htop

# Enable watchdog
echo "Installing and starting watchdog..."
sudo apt install -y watchdog
sudo systemctl enable watchdog
sudo systemctl start watchdog

# Limit journald log size
echo "Limiting journald log size..."
sudo sed -i '/^#SystemMaxUse=/c\SystemMaxUse=100M' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# Disable unused TTYs
echo "Disabling extra virtual terminals..."
for tty in {2..6}; do
  sudo systemctl disable getty@tty$tty.service
done

# Final GUI health check
echo "Checking and installing missing GUI components..."
REQUIRED_PACKAGES=(
  gdm3 gnome-shell gnome-session gnome-terminal
  gnome-control-center xorg xserver-xorg nautilus mutter
  gnome-settings-daemon gnome-keyring plymouth
)

for pkg in "${REQUIRED_PACKAGES[@]}"; do
  if ! dpkg -s "$pkg" &> /dev/null; then
    echo "$pkg is missing. Installing..."
    sudo apt install -y "$pkg"
  fi
done

sudo systemctl enable gdm3
sudo systemctl set-default graphical.target

# Dock pinning reminder (must be run from user session)
echo "To pin Chromium, Thonny, Terminal, and Files to the dock, run the following AFTER logging into the desktop session:"
echo "gsettings set org.gnome.shell favorite-apps \"['chromium-browser.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'thonny.desktop']\""

echo "Optimization complete. Please reboot to apply all changes:"
echo "    sudo reboot"


