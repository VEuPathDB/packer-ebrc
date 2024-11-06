#!/bin/bash
set -ux

# Enable dotglob to match hidden files
shopt -s dotglob
rm -rf /tmp/*
rm -rf /var/tmp/*
shopt -u dotglob

# Remove unnecessary files and directories to clean up the image
rm -f /var/lib/dhclient/*
rm -rf /var/cache/yum/
rm -rf /var/lib/yum/repos
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /root/VBoxGuestAdditions*

# Clean yum cache
yum -q -y clean all

# Truncate log files to clear their contents
truncate -s 0 /var/log/audit/audit.log
truncate -s 0 /var/log/boot.log
truncate -s 0 /var/log/btmp
truncate -s 0 /var/log/cron
truncate -s 0 /var/log/dmesg
truncate -s 0 /var/log/firewalld
truncate -s 0 /var/log/grubby
truncate -s 0 /var/log/lastlog
truncate -s 0 /var/log/maillog
truncate -s 0 /var/log/messages
truncate -s 0 /var/log/secure
truncate -s 0 /var/log/spooler
truncate -s 0 /var/log/tallylog
truncate -s 0 /var/log/wtmp
truncate -s 0 /var/log/tuned/tuned.log

# Remove old log files
find /var/log/ -name '*.old' -print0 | xargs -0 rm -f

# Update file database excluding /vagrant if updatedb is available
if hash updatedb 2>/dev/null; then
  updatedb --add-prunepaths /vagrant 2>/dev/null
fi

# Clear root's bash history and remove SSH configuration
rm -f ~root/.bash_history
unset HISTFILE
rm -rf ~root/.ssh/
