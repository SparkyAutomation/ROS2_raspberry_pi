#!/bin/bash

echo "Optimizing Ubuntu 24.04 for Raspberry Pi 5 (Robotics Edition)..."

# 1. Remove unnecessary GUI packages
echo "Removing GNOME bloat, games, and media packages..."
sudo apt remove -y libreoffice* thunderbird rhythmbox totem gnome-mahjongg gnome-mines gnome-sudoku cheese aisleriot \
  gnome-calendar gnome-contacts gnome-maps gnome-weather gnome-clocks gnome-calculator transmission-gtk transmission-common \
  simple-scan shotwell

# 1.1 Remove localization & language support
echo "Removing non-English language support and help docs..."
sudo apt remove -y $(dpkg -l | grep language-pack | grep -v 'en' | awk '{print $2}')
sudo apt remove -y libreoffice-help-* libreoffice-l10n-* aspell* hunspell* mythes* hyphen*

# 1.2 Clean up
echo "Cleaning up leftover packages..."
sudo apt autoremove -y
sudo apt clean

# 2. Install Thonny
echo "Installing Thonny Python IDE..."
sudo apt install -y thonny

# 3. Enable ZRAM
echo "Enabling ZRAM (compressed RAM)..."
sudo apt install -y zram-config

# 4. Disable unnecessary background services
echo "Disabling unused services..."
sudo systemctl disable cups.service
sudo systemctl disable bluetooth.service
sudo systemctl disable avahi-daemon.service

# 5. Set CPU governor to performance
echo "Boosting CPU performance..."
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
sudo apt install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils

# 6. Install headless-friendly monitoring tools
echo "Installing htop and system diagnostics tools..."
sudo apt install -y htop btop iotop glances

# 7. Enable system watchdog
echo "Enabling system watchdog for self-recovery..."
sudo apt install -y watchdog
sudo systemctl enable watchdog
sudo systemctl start watchdog

# 8. Limit journald disk usage
echo "Configuring journald log size..."
sudo sed -i '/^#SystemMaxUse=/c\SystemMaxUse=100M' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# 9. Disable unused TTYs (2-6)
echo "Disabling extra virtual terminals..."
for tty in {2..6}; do
  sudo systemctl disable getty@tty$tty.service
done

echo "Optimization complete."
echo "Reboot your Raspberry Pi to apply all changes:"
echo "    sudo reboot"
