yum install -q -y yum-utils
package-cleanup -q -y --oldkernel --count=1

rm -f /var/lib/dhclient/*
rm -rf /var/cache/yum/
rm -rf /var/lib/yum/repos
rm -f /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /tmp/* /tmp/.[^.]+
rm -f /root/VBoxGuestAdditions*

yum -q -y clean all

cat /dev/null > /var/log/wtmp
