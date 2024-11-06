.PHONY: all base puppet vagrant clean

# Defaults
ON_ERROR  ?= cleanup
HEADLESS  ?= true
BOXDIR    ?= builds/libvirt/vagrantbox
VERSION   ?= "$(shell date +%Y%m%d.%H%M)"

# Build command
PKR_BUILD_CMD = packer build -var 'headless=$(HEADLESS)' -on-error=$(ON_ERROR)

all: base puppet vagrant package

base:
	$(PKR_BUILD_CMD) x86_64-qemu-base.pkr.hcl

puppet:
	$(PKR_BUILD_CMD) x86_64-qemu-puppet.pkr.hcl

vagrant:
	$(PKR_BUILD_CMD) x86_64-qemu-vagrant.pkr.hcl

package:
	mkdir -p "$(BOXDIR)"
	cp -u files/libvirt_metadata.json "$(BOXDIR)/metadata.json"
	sed -i "s/19700101/$(VERSION)/g" "$(BOXDIR)/metadata.json"
	cp -u builds/libvirt/rocky-9-64-vagrant/rocky-9-64-vagrant "$(BOXDIR)/box.img"
	cd "$(BOXDIR)" && \
	tar cvf rocky-9-64-puppet.box box.img metadata.json > /dev/null 2>&1 && \
	echo "Successfully created rocky-9-64-puppet.box!"

clean:
	rm -rf builds
