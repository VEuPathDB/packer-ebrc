#!/bin/bash
# Format and mount external disks for web development VMs

######################################################################
# Device naming depends on qemu interface used. /dev/sd* for sata
# /dev/vd* for virtio. sata has a limit of 4 disks so we typical have 
# to use virtio.

# CONFIGURE
APPDB_DIR=/u02/oradata/appdb
APPDB_DEV=/dev/vdb
APPDB_LABEL=appdb

USERDB_DIR=/u02/oradata/userdb
USERDB_DEV=/dev/vdc
USERDB_LABEL=userdb

DATA_DIR=/var/www/Common/apiSiteFilesMirror
DATA_DEV=/dev/vdd
DATA_LABEL=data

######################################################################
# FORMAT DISKS - full disk, no partition
set -x
mkfs.ext4 -F $APPDB_DEV
mkfs.ext4 -F $USERDB_DEV
mkfs.ext4 -F $DATA_DEV

# LABEL DISKS
e2label $APPDB_DEV  $APPDB_LABEL
e2label $USERDB_DEV $USERDB_LABEL
e2label $DATA_DEV   $DATA_LABEL
set +x

# # MAKE MOUNTPOINTS
mkdir -p $APPDB_DIR
mkdir -p $USERDB_DIR
mkdir -p $DATA_DIR

chown oracle:oinstall -R /u02

# UPDATE /ETC/FSTAB
cat >> /etc/fstab <<EOF

LABEL=$APPDB_LABEL $APPDB_DIR ext4 defaults 0  0
LABEL=$USERDB_LABEL $USERDB_DIR ext4 defaults 0  0
LABEL=$DATA_LABEL $DATA_DIR ext4 defaults 0  0
EOF

# MOUNT ALL
mount -a
