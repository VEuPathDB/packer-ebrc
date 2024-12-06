#!/bin/bash
# Use this yum update after provisioning that adds new YUM repos.
# For example, you'll want to update after adding the veupathdb repo for
# any packages that are newer than base/epel.
#
# Don't update the kernel

dnf -q -y clean all
dnf -q -y update
