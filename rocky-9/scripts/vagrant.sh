#!/bin/bash
set -eux

# Setup r10k (from Puppet) for Vagrant use
mkdir -p /etc/puppetlabs/r10k/
cat <<EOF > /etc/puppetlabs/r10k/r10k.yaml
:sources:
  :internal:
    remote: '/vagrant/scratch/puppet-control'
    basedir: '/etc/puppetlabs/code/environments'
EOF
chmod 644 /etc/puppetlabs/r10k/r10k.yaml

# Create vagrant user
useradd -m -s /bin/bash -p "$(openssl passwd -1 vagrant)" vagrant

# Configure sudo
echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant

# Install Vagrant insecure key
mkdir -p /home/vagrant/.ssh
curl -L https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub \
  -o /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys

# Unset the root password
passwd -d root
