# sometimes the VitrualBox NAT interface is not ready when Linux starts
# networking. I started seeing this with CentOS 7.3.1611 and
# initscripts-9.49.37. initscripts allows a DEVTIMEOUT config to wait up
# to N seconds for NIC device to appear.
#
# https://bugzilla.redhat.com/show_bug.cgi?id=1287726
# https://bugzilla.redhat.com/show_bug.cgi?id=1194623

this="$(basename $0)"

if ! grep -q DEVTIMEOUT /etc/sysconfig/network; then
cat >> /etc/sysconfig/network <<EOF

# wait up to 10 seconds for NIC hardware detection before initializing
# interface. This is a Packer-managed addition using $this .
# -mheiges@uga.edu
#
DEVTIMEOUT=10
EOF
fi
