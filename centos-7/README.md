
#### x86_64-virtualbox-base.json

Creates VirtualBox OVF with minimal CentOS 7

    packer build  x86_64-virtualbox-base.json

The http/ks.cfg drives the initial installation with a yum update as a
%post script. VirtualBoxGuestAdditions are installed as a Packer
provisioners script. Other Packer provisioners scripts remove extra
kernels and zero the disks.

#### x86_64-virtualbox-puppet.json

Adds Puppet to `x86_64-virtualbox-base` OVF, creates
`builds/centos-7-64-virtualbox/centos-7-64-virtualbox.ovf`

    packer build  x86_64-virtualbox-puppet.json

#### x86_64-virtualbox-puppet-vagrant.json

Converts `x86_64-virtualbox-puppet` OVF to a Vagrant box and publishes a
**public** box as `ebrc/centos-7-64-puppet` on Atlas.

Lookup the current version in the json file.

    jq '.variables.version' x86_64-virtualbox-puppet-vagrant.json
    "1.0.1"

Pick a desired incremented value and update the json file.

    VER=1.0.3
    jq --arg ver $VER '. | (.variables.version = $ver)' x86_64-virtualbox-puppet-vagrant.json | sponge x86_64-virtualbox-puppet-vagrant.json

    export ATLAS_TOKEN=.......
    packer build x86_64-virtualbox-puppet-vagrant.json

#### x86_64-virtualbox-web.json

Converts `x86_64-virtualbox-puppet` OVF to Vagrant box with EBRC WDK-based
web development support.

Run `bin/export_ebrc_puppet` to obtain Puppet manifests for EBRC server
deployments as a git archive in the `scratch` directory. (Git archives
can not be commited to). Production hiera data is excluded from the
export by this script.

    packer build x86_64-virtualbox-web.json

After the build is complete, calculate the sha256 checksum for the box file.

    SHA2=(`shasum -a 256 builds/vagrant/virtualbox/centos-7-64-virtualbox-web.box`)

Lookup the current version in the json file.

    jq '.versions[-1].version' webdev.json
    "0.0.3"

Pick a desired incremented value and update the json file.

    VER=0.0.4

Append an entry for this new version in the `webdev.json` file.

    jq --arg ver $VER --arg sha2 $SHA2 '.versions += ( [{
      "providers": [
        {
          "checksum": $sha2,
          "checksum_type": "sha256",
          "name": "virtualbox",
          "url": "http://software.apidb.org/vagrant/webdev/\($ver)/centos-7-64-virtualbox-web.box"
        }
      ],
      "version": $ver
    }
    ] )' webdev.json | sponge webdev.json


Create a directory on the webserver

    ssh luffa.gacrc.uga.edu "mkdir /var/www/software.apidb.org/vagrant/webdev/${VER}"

Uploade the box, to versioned directory, and json file, to web root directory.

    rsync -aPv webdev.json luffa.gacrc.uga.edu:/var/www/software.apidb.org/vagrant/

    rsync -aPv builds/vagrant/virtualbox/centos-7-64-virtualbox-web.box \
        luffa.gacrc.uga.edu:/var/www/software.apidb.org/vagrant/webdev/${VER}
