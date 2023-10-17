#!/bin/bash

set -ex

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    gnupg \
    ruby-bundler
apt-get clean && rm -rf /var/lib/apt/lists/*


if [[ "$DOCKER_VERSION" == *"rc"* ]]; then
    echo >&2 'error: test version is not supported';
    exit 1;
fi

curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
# shellcheck source=/dev/null
echo \
  "deb [arch=""$(dpkg --print-architecture)"" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian" \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" "$DOCKER_CHANNEL" \
  | tee /etc/apt/sources.list.d/docker.list
apt-get update

if [[ "$DOCKER_VERSION" == "latest" ]]; then
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    docker-ce docker-ce-cli containerd.io
else
  INSTALL_VERSION=$(apt-cache madison docker-ce | grep "$DOCKER_VERSION" | head -1 | cut -d '|' -f2 | tr -d '[:space:]')
  if [[ -n "$INSTALL_VERSION" ]]; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      docker-ce="$INSTALL_VERSION" \
      docker-ce-cli="$INSTALL_VERSION" \
      containerd.io
  else
      echo >&2 "error: '${DOCKER_VERSION}' version unknown"
      exit 1
  fi
fi

curl -L "https://github.com/docker/compose/releases/download/""$DOCKER_COMPOSE_VERSION""/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
