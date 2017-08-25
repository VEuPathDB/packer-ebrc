Packer generation of virtual machine images for EuPathDB.

### Getting Started

**Host Requirements:**

- Packer
- VirtualBox
- [jq](https://stedolan.github.io/jq/)
- sponge (`moreutils` RPM, Homebrew)
- [librarian-puppet](https://github.com/rodjek/librarian-puppet)

**Tips:**

- Disable wireless, use only wired. Empirical evidence suggests that
having both enabled can sometimes result in Packer hanging on "Waiting
for SSH to become available".
- Many packages and other assets are behind EuPathDB firewalls. Run from
campus network.

### Build Configurations

The builds are incrementally provisioned in four stages.

  0. a minimum CentOS OVF image (`x86_64-virtualbox-base.json`)
  0. addition of Puppet to the CentOS OVF image (`x86_64-virtualbox-puppet.json`)
  0. conversion of the OVF image to a Vagrant box (`x86_64-virtualbox-puppet-vagrant.json`)
  0. Puppet provisioning of web server software and configurations to the Vagrant box (`x86_64-virtualbox-web.json`)

Each build step depends on the artifacts from the previous step.

#### x86_64-virtualbox-base.json

Generate a VirtualBox OVF with minimal CentOS 7. Creates
`builds/centos-7-64-virtualbox/centos-7-64-virtualbox.ovf`
Password for `root` account is `ebrc`.

    packer build  x86_64-virtualbox-base.json

The http/ks.cfg drives the initial installation with a yum update as a
%post script. VirtualBoxGuestAdditions are installed as a Packer
provisioners script. Other Packer provisioners scripts remove extra
kernels and zero the disks.

#### x86_64-virtualbox-puppet.json

Adds Puppet to the `x86_64-virtualbox-base` OVF from the previous step.
Creates
`builds/centos-7-64-virtualbox-puppet/centos-7-64-virtualbox-puppet.ovf`.
Password for `root` account is `ebrc`.


    packer build  x86_64-virtualbox-puppet.json

#### x86_64-virtualbox-puppet-vagrant.json

_This build is optional, it is not needed by
`x86_64-virtualbox-web.json`. Only build this if you want to place an
updated box on Atlas._

Converts `x86_64-virtualbox-puppet` OVF to a Vagrant box and publishes a
**public** box as `ebrc/centos-7-64-puppet` on Atlas with the box
version derived from the build timestamp, `%Y%m%d`. Creates
`builds/vagrant/virtualbox/centos-7-64-virtualbox-puppet.box`. The
password for `root` account is now `vagrant`.

Set `ATLAS_TOKEN` environment variable and run the build command,
passing in the current date as the box `version` variable.

    export ATLAS_TOKEN=.......

    packer build -var "version=$(date +'%Y%m%d')" x86_64-virtualbox-puppet-vagrant.json

    packer build -var "phase=testing version=$(date +'%Y%m%d')" x86_64-virtualbox-puppet-vagrant.json

#### x86_64-virtualbox-web.json

Converts `x86_64-virtualbox-puppet` OVF to Vagrant box with EBRC
WDK-based web development support. Creates
`builds/vagrant/virtualbox/centos-7-64-virtualbox-web.box`. A
`post-processor` step uploads the box and updated `webdev.json` to
EBRC's box server.

This includes provisioning the `vagrant` user via local Puppet manifests
in the `puppet` directory. The modules are managed by librarian-puppet
and Puppetfile. The modules directory will be empty when initially
checked out from git, before librarian-puppet installs the modules. The
directory must exist, even if empty, because Vagrant checks for its
existence during its configuration validation phase, before provisioning
steps are run.

The provisioning in `x86_64-virtualbox-web.json` includes a run of
`bin/export_ebrc_puppet` to obtain Puppet manifests for EBRC server
deployments as a git archive into the `scratch` directory. (Git archives
can not be commited to). Production hiera data is excluded from the
export by this script.

If this build has significant changes set some notes in the `CHANGELOG`
shell environment variable (defaults to `routine update` if not set),
then build.

    export CHANGELOG="brief notes about any signficant changes"
    packer build x86_64-virtualbox-web.json

For testing, pass the `webdev_postprocessor_dryrun` variable with
non-zero value. This disables uploading the files to the box server.

    packer build -var 'webdev_postprocessor_dryrun=1' x86_64-virtualbox-web.json
