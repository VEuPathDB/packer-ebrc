

#### x86_64-virtualbox-base.json

Creates VirtualBox OVF with minimal CentOS 7

#### x86_64-virtualbox-puppet.json

Adds Puppet to `x86_64-virtualbox-base` OVF, creates new OVF.

`builds/centos-7-64-virtualbox/centos-7-64-virtualbox.ovf`

#### x86_64-virtualbox-puppet-vagrant.json
    
Converts `x86_64-virtualbox-puppet` OVF to a Vagrant box and publishes a
**public** box as `ebrc/centos-7-64-puppet` on Atlas.

#### x86_64-virtualbox-web.json

Converts `x86_64-virtualbox-puppet` OVF to Vagrant box with EBRC WDK-based
web development support.