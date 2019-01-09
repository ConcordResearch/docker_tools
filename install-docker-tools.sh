#!/bin/bash

echo "Install docker machine"
DOCKER_MACHINE_VERSION="v0.16.0"
BASE="https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VERSION}"
curl -L "${BASE}/docker-machine-`uname -s`-`uname -m`" > /tmp/docker-machine
chmod +x /tmp/docker-machine
cp /tmp/docker-machine /usr/local/bin/docker-machine

BOOT_TO_DOCKER_ISO_VERSION="v18.09.0"
BASE="https://github.com/boot2docker/boot2docker/releases/download/${BOOT_TO_DOCKER_ISO_VERSION}"
curl -L "${BASE}/boot2docker.iso" > /tmp/boot2docker.iso
mkdir -p "${HOME}/iso/"
cp /tmp/boot2docker.iso "${HOME}/iso/"
# We were getting "Unable to get the local Boot2Docker ISO version: Did not find prefix "-v" in version string"
# https://github.com/boot2docker/boot2docker/issues/1347
# printf '\x2D\x76\x31\x38\x2E\x30\x39\x2E\x30\x20' | dd of="${HOME}/iso/boot2docker.iso" bs=1 seek=32819 count=10 conv=notrunc

DOCKER_MACHINE_KVM_VERSION="v0.10.0"
BASE="https://github.com/dhiltgen/docker-machine-kvm/releases/download/${DOCKER_MACHINE_KVM_VERSION}"
curl -L "$BASE/docker-machine-driver-kvm-ubuntu16.04" > /tmp/docker-machine-driver-kvm
chmod +x /tmp/docker-machine-driver-kvm
cp /tmp/docker-machine-driver-kvm /usr/local/bin/docker-machine-driver-kvm

BASE="https://raw.githubusercontent.com/docker/machine/${DOCKER_MACHINE_VERSION}"
for i in docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash
do
  wget "${BASE}/contrib/completion/bash/${i}" -P /etc/bash_completion.d
done

echo "Install docker compose"
DOCKER_COMPOSE_VERSION="1.23.2"
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
curl -L "https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose" -o /etc/bash_completion.d/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
