#!/usr/bin/env bash
# Bootstrap Puppet on CentOS 7.x

set -e

REPO_URL="https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm"

if [ "$EUID" -ne "0" ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

if which puppet > /dev/null 2>&1; then
  echo "Puppet is already installed."
  exit 0
fi

# Install puppet labs repo
echo "Configuring PuppetLabs repo..."
repo_file="$(mktemp).rpm"
curl -s --output "${repo_file}" "${REPO_URL}"
yum install -y "${repo_file}"
rm -f "${repo_file}"

# Install Puppet...
echo "Installing puppet"
yum install -y puppet-agent

echo "Puppet installed!"
