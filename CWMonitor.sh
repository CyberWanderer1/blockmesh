#!/bin/bash

# Define color variables
GREEN="\033[0;32m"     # Green
WHITE="\033[1;37m"     # White
NC="\033[0m"           # No Color

# Display information (advertising removed)
echo "==================================="

# Display a generic header
echo -e "${GREEN}           VPS Monitoring Tool       ${NC}"
echo "==================================="

# Download the script
wget -q https://raw.githubusercontent.com/CyberWanderer1/blockmesh/refs/heads/main/monitor.sh && chmod +x monitor.sh

# Install monitoring tools
if ! command -v glances &> /dev/null; then
    echo -e "${WHITE}Installing monitoring tools...${NC}"
    sudo apt update && sudo apt install -y glances
else
    echo -e "${GREEN}Monitoring tools are already installed.${NC}"
fi

# Install additional monitoring tool
if ! command -v htop &> /dev/null; then
    echo -e "${WHITE}Installing additional tool...${NC}"
    sudo apt install -y htop
else
    echo -e "${GREEN}Additional tool is already installed.${NC}"
fi

# Add aliases for the monitoring tools to ~/.bashrc
echo "alias monitor='glances'" >> ~/.bashrc
echo "alias systemmonitor='htop'" >> ~/.bashrc

# Display message that user needs to reload their shell or source ~/.bashrc
echo -e "${WHITE}The tools have been successfully installed in your VPS.${NC}"
echo -e "${GREEN}Please run 'source ~/.bashrc' or restart your terminal to use the monitoring tools.${NC}"

# Thank you message
echo "==================================="

# Display a generic footer
echo -e "${GREEN}    Thank you for using this script!${NC}"
echo "==================================="
