# Rocky 8 Virtual Machine Generation

This automation helps build virtual machine images in stages and configures a
Vagrant box for a common development environment. The last stage copies the
`rocky-8-64-vagrant` image and a `metadata.json` file, then archives them into
the `.box` format that Vagrant expects.

## Quick Start

To quickly get started, ensure you have the following prerequisites installed:
- qemu/kvm
- packer (tested with Debian's FOSS version
[1.6.6](https://packages.debian.org/bookworm/packer))
- make

Run the following command to build the Vagrant box from scratch:

```
make
```

### Development Tips
By default, Packer cleans up on errors, making debugging difficult. If you're
developing or debugging, it's recommended to run:

```
make ON_ERROR=ask
```

Additionally, set `HEADLESS=false` to view the GUI console for more complex
issues.

### Important Notes
- During the first stage, SSH repeatedly tries to connect while the machine is
provisioning using the kickstart file. If this process takes more than 10
minutes on a decent connection and machine, there may be an issue.

### Local Vagrant Import
To import and test the resulting box:

```
vagrant box add test ./builds/libvirt/vagrantbox/rocky-8-64-puppet.box
vagrant init test
vagrant up
```

## Build Stages and Make Options
The build process is divided into four stages, each of which can be run individually using `make` commands.

### Full Build Process
Command: `make` or `make all`\
Runs all four stages in sequence: base, puppet, vagrant, and package. This is
the most comprehensive build option suitable for generating the complete
Vagrant box.

### 1. Base Image
Command: `make base`\
This stage is based on the Rocky 8 Boot ISO and runs a basic kickstart to set up the initial system.

### 2. Puppet Installation
Command: `make puppet`\
Installs Puppet Labs 7 repository, `puppet-agent`, `hiera-eyaml`, and `r10k`.

### 3. Vagrant Provisioning
Command: `make vagrant`\
Provisions the system for use in Vagrant.

### 4. Packaging
Command: `make package`\
Archives the Vagrant-provisioned qcow2 image into a tarball compatible with Vagrant.
