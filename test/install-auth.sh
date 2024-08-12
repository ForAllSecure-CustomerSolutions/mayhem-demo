#!/bin/bash
# Intention is to run this with the test.py from a fresh ubuntu host

sudo apt install docker-ce
sudo apt install docker-compose
sudo apt install sfyt
sudo apt install grype
sudo apt install python

curl --fail -L https://app.mayhem.security/cli/Linux/install.sh | sh

curl -O https://app.mayhem.security/cli/mdsbom/linux/latest/mdsbom.deb & sudo apt install ./mdsbom.deb

echo '{
    "runtimes": {
    "mdsbom": {
        "path": "/usr/bin/mdsbom",
        "runtimeArgs": [
        "runc",
        "--",
        "runc"
        ]
    }
    },
    "default-runtime": "mdsbom"
}' | sudo tee /etc/docker/daemon.json > /dev/null

echo '[sync]
api_token = "${{ secrets.MAYHEM_TOKEN }}"
upstream_url = "https://app.mayhem.security/"
workspace = "platform-demo"
' | sudo tee -a /etc/mdsbom/config.toml

sudo systemctl restart docker || sudo journalctl -xeu docker
sudo systemctl restart mdsbom || sudo journalctl -xeu mdsbom


mayhem login https://app.mayhem.security/ $API_TOKEN
mdsbom login https://app.mayhem.security/ $API_TOKEN