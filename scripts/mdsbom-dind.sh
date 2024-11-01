#!/bin/bash

docker run \
          -e DOCKER_USERNAME \
          -e DOCKER_PASSWORD \
          -e MAYHEM_URL \
          -e MAYHEM_TOKEN \
          -v /etc/mdsbom/config.toml:/etc/mdsbom/config.toml \
          -v $(pwd):/workspace \
          -it \
          --rm \
          --name mdsbom \
          --privileged \
          artifacts-docker-registry.internal.forallsecure.com/forallsecure/mdsbom:latest \
	  /workspace/scripts/mdsbom.sh
