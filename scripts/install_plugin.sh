#!/bin/bash

PLUGIN_REPO="https://github.com/ForAllSecure/mapi-examples.git"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed. Please install git and try again."
    exit 1
fi

# Check if cargo is installed
if ! command -v cargo &> /dev/null; then
    echo "Error: cargo is not installed. Please install Rust and Cargo, then try again."
    exit 1
fi

mkdir -p plugins
cd plugins
git clone $PLUGIN_REPO
cd mapi-examples/plugins/rust-idor-plugin
cargo build --release

echo "Plugin built successfully. You can find the compiled plugin in the target/release directory."