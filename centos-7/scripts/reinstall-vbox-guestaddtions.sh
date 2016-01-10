# When GuestAdditions is installed without dkms we
# must run setup again after kernel upgrades.
# dkms is in epel but the VM may not have a yum conf 
# for epel when GuestAdditions was originally installed.

/opt/VBoxGuestAdditions*/init/vboxadd setup
