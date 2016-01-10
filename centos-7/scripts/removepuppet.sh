
/usr/bin/yum erase -y puppet*

rm -rf /var/lib/rpm-state/puppet*
rm -rf /var/lib/yum/repos/x86_64/7/puppet*

/usr/sbin/semodule --remove=puppet
