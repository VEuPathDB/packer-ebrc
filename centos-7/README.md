`get_ebrc_puppet` Obtains Puppet manifests for EBRC server deployments
as a git archive in the `scratch` directory. (Git archives can not be
commited to). Production hiera data is excluded.

#### x86_64-virtualbox-base.json

Creates VirtualBox OVF with minimal CentOS 7

`packer build  x86_64-virtualbox-base.json`

#### x86_64-virtualbox-puppet.json

Adds Puppet to `x86_64-virtualbox-base` OVF, creates new OVF.

Creates `builds/centos-7-64-virtualbox/centos-7-64-virtualbox.ovf`

`packer build  x86_64-virtualbox-puppet.json`

#### x86_64-virtualbox-puppet-vagrant.json
    
Converts `x86_64-virtualbox-puppet` OVF to a Vagrant box and publishes a
**public** box as `ebrc/centos-7-64-puppet` on Atlas.

VERSION=1.0.2
jq --arg ver $VERSION '. | (.variables.version = $ver)' x86_64-virtualbox-puppet-vagrant.json

`packer build x86_64-virtualbox-puppet-vagrant.json`

#### x86_64-virtualbox-web.json

Converts `x86_64-virtualbox-puppet` OVF to Vagrant box with EBRC WDK-based
web development support.

`packer build x86_64-virtualbox-web.json`