
/usr/bin/yum erase -y puppet*

rm -rf /var/lib/rpm-state/puppet*
rm -rf /var/lib/yum/repos/x86_64/7/puppet*
rm -rf /opt/puppetlabs
rm -rf /etc/puppetlabs

/usr/sbin/semodule --remove=puppet
