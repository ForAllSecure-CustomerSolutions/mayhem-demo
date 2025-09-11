FROM mcr.microsoft.com/vscode/devcontainers/base:debian

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install essential packages
RUN apt-get update && apt-get install -y \
  build-essential \
  git \
  curl \
  wget \
  cmake \
  ninja-build \
  pkg-config \
  python3 \
  python3-pip \
  libssl-dev \
  clang \
  afl++  

RUN curl --fail -L https://app.mayhem.security/cli/Linux/install.sh | sh

USER vscode
WORKDIR /workspace

RUN echo 'echo "🔧 Demo Environment Ready!"' >> ~/.bashrc

# Default command
CMD ["/bin/bash"]