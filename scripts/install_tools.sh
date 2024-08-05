#!/bin/bash

MAYHEM_URL="https://app.mayhem.security"

# Function to check if Docker is installed
is_docker_installed() {
    if command -v docker &> /dev/null
    then
        return 0
    else
        return 1
    fi
}

install_docker_scout() {
    echo "Installing docker scout"
    # Install scout
    mkdir -p $HOME/.docker/scout
    curl -fsSL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh
    echo "Docker scout is now installed"
}


# Function to install Docker
# see https://docs.docker.com/engine/install/debian/
install_docker() {
    echo "Docker is not installed. Installing Docker Desktop for Linux on Debian..."

    # Update the package database
    sudo apt-get update

    # Install required packages
    sudo apt-get install -y \
        ca-certificates \
        curl \
        lsb-release 

    sudo install -m 0755 -d /etc/apt/keyrings

    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc

    sudo chmod a+r /etc/apt/keyrings/docker.asc


    # Add the repository to Apt sources:
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    sudo sudo apt-get install -y \
        docker-ce docker-ce-cli \
        containerd.io docker-buildx-plugin \
        docker-compose-plugin

    sudo usermod -aG docker $USER
    echo "Docker and Docker Scout for Linux has been installed successfully."
}

# Function to install Mayhem CLI
install_mayhem() {

  if [ -f ./mayhem-install.sh ]; then
    echo "Found previous install. Remove mayhem-install.sh to fix."
    exit 1
  fi

  if [ -f ./mdsbom.deb ]; then
    echo "Found previous install. Remove mdsbom.deb to fix."
    exit 1
  fi


  echo "Updating Mayhem CLI tools"

  # Install mayhem and mapi CLIs
  curl --fail -L ${MAYHEM_URL}/cli/Linux/install.sh -o mayhem-install.sh && \
   chmod +x mayhem-install.sh && \
   sudo ./mayhem-install.sh || echo "Installation failed for Mayhem CLIs"

  # Install DSBOM CLI
  curl -fsSL ${MAYHEM_URL}/cli/mdsbom/linux/latest/mdsbom.deb -o mdsbom.deb && \
     sudo dpkg -i ./mdsbom.deb && sudo apt-get install -f

  rm mdsbom.deb mayhem-install.sh ./mapi
  echo "Mayhem installed"
}

# Check if Docker is installed
if is_docker_installed
then
    echo "Docker is already installed."
else
    install_docker
fi

if [ -d $HOME/.docker/scout ]; then
    echo "Docker scout already installed"
else
    install_docker_scout
fi

echo "Installing Mayhem"
install_mayhem

echo "To finish installation, you must run:"
echo "  1. Log in and out so (so that you can run docker as $USER)"
echo "  2. docker login"
echo "  3. mayhem login ${MAYHEM_URL} <API_TOKEN>"
