# Use this yum update after provisioning that adds new YUM repos.
# For example, you'll want to update after adding the eupathdb repo for
# any packages that are newer than base/epel.
#
# Don't update the kernel

yum -q -y clean all
yum -q -y update
