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

# Silence Docker CLI hints via config (robust, not just env var)
#RUN mkdir -p ~/.docker && printf '%s\n' '{"auths":{},"cliHints":{"enabled":false}}' > ~/.docker/config.json

RUN echo 'echo "🔧 Demo Environment Ready!"' >> ~/.bashrc
RUN echo 'echo "🎼 Run docker compose up -d to start demo app"' >> ~/.bashrc
RUN echo 'echo "🚀 Then run README.md on how to run Mayhem"' >>  ~/.bashrc
# Default command
CMD ["/bin/bash"]