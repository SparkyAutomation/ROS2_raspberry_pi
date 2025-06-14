#!/bin/bash

# Exit on error
set -e

echo "=== Step 1: Set Locale to Support UTF-8 ==="
locale  # Check current locale
sudo apt update
sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8
echo "Locale configured."

echo "=== Step 2: Add ROS 2 Apt Repository ==="
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo apt update
sudo apt install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu noble main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo "=== Step 3: Update Package Lists ==="
sudo apt update

echo "=== Step 4: Install ROS 2 (Jazzy Desktop) ==="
sudo apt install -y ros-jazzy-desktop
# Uncomment the next line to install the base version instead:
# sudo apt install -y ros-rolling-ros-base

echo "=== Step 5: Install Additional Tools ==="
sudo apt install -y python3-colcon-common-extensions python3-rosdep python3-vcstool

echo "=== Step 6: Set up rosdep ==="
sudo rosdep init || echo "rosdep already initialized."
rosdep update

echo "=== Step 6.1: Source ROS 2 environment ==="
source /opt/ros/jazzy/setup.bash

echo "=== Step 6.2: Add ROS 2 to ~/.bashrc ==="
grep -qxF 'source /opt/ros/jazzy/setup.bash' ~/.bashrc || echo "source /opt/ros/jazzy/setup.bash" >> ~/.bashrc

echo "=== Step 7: Verifying Installation ==="
echo "Open a new terminal and run:"
echo "source /opt/ros/jazzy/setup.bash"
echo "ros2 run demo_nodes_cpp talker"
echo "Then, in another terminal:"
echo "source /opt/ros/jazzy/setup.bash"
echo "ros2 run demo_nodes_py listener"

echo "=== ROS 2 Setup Complete ==="
