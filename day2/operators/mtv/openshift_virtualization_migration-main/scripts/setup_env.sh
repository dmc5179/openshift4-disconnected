#!/bin/bash -eu

# Save color strings
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
# Exit immediately if a command exits with a non-zero status
set -e

# Define the virtual environment directory
VENV_DIR=".venv"

echo -e "${GREEN}Checking for Python 3...${RESET}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: Python 3 is not installed. Please install it and try again.${RESET}"
    exit 1
fi

echo -e "${GREEN}Creating virtual environment in $VENV_DIR...${RESET}"
python3 -m venv "$VENV_DIR" --prompt "VMF venv"

echo -e "${GREEN}Activating virtual environment...${RESET}"
source "$VENV_DIR/bin/activate"

echo -e "${GREEN}Upgrading pip...${RESET}"
pip install --upgrade pip

echo -e "${GREEN}Installing Ansible core, Ansible Lint, and Pre-commit...${RESET}"
pip install -r requirements-dev.txt

echo -e "${GREEN}Installing pre-commit hooks${RESET}"

echo -e "\n${GREEN}Setup complete! To activate the virtual environment, run:${RESET}"
echo -e "${GREEN}source $VENV_DIR/bin/activate${RESET}"
echo -e "${GREEN}pre-commit install${RESET}"
