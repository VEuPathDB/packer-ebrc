#!/bin/bash
set -eux

# Install Puppetlabs Repo
REPO_URL="https://yum.puppetlabs.com/puppet8-release-el-9.noarch.rpm"
REPO_FILE="$(mktemp).rpm"
curl -s --output "${REPO_FILE}" "${REPO_URL}"
dnf install -y "${REPO_FILE}"
rm -f "${REPO_FILE}"

# Install Puppet
dnf install -y puppet-agent

# Use Puppet's gem so modules are installed in Puppet's gempath
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml

# r10k
/opt/puppetlabs/puppet/bin/gem install faraday-net_http -v '3.0.2'
/opt/puppetlabs/puppet/bin/gem install faraday -v 2.8.1
/opt/puppetlabs/puppet/bin/gem install r10k

# git
dnf install -y git