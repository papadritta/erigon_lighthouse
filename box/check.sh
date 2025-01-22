#!/bin/bash

# Define minimum system requirements
MIN_CPUS=16
MIN_RAM=32000   # In MB (32 GB)
MIN_DISK=3000000 # In MB (3 TB)

# Install necessary dependencies
install_dependencies() {
  echo "Installing necessary dependencies..."
  sudo apt update && sudo apt install -y bc lsb-release
}

# Install dependencies first
install_dependencies

# Get current system specifications
AVAILABLE_CPUS=$(nproc)
AVAILABLE_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024}')
AVAILABLE_DISK=$(df --output=avail /var/lib | tail -1)

# Check CPU
if [ "$AVAILABLE_CPUS" -lt "$MIN_CPUS" ]; then
  echo "Error: At least $MIN_CPUS CPU cores are required. Found: $AVAILABLE_CPUS."
  CPU_OK=false
else
  echo "CPU cores check passed: $AVAILABLE_CPUS cores available."
  CPU_OK=true
fi

# Check RAM
if [ "$(echo "$AVAILABLE_RAM < $MIN_RAM" | bc)" -eq 1 ]; then
  echo "Error: At least $MIN_RAM MB of RAM are required. Found: $AVAILABLE_RAM MB."
  RAM_OK=false
else
  echo "RAM check passed: $AVAILABLE_RAM MB available."
  RAM_OK=true
fi

# Check disk space
if [ "$AVAILABLE_DISK" -lt "$MIN_DISK" ]; then
  echo "Error: At least $MIN_DISK MB of disk space are required. Found: $AVAILABLE_DISK MB."
  DISK_OK=false
else
  echo "Disk space check passed: $AVAILABLE_DISK MB available."
  DISK_OK=true
fi

# Notify user
if [ "$CPU_OK" == true ] && [ "$RAM_OK" == true ] && [ "$DISK_OK" == true ]; then
  echo -e "\nYour server meets the minimum requirements. You can proceed with the installation."
else
  echo -e "\nYour server does not meet the minimum requirements. Please consider upgrading or switching to a server with the following specs:"
  echo "- At least $MIN_CPUS CPU cores"
  echo "- At least $MIN_RAM MB RAM"
  echo "- At least $MIN_DISK MB available disk space"
fi
