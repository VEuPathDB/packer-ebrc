#!/bin/bash

set -e

# This script is to update the OS of the packerkvm Jenkins node.

EXPECTED_HOSTNAME=packerkvm

# Confirm this is running on the expected Jenkins node (don't want to
# accidentally update the wrong one).
if [[ "$HOSTNAME" != "$EXPECTED_HOSTNAME" ]]; then
  echo "This hostname is not '$EXPECTED_HOSTNAME'."
  echo "Is this running on the correct Jenkins node? Refusing to update."
  exit 1
fi

sudo yum update -y

if ! rpm -q yum-utils >/dev/null; then
  sudo yum install -y yum-utils
fi

sudo package-cleanup -y --oldkernels --count=2

VBOXVERSION=`VBoxManage --version | sed -r 's/([0-9])\.([0-9])\.([0-9]{1,2}).*/\1.\2.\3/'`

if VBoxManage list extpacks | egrep -q "Version:.+$VBOXVERSION"; then
  echo VBox extpack at correct version, no update needed.
else
  echo VBox extpack update needed ...
  curl -fs "http://download.virtualbox.org/virtualbox/${VBOXVERSION}/Oracle_VM_VirtualBox_Extension_Pack-${VBOXVERSION}.vbox-extpack" -o "/tmp/Oracle_VM_VirtualBox_Extension_Pack-${VBOXVERSION}.vbox-extpack"
  yes | sudo VBoxManage extpack install --replace "/tmp/Oracle_VM_VirtualBox_Extension_Pack-${VBOXVERSION}.vbox-extpack"
  rm -f "/tmp/Oracle_VM_VirtualBox_Extension_Pack-${VBOXVERSION}.vbox-extpack"
fi

needs-restarting -r
RESTART=$?
echo RESTART $RESTART

if [[ $RESTART -ne 0 ]]; then
  echo "Rebooting in 1 minute"
  sudo /sbin/shutdown -r +1
fi
