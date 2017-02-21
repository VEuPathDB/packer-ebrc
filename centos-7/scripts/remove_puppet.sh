
/usr/bin/yum erase -y 'puppet*'

rm -rf /var/lib/rpm-state/puppet*
rm -rf /var/lib/yum/repos/x86_64/7/puppet*
rm -rf /opt/puppetlabs
rm -rf /etc/puppetlabs

if /usr/sbin/semodule --list-modules |grep -q puppet; then
  if [[ -f /etc/selinux/targeted/modules/active/modules/puppet.pp ]]; then
    /usr/sbin/semodule --remove=puppet
  elif [[ -d /etc/selinux/targeted/active/modules/100/puppet ]]; then
    rm -rf /etc/selinux/targeted/active/modules/100/puppet
  fi
fi