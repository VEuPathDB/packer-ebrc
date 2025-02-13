#!/bin/bash

# Set grub_timeout to 0 so we don't have to wait
# an extra 5 seconds everytime we do vagrant up

sed -i 's/GRUB_TIMEOUT=[0-9]*/GRUB_TIMEOUT=0/g' /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg