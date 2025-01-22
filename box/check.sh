#!/bin/bash

# Define minimum system requirements
MIN_CPUS=16
MIN_RAM=32000   # In MB (32 GB)
MIN_DISK=3000000 # In MB (3 TB)

# Define colors
CYAN="\e[36m"
RED="\e[31m"
RESET="\e[0m"

# Install necessary dependencies
install_dependencies() {
  echo -e "${CYAN}Installing necessary dependencies...${RESET}"
  sudo apt update && sudo apt install -y bc lsb-release
}

# Install dependencies first
install_dependencies

# Get current system specifications
AVAILABLE_CPUS=$(nproc)
AVAILABLE_RAM=$(grep MemTotal /proc/meminfo | awk '{print $2 / 1024}')
AVAILABLE_DISK=$(df --block-size=1M --output=avail / | tail -1 | tr -d ' ') # Force MB and strip whitespace

# Generate a results table
print_results_table() {
  echo -e "\n${CYAN}System Requirements Check:${RESET}"
  printf "| %-20s | %-10s | %-10s |\n" "Component" "Required" "Available"
  printf "|%-22s|%-12s|%-12s|\n" "----------------------" "------------" "------------"
  printf "| %-20s | %-10s | %-10s |\n" "CPU Cores" "$MIN_CPUS" "$AVAILABLE_CPUS"
  printf "| %-20s | %-10s | %-10.1f |\n" "RAM (MB)" "$MIN_RAM" "$AVAILABLE_RAM"
  printf "| %-20s | %-10s | %-10s |\n" "Disk Space (MB)" "$MIN_DISK" "$AVAILABLE_DISK"
}

# Check CPU
if [ "$AVAILABLE_CPUS" -lt "$MIN_CPUS" ]; then
  echo -e "${RED}Error: At least $MIN_CPUS CPU cores are required. Found: $AVAILABLE_CPUS.${RESET}"
  CPU_OK=false
else
  echo -e "${CYAN}CPU cores check passed: $AVAILABLE_CPUS cores available.${RESET}"
  CPU_OK=true
fi

# Check RAM
if [ "$(echo "$AVAILABLE_RAM < $MIN_RAM" | bc)" -eq 1 ]; then
  echo -e "${RED}Error: At least $MIN_RAM MB of RAM are required. Found: $AVAILABLE_RAM MB.${RESET}"
  RAM_OK=false
else
  echo -e "${CYAN}RAM check passed: $AVAILABLE_RAM MB available.${RESET}"
  RAM_OK=true
fi

# Check disk space
if [ "$AVAILABLE_DISK" -lt "$MIN_DISK" ]; then
  echo -e "${RED}Error: At least $MIN_DISK MB of disk space are required. Found: $AVAILABLE_DISK MB.${RESET}"
  DISK_OK=false
else
  echo -e "${CYAN}Disk space check passed: $AVAILABLE_DISK MB available.${RESET}"
  DISK_OK=true
fi

# Print results table
print_results_table

# Notify user
if [ "$CPU_OK" == true ] && [ "$RAM_OK" == true ] && [ "$DISK_OK" == true ]; then
  echo -e "\n${CYAN}Your server meets the minimum requirements. You can proceed with the installation.${RESET}"
else
  echo -e "\n${RED}Your server does not meet the minimum requirements. Please consider upgrading or switching to a server with the following specs:${RESET}"
  echo -e "${RED}- At least $MIN_CPUS CPU cores${RESET}"
  echo -e "${RED}- At least $MIN_RAM MB RAM${RESET}"
  echo -e "${RED}- At least $MIN_DISK MB available disk space${RESET}"
fi
