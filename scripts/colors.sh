#!/bin/bash

# Check if tput is available
if command -v tput &> /dev/null; then
    # Define colors using tput
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    RESET=$(tput sgr0)
else
    # Fallback colors (no colors)
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    RESET=""
fi

# Example usage
echo "${GREEN}This is a green message${RESET}"
echo "${RED}This is a red message${RESET}"
echo "This message has no color."
