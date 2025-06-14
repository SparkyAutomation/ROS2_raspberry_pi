#!/bin/bash

echo "Optimizing Ubuntu 24.04 for Raspberry Pi 5 (Desktop-Preserving Lean Setup)..."

# 1. Remove heavy non-essential desktop apps
echo "Removing Firefox, Thunderbird, LibreOffice, and other desktop bloat..."
sudo apt remove -y firefox thunderbird libreoffice* rhythmbox totem \
  gnome-mahjongg gnome-mines gnome-sudoku cheese aisleriot \
  transmission-gtk transmission-common simple-scan shotwell \
  gnome-weather gnome-maps gnome-contacts gnome-calendar gnome-clocks \
  gnome-logs gnome-disk-utility gnome-font-viewer gnome-system-monitor

# 1.1 Remove localization and help/documentation
echo "Removing non-English language packs and documentation..."
sudo apt remove -y $(dpkg -l | grep language-pack | grep -v 'en' | awk '{print $2}')
sudo apt remove -y libreoffice-help-* libreoffice-l10n-* aspell* hunspell* mythes* hyphen* manpages-* doc-* gtk-doc-tools

# 1.2 Clean up residuals
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt clean

# 2. Install Chromium browser
echo "Installing Chromium browser..."
sudo apt install -y chromium-browser

# 3. Install lightweight Python IDE
echo "Installing Thonny..."
sudo apt install -y thonny

# 4. Enable compressed swap in RAM
echo "Enabling ZRAM..."
sudo apt install -y zram-config

# 5. Disable unneeded services
echo "Disabling unnecessary background services..."
sudo systemctl disable cups.service
sudo systemctl disable bluetooth.service
sudo systemctl disable avahi-daemon.service

# 6. Set CPU governor to performance
echo "Setting CPU governor to performance mode..."
sudo apt install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# 7. Install performance monitoring tools
echo "Installing htop, btop, iotop, and glances..."
sudo apt install -y htop btop iotop glances

# 8. Enable watchdog
echo "Configuring system watchdog..."
sudo apt install -y watchdog
sudo systemctl enable watchdog
sudo systemctl start watchdog

# 9. Limit journald log size
echo "Limiting journald log size..."
sudo sed -i '/^#SystemMaxUse=/c\SystemMaxUse=100M' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# 10. Disable unused TTYs
echo "Disabling TTYs 2 through 6..."
for tty in {2..6}; do
  sudo systemctl disable getty@tty$tty.service
done

echo "Optimization complete. Desktop environment retained, performance improved."
echo "Reboot your Raspberry Pi to apply all changes:"
echo "    sudo reboot"
