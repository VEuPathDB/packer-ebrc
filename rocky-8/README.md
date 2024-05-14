# Rocky 8 Virtual Machine Image Generation

## Getting Started

**Host Requirements:**
- Packer (testing with [Debian's FOSS version 1.6.6](https://packages.debian.org/bookworm/packer))
- QEMU/KVM

## Build Configurations

The builds are incrementally provisioned in multiple stages.

1. Create a minimum Rocky 8 base image (`x86_64-qemu-base.pkr.hcl`)
2. Puppet configuration stage
3. Vagrant box creation
4. Web server software testing in Vagrant (optional)

Each build step depends on the artifacts from the previous step.

### x86_64-qemu-base.pkr.hcl

Generate a minimal Rocky 8 base image.

```bash
packer build x86_64-qemu-base.pkr.hcl
```

Useful testing command.

```bash
packer build -var 'headless=false' -on-error=ask x86_64-qemu-base.pkr.hcl
```

## Future Stages
While the details of the next stages are still being developed, they will
include a Puppet stage and a Vagrant stage, reflecting the structure of the
`centos-7` directory.
