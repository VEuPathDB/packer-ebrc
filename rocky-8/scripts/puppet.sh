#!/bin/bash
set -eux

# Install Puppetlabs Repo
REPO_URL="https://yum.puppetlabs.com/puppet7-release-el-8.noarch.rpm"
REPO_FILE="$(mktemp).rpm"
curl -s --output "${REPO_FILE}" "${REPO_URL}"
yum install -y "${REPO_FILE}"
rm -f "${REPO_FILE}"

# Install Puppet
yum install -y puppet-agent

# Use Puppet's gem so modules are installed in Puppet's gempath
/opt/puppetlabs/puppet/bin/gem install hiera-eyaml

# r10k
/opt/puppetlabs/puppet/bin/gem install faraday-net_http -v '3.0.2'
/opt/puppetlabs/puppet/bin/gem install faraday -v 2.8.1
/opt/puppetlabs/puppet/bin/gem install r10k
