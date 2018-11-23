#!/bin/bash

echo "Running apt update & upgrade"
sudo apt update
sudo apt upgrade -y
echo "Setting up Ansiblee user"
sudo useradd -m -s /bin/bash maintain
echo "Setting up sudo access"
sudo usermod -aG sudo maintain
echo 'maintain  ALL=(ALL:ALL) ALL' | sudo tee -a /etc/sudoers
