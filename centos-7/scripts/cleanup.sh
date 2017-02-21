#/bin/sh -x

rm -f /var/lib/dhclient/*
rm -rf /var/cache/yum/
rm -rf /var/lib/yum/repos
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /tmp/* /tmp/.[^.]+
rm -rf /var/tmp/*
rm -f /root/VBoxGuestAdditions*

yum -q -y clean all

>/var/log/audit/audit.log
>/var/log/boot.log
>/var/log/btmp
>/var/log/cron
>/var/log/dmesg
>/var/log/firewalld
>/var/log/grubby
>/var/log/lastlog
>/var/log/maillog
>/var/log/messages
>/var/log/secure
>/var/log/spooler
>/var/log/tallylog
>/var/log/wtmp
>/var/log/tuned/tuned.log

find /var/log/ -name '*.old' -print0 | xargs -0 rm -f

if hash updatedb 2>/dev/null; then
  updatedb --add-prunepaths /vagrant 2>/dev/null
fi

rm -f ~root/.bash_history
unset HISTFILE

rm -rf ~root/.ssh/
