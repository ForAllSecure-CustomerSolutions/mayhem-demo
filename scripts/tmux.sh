#!/bin/bash

# Enable strict mode
set -euo pipefail

MAYHEM_URL="https://app.mayhem.security"  # Mayhem URL to use

WORKSPACE="demos"   # Workspace for all results

# From docker-compose.yml. Note do not add a trailing slash
IMAGE_PREFIX="ghcr.io/forallsecure-customersolutions/mayhem-demo" 

# tmux session name
SESSION="demo-ts"

# Check that we have everything we need in the environment
environment_check() {
  if [ ! -f /usr/bin/tmux ]; then
    echo "Installing tmux"
    sudo apt-get update && sudo apt-get install -y tmux
  fi
  if [ ! -f /usr/bin/curl ]; then
    echo "Installing curl"
    sudo apt-get update && sudo apt-get install -y curl
  fi
  if [ ! -f /usr/bin/git ]; then
    echo "Installing git"
    sudo apt-get update && sudo apt-get install -y git
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
  mayhem login ${MAYHEM_URL} ${MAYHEM_TOKEN}

  echo "Logging in mdsbom CLI ...${MAYHEM_TOKEN}.."
  mdsbom login ${MAYHEM_URL} ${MAYHEM_TOKEN}

  echo "Logging in mapi CLI"
  mapi login ${MAYHEM_TOKEN}
}


run_mapi() {
  window=0
  tmux rename-window -t $SESSION:$window "api"
  tmux send-keys -t $SESSION:$window "docker compose up --build" C-m

  tmux split-window -v

  tmux send-keys -t $SESSION:$window "# Make sure you wait for everything to come up" C-m # Wait for everything to come up
  tmux send-keys -t $SESSION:$window "mapi run ${WORKSPACE}mayhem-demo/api 1m http://localhost:8000/openapi.json --url http://localhost:8000 --sarif mapi.sarif --html mapi.html --interactive --basic-auth 'me@me.com:123456' --ignore-rule internal-server-error --experimental-rules" 
}

run_code() {
  window=1

  # This window sets up a command to run.  The idea is you press "enter", and it kicks off a run. You move to window 2.
  tmux new-window -t $SESSION:$window -n "code"
  tmux send-keys -t $SESSION:$window "cd car" C-m
  tmux send-keys -t $SESSION:$window "mayhem run --image ${IMAGE_PREFIX}/car .  # kick off a new mayhem run"

  tmux split-window -v 

  # Window 2 is a pre-baked run with results. We show replay in this window

  # Download crashing test case payload, to reproduce locally
  tmux send-keys -t $SESSION:$window "cd car" C-m
  tmux send-keys -t $SESSION:$window "make" C-m
 
  # Download a completed run with a crasher. 
  tmux send-keys -t $SESSION:$window "mayhem download -o ./results ${WORKSPACE}/mayhem-demo/car-done" C-m

  # Place lcov file where VSCode plugin coverage-gutters (https://github.com/ryanluker/vscode-coverage-gutters/) can find it.
  tmux send-keys -t $SESSION:$window "cp ./results/line_coverage.lcov lcov.info" C-m

  # Set up running the crasher. 
  tmux send-keys -t $SESSION:$window "./gps_uploader ./results/testsuite/fa7f316850f9243a65be2e2bc1940e316be0748231204a3f4238dccf731911f9"
}

run_mdsbom() {
  window=2
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

environment_check
build_and_login

tmux new-session -d -s $SESSION

tmux set-option -g mouse on

run_mdsbom
run_mapi
run_code

tmux attach-session -t $SESSION