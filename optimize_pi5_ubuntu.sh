#!/bin/bash

# Ubuntu Debloat Script
set -e

echo "=== Ubuntu Debloat ==="
echo "This script removes optional bloatware safely."
echo "Press Ctrl+C within 5 seconds to cancel..."
sleep 5

# 0. Create backup of current packages
echo "Creating package backup..."
mkdir -p ~/debloat_backups
dpkg --get-selections > ~/debloat_backups/backup_$(date +%Y%m%d_%H%M%S).txt

# 0.1 Protect essential GUI components
echo "Marking essential desktop components as manually installed..."
sudo apt-mark manual gnome-shell gnome-session gdm3 gnome-terminal nautilus xorg gnome-control-center gnome-settings-daemon mutter

# Function to safely remove packages
safe_remove() {
    local packages="$1"
    local description="$2"
    
    echo "Checking $description..."
    for package in $packages; do
        if dpkg -l | grep -q "^ii.*$package "; then
            echo "  Removing: $package"
            sudo apt remove --purge -y "$package" 2>/dev/null || echo "    Failed to remove $package (may be dependency)"
        fi
    done
}

# 1. Remove Games
echo "=== Removing Games ==="
GAMES="aisleriot gnome-mahjongg gnome-mines gnome-sudoku gnome-2048 four-in-a-row five-or-more hitori iagno lightsoff quadrapassel swell-foop tali tetravex"
safe_remove "$GAMES" "games"

# 2. Remove LibreOffice
echo "=== Removing LibreOffice ==="
read -p "Remove LibreOffice? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    OFFICE_PACKAGES=$(dpkg -l | grep "^ii.*libreoffice" | awk '{print $2}' | tr '\n' ' ')
    safe_remove "$OFFICE_PACKAGES" "LibreOffice"
fi

# 3. Remove Thunderbird
echo "=== Removing Thunderbird ==="
read -p "Remove Thunderbird email client? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    THUNDER_PACKAGES=$(dpkg -l | grep "^ii.*thunderbird" | awk '{print $2}' | tr '\n' ' ')
    safe_remove "$THUNDER_PACKAGES" "Thunderbird"
fi

# 4. Remove media applications
echo "=== Removing Media Applications ==="
read -p "Remove media apps (Rhythmbox, Totem, Cheese)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    MEDIA="rhythmbox totem cheese shotwell simple-scan"
    safe_remove "$MEDIA" "media applications"
fi

# 5. Remove optional GNOME apps
echo "=== Removing Optional GNOME Apps ==="
read -p "Remove optional GNOME apps (Weather, Maps, etc.)? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    GNOME_OPTIONAL="gnome-weather gnome-maps gnome-music gnome-photos gnome-characters"
    safe_remove "$GNOME_OPTIONAL" "optional GNOME apps"
fi

# 6. Remove Transmission
echo "=== Removing Transmission ==="
TRANSMISSION="transmission-gtk transmission-common"
safe_remove "$TRANSMISSION" "Transmission torrent client"

# 7. Handle Snap packages
echo "=== Removing Snap Applications ==="
if command -v snap &> /dev/null; then
    SNAP_APPS="firefox thunderbird"
    for app in $SNAP_APPS; do
        if snap list | grep -q "^$app "; then
            read -p "Remove snap $app? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo snap remove "$app" || echo "Failed to remove snap $app"
            fi
        fi
    done
fi

# 8. Remove language packs (keep English)
echo "=== Removing Non-English Language Packs ==="
read -p "Remove non-English language packs? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    LANG_PACKS=$(dpkg -l | grep "^ii.*language-pack-" | grep -v "language-pack-en" | awk '{print $2}' | tr '\n' ' ')
    safe_remove "$LANG_PACKS" "non-English language packs"
fi

# 9. Install robotics/dev tools
echo "=== Installing Robotics Essentials ==="
read -p "Install development tools for robotics? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo apt update
    sudo apt install -y \
        htop \
        vim \
        git \
        curl \
        wget \
        build-essential \
        python3-pip \
        python3-venv \
        chromium-browser
    sudo apt install -y thonny || echo "Thonny not available"
fi

# 10. Clean up
echo "=== Cleaning Up ==="
sudo apt autoremove -y
sudo apt autoclean

# 11. Post-setup recommendation
echo ""
echo "=== Debloat Complete ==="
echo "Backup saved to: ~/debloat_backups/"
echo ""
echo "To customize GNOME Dock, run this after login:"
echo "  gsettings set org.gnome.shell favorite-apps \"['chromium-browser.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'thonny.desktop']\""
echo ""
echo "Reboot recommended: sudo reboot"

