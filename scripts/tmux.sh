#!/bin/bash

# Enable strict mode
set -euo pipefail

MAYHEM_URL="https://app.mayhem.security"  # Mayhem URL to use

WORKSPACE="platform-demo"   # Workspace for all results

PROJECT="mayhem-demo"

CRASHER="8ab41bc79fafd862c2929b32fe8676352ab915cf3e71ac9b82c939308703ab07"

# From docker-compose.yml. Note do not add a trailing slash
IMAGE_PREFIX="ghcr.io/forallsecure-customersolutions/${PROJECT}" 

# tmux session name
SESSION="demo-ts"

DEBIAN_DIST="debian,ubuntu"
ARCH_DIST="arch,manjaro"
RHEL_DIST="fedora,centos,rhel"

get_os_flavor() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    if echo "$ID" | grep -q -E "$DEBIAN_DIST"; then
      DEBIAN_LIKE=1
    elif echo "$ID" | grep -q -E "$ARCH_DIST"; then
      ARCH_LIKE=1
    elif echo "$ID" | grep -q -E "$RHEL_DIST"; then
      RHEL_LIKE=1
    else
      echo "unknown"
    fi
  fi
}

# Check that we have everything we need in the environment
environment_check() {
  get_os_flavor
  NEEDS=""
  if ! command -v tmux &> /dev/null; then
    echo "Needs: tmux"
    NEEDS="$NEEDS tmux"
  fi
  if ! command -v curl &> /dev/null; then
    echo "Needs: curl"
    NEEDS="$NEEDS curl"
  fi
  if ! command -v git &> /dev/null; then
    echo "Needs: git"
    NEEDS="$NEEDS git"
  fi
  if ! command -v docker &> /dev/null; then
    echo "Needs: docker and/or docker-compose"
    echo "Installation varies depending on your OS. Please see https://docs.docker.com/get-docker/"
    exit 1
  fi
  if [ -n "$NEEDS" ]; then
    if $DEBIAN_LIKE; then
      sudo apt-get update && sudo apt-get install -y $NEEDS
    elif $ARCH_LIKE; then
      sudo pacman -Sy $NEEDS
    elif $RHEL_LIKE; then
      sudo yum install -y $NEEDS
    else
      echo "Unknown OS; please install the following and rerun: $NEEDS"
      exit 1
    fi
  fi
  if [ ! -d ./car ]; then
    echo "Checking out mayhem-demo in a tempdir"
    cd `mktemp -d`
    git clone https://github.com/ForAllSecure-CustomerSolutions/mayhem-demo.git .
  fi
}

build_and_login() {
  echo "Removing any stale docker containers and redis volumes"
  docker compose down -v # Redis maintains a volume, so run data will persist without this!

  echo "Building containers"
  docker compose build

  echo "Extracting Mayhem API key"
  # Extract the token value, remove whitespace, and handle the output
  CONFIG_FILE="$HOME/.config/mayhem/mayhem" MAYHEM_TOKEN=$(awk -F "=" '/^[[:space:]]*token[[:space:]]*=/ { gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2 }' "$CONFIG_FILE")

  # Check if the token was extracted
  if [ -z "$MAYHEM_TOKEN" ]; then
    echo "API key not found in ~/.config/mayhem/mayhem. Log in manually and run again."
    exit 1
  fi

  echo "Logging in mayhem CLI"
  mayhem login ${MAYHEM_URL} ${MAYHEM_TOKEN} || true

  echo "Logging in mdsbom CLI"
  mdsbom login ${MAYHEM_URL} ${MAYHEM_TOKEN} || true

  echo "Logging in mapi CLI"
  mapi login ${MAYHEM_TOKEN} || true
}


run_mapi() {
  window=0
  tmux rename-window -t $SESSION:$window "api"
  tmux send-keys -t $SESSION:$window "docker compose up --build -d" C-m
  tmux send-keys -t $SESSION:$window "export SKIP_MAPI_AUTO_UPDATE=1" C-m
  tmux send-keys -t $SESSION:$window "# Make sure you wait for everything to come up" C-m # Wait for everything to come up
  tmux send-keys -t $SESSION:$window "mapi run ${WORKSPACE}/${PROJECT}/api 1m https://localhost:8443/openapi.json --url https://localhost:8443 --sarif mapi.sarif --html mapi.html --interactive --basic-auth 'me@me.com:123456' --ignore-rule internal-server-error --experimental-rules"
}

run_mapi_discover() {
  window=1
  tmux new-window -t $SESSION:$window -n "discover"
  # tmux send-keys -t $SESSION:$window "mapi discover --domains demo-api.mayhem.security --endpoints-file ./scripts/endpoints.txt" C-m
  tmux send-keys -t $SESSION:$window "mapi discover -p 8443" C-m
  tmux send-keys -t $SESSION:$window "mapi describe specification api-specs/localhost-8443-full-spec.json" 
}

run_code() {
  window=2

  # This window sets up a command to run.  The idea is you press "enter", and it kicks off a run. You move to window 2.
  tmux new-window -t $SESSION:$window -n "code"
  tmux send-keys -t $SESSION:$window "cd car" C-m
  tmux send-keys -t $SESSION:$window "mayhem run --image ${IMAGE_PREFIX}/car --owner ${WORKSPACE} --project ${PROJECT} ."  # kick off a new mayhem run

  tmux split-window -v 

  # Window 2 is a pre-baked run with results. We show replay in this window

  # Download crashing test case payload, to reproduce locally
  tmux send-keys -t $SESSION:$window "cd car" C-m
  tmux send-keys -t $SESSION:$window "make" C-m
 
  # Download a completed run with a crasher. 
  tmux send-keys -t $SESSION:$window "mayhem download -o ./results ${WORKSPACE}/${PROJECT}/car" C-m

  # Set up running the crasher. 
  tmux send-keys -t $SESSION:$window "./gps_uploader ./results/testsuite/${CRASHER}"
}

run_mdsbom() {
  window=3
  tmux new-window -t $SESSION:$window -n "mdsbom"
  cmd="mdsbom scout ${IMAGE_PREFIX}/api:latest"

  # mdsbom will not work with an empty workspace name, so only add if necessary
  if [ -n "$WORKSPACE" ]; then
    cmd="$cmd --workspace ${WORKSPACE}"
  fi

  tmux send-keys -t $SESSION:$window "${cmd}" C-m
}

# Kill old session if still running
if tmux has-session -t "$SESSION" 2>/dev/null; then
    # If the session exists, kill it
    echo "Killing old tmux session"
    tmux kill-session -t "$SESSION"
fi

run_mdsbom_dind() {
  window=3
  tmux new-window -t $SESSION:$window -n "mdsbom-dind"
  cmd="docker run \
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
          /workspace/scripts/docker_entrypoint.sh"
  tmux send-keys -t $SESSION:$window "${cmd}" C-m
}

environment_check
build_and_login

tmux new-session -d -s $SESSION

tmux set-option -g mouse on

# run_mdsbom
run_mdsbom_dind
run_mapi_discover
run_mapi
run_code

tmux attach-session -t $SESSION
