Packer generation of virtual machine images for EuPathDB.

### Getting Started

**Host Requirements:**

- Packer
- VirtualBox
- [jq](https://stedolan.github.io/jq/)
- sponge (`moreutils` RPM, Homebrew)
- [librarian-puppet](https://github.com/rodjek/librarian-puppet)
- [hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml) - if you want
to edit encrypted hiera data.
- Public and private keys for hiera-eyaml in the `puppet/keys` directory
of this project. These are required on the Packer host even if you do
not need to edit encrypted hiera data because they will be uploaded to
and used by the guest for decryption. Copy these from the Notes field of
"Packer puppet hiera-eyaml keys" in Passpack. The Passpack Notes field
does not preserve line endings so you'll need to manually fix the line
wrapping to make valid keys (i.e. replace spaces with newlines).

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
  0. Puppet provisioning of web server software and configurations to the Vagrant box (`x86_64-virtualbox-webdev.json`)

Each build step depends on the artifacts from the previous step.

#### x86_64-virtualbox-base.json

Generate a VirtualBox OVF with minimal CentOS 7. Creates
`builds/virtualbox/centos-7-64-base/centos-7-64-base.ovf`
Password for `root` account is `ebrc`.

```bash
$ packer build  x86_64-virtualbox-base.json
```

The http/ks.cfg drives the initial installation with a yum update as a
%post script. VirtualBoxGuestAdditions are installed as a Packer
provisioners script. Other Packer provisioner scripts remove extra
kernels and zero the disks.

#### x86_64-virtualbox-puppet.json

Adds Puppet to the OVF from `x86_64-virtualbox-base.json` of the previous step.
Creates
`builds/virtualbox/centos-7-64-puppet/centos-7-64-puppet.ovf`.
Password for `root` account is `ebrc`.

```bash
$ packer build  x86_64-virtualbox-puppet.json
```

#### x86_64-virtualbox-puppet-vagrant.json

_This build is optional, it is not needed by
`x86_64-virtualbox-webdev.json`. Only build this when you want to place an
updated CentOS box in our box repo._

Converts the OVF from `x86_64-virtualbox-puppet.json` of the previous step to a
Vagrant-compatible box and publishes the box as
`ebrc/centos-7-64-puppet` in our repo with the box version derived from
the build timestamp, `%Y%m%d`. Creates
`builds/virtualbox/vagrant/centos-7-64-puppet/centos-7-64-puppet.box` on the Packer host. A
post-processor runs `bin/vagrant_box_postprocessor.sh` to upload to our
box repository and update the metadata json file.

Box specifications for a Vagrantfile are

```ruby
vm_config.vm.box      = 'ebrc/centos-7-64-puppet',
vm_config.vm.hostname = 'http://software.apidb.org/vagrant/centos-7-64-puppet.json'
```

The password for `root` account on this VM is `vagrant`.

#### x86_64-virtualbox-webdev.json

Converts the OVF from `x86_64-virtualbox-puppet.json` to Vagrant box with EBRC
WDK-based web development support. Creates
`builds/virtualbox/vagrant/centos-7-webdev/centos-7-webdev.box`. A
`post-processor` step uploads the box and updated `webdev.json` to
EBRC's box server.

Box specifications for a Vagrantfile are

```ruby
vm_config.vm.box      = 'ebrc/webdev',
vm_config.vm.hostname = 'http://software.apidb.org/vagrant/webdev.json'
```

**Webdev Build Highlights**

This build includes provisioning the `vagrant` user via local Puppet
manifests in the `puppet` directory on the Packer host. The Puppet
modules are managed by librarian-puppet and Puppetfile. The modules
directory will be empty when this packer-ebrc project is initially
checked out from git, before librarian-puppet installs the modules. The
directory must exist, even if empty, because Vagrant checks for its
existence during its configuration validation phase, before provisioning
steps are run. A missing directory wil result in Packer returning
"`module_path[0] is invalid: stat puppet/modules: no such file or directory`".
The hiera ddta for this provisioning uses
[hiera-eyaml](https://github.com/voxpupuli/hiera-eyaml ).

Then there is a second, separate Puppet provisioning of EBRC components.
The provisioning in `x86_64-virtualbox-webdev.json` includes a run of
`bin/export_ebrc_puppet` on the Packer host which obtains EBRC's Puppet
manifests as a git archive into the `scratch` directory. (Git archives
can not be commited to). Production hiera data is excluded from the
export by this script.

If this build has significant changes set some notes in the `CHANGELOG`
shell environment variable (defaults to `routine update` if not set),
then build.

```bash
$ export CHANGELOG="brief notes about any signficant changes"
$ packer build x86_64-virtualbox-webdev.json
```

For testing, pass the `box_postprocessor_dryrun` variable with
non-zero value. This disables uploading the files to the box server.

```bash
$ packer build -var 'box_postprocessor_dryrun=1' x86_64-virtualbox-webdev.json
```

----

## Amazon Webservices (AWS)

### Requirements

You will need a personal AWS account. There is no EBRC organization
account at this time.

You need a Virtual Private Cloud (VPC) configured for your region. AWS
typically creates one as a default but if you don't have one (your
account predates VPCs or you deleted it) then you will need to create a
VPC. These Packer templates require a subnet_id value so Packer can then
lookup which VPC to use - that is, it assumes you are using a
non-default VPC.

You need the subnet-id from your desired VPC to pass to Packer via the
`aws_subnet_id` variable.

Access key and secret from an IAM user is needed. The user must be
associated with the proper permission policy. See
[IAM policy for Packer](https://www.packer.io/docs/builders/amazon.html)
for guidance.


#### x86_64-aws-base.json

Generates with a hardware virtual machine (HVM) with encrypted boot
volume. The resulting AMI is the preferred base for other EBRC VMs
because the volume is encrypted.

Based on the [CentOS 7 Marketplace HVM AMI](https://aws.amazon.com/marketplace/pp/B00O7WM7QW).
See the [CentOS Cloud wiki](https://wiki.centos.org/Cloud/AWS) for product codes.

Notable variables in json template:

- `aws_region` is hardcoded; can be overridden with `-var "aws_region=..."`.
- `subnet_id` This value is specified under the assumption you are using a non-default VPC.

`$KEY` and `$SECRET` are the `access_key_id` and `secret_access_key` for the `packer` user,
or whichever user has the proper
[IAM policy for Packer](https://www.packer.io/docs/builders/amazon.html) to work.

```bash
$ KEY=WVA888AAAAXXXX
$ SECRET='AAATA/rbXEIEIO666'
$ packer build \
  -var "aws_access_key=$KEY" \
  -var "aws_secret_key=$SECRET" \
  -var "aws_subnet_id=subnet-b2d6458f" \
  -var "aws_region=us-east-1" \
  x86_64-aws-base.json 
```

#### x86_64-aws-puppet.json

This adds to the `centos-7-base` AMI generated by
`x86_64-aws-base.json`. This AMI has little practical use beyond serving
as a test case.

The  `centos-7-base` source AMI must be available before building this
Packer template. This dependency is intentional, the `centos-7-base` AMI
adds disk encryption to the Marketplace AMI so EBRC Puppet manifests and
other provisioning data will be protected on at-rest storage, including
temporary build volumes.

Notable variables in json template:

- `ami_owner_id` is the owner ID of the source AMI
- `aws_subnet_id` 

```bash
$ KEY=WVA888AAAAXXXX
$ SECRET='AAATA/rbXEIEIO666'
$ packer build \
  -var "aws_access_key=$KEY" \
  -var "aws_secret_key=$SECRET" \
  -var "aws_subnet_id=subnet-b2d6458f" \
  -var "aws_region=us-east-1" \
  x86_64-aws-puppet.json 
```

#### Troubleshooting AWS Builds

If you don't have an
[AWS default VPC](https://aws.amazon.com/vpc/faqs/#Default_VPCs) -
because the selected region in your account includes the old
'EC2-Classic' or because you deleted your default VPC - you will need to
specify it in the Packer template. _Contact AWS support to (re)create a 
default VPC._

*VPCResourceNotSpecified error*

From https://www.packer.io/intro/getting-started/build-image.html,

```
Note: If you see a VPCResourceNotSpecified error, Packer might not be
able to determine the default VPC, which the t2 instance types require.
This can happen if you created your AWS account before 2013-12-04. You
can either change the instance_type to m3.medium, or specify a VPC.
Please see
http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/default-vpc.html
for more information. If you specify a vpc_id, you will also need to set
subnet_id. Unless you modify your subnet's IPv4 public addressing
attribute, you will also need to set associate_public_ip_address to
true, or set up a VPN.
```

From https://github.com/hashicorp/packer/issues/2056

```
pick a subnet from your default VPC that AWS automatically creates
create a security group with inbound rule of protocol: SSH, port: 22, source: 0.0.0.0/0
add the following properties to the amazon-ebs -builder
"subnet_id": "subnet-123456",
"security_group_id": "sg-1234-allow-ssh"
```
