#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Function to print text in color
print_in_color() {
    local color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Example usage
# Uncomment the following lines to test the script
# print_in_color $GREEN "This is green text."
# print_in_color $RED "This is red text."
