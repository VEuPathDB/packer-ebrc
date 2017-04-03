
### Overview

First run Packer to create a qemu image provisioned with our `savm` Puppet
environment. Currently that means

  - `packer build x86_64-qemu-base.json`
    - Installs the base operating system.
    - Creates `centos-7-64-qemu-base/centos-7-64-qemu-base.img`

  - `packer build x86_64-qemu-puppet.json`
    - Installs Puppet agent.
    - Depends on `centos-7-64-qemu-base/centos-7-64-qemu-base.img`
    - Creates `centos-7-64-qemu-puppet/centos-7-64-qemu-puppet.img`

  - `packer build x86_64-qemu-web.json`
    - Installs software dependencies for EBRC WDK-based websites, including Tomcat Instance Framework, et al.
    - Depends on `centos-7-64-qemu-puppet/centos-7-64-qemu-puppet.img`
    - Creates `

This is similar to the stages for building our Vagrant/VirtualBox boxes.
These stages may be collapsed into one in the future for the qemu builds
because we don't need the intermediate artifacts for the qemu hypervisor.

- ansible 
  - determines the site-specific parameter values
  - creates virtual disks for appdb, userdb, data (apiSiteFiles)
  - runs Packer to provision the site-specific VM
  - Packer
    - formats appdb, userdb, data virtual disks
    - runs ansible to provision website and databases
    - any post-processors (export to VMWare?)
    - (the downside is that Packer runs qemu-img to make the new VM and
    qemu-image again to finalize the root image. This is a slow process
    on the 25GB root image (on MacBook disk at least). On the upside, the final image is a smaller sparse image)

The playbook must be run on the KVM/Packer host.

`source_website` must be the backend server that hosts apiSiteFilesMirror, not a a proxy.


`inventory`

    [source_webserver]
    # w1.foodb.org

    [buildhost]
    localhost               ansible_connection=local


`source_websever` is undefined in `inventory` and set on CLI.

    ansible-playbook -i ansible/inventory ansible/collate.yml --extra-vars "source_website=w1.cryptodb.org do_full_rebuild=true"

    ansible-playbook -i ansible/dyninventory.py ansible/collate.yml --extra-vars "do_full_rebuild=true"


### To Do

several paths and other variables in Ansible playbook must match what is
in Packer template. Refactor this so that both get values from common
source.