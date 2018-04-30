#!/bin/bash
# Format and mount external disks for web development VMs
set -e
unset HAS_BUILDER_DIR

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

ACCTDB_DIR=/u02/oradata/acctdb
ACCTDB_DEV=/dev/vdd
ACCTDB_LABEL=acctdb

DATA_DIR=/var/www/Common/apiSiteFilesMirror
DATA_DEV=/dev/vde
DATA_LABEL=data

BUILDER_DIR=/home/vmbuilder
BUILDER_DEV=/dev/vdf
BUILDER_LABEL=vmbuilder

if [[ -d "$BUILDER_DIR" ]]; then
  HAS_BUILDER_DIR=1
fi

######################################################################
# FORMAT DISKS - full disk, no partition
set -x
mkfs.ext4 -F $APPDB_DEV
mkfs.ext4 -F $USERDB_DEV
mkfs.ext4 -F $ACCTDB_DEV
mkfs.ext4 -F $DATA_DEV
mkfs.ext4 -F $BUILDER_DEV

# LABEL DISKS
e2label $APPDB_DEV   $APPDB_LABEL
e2label $USERDB_DEV  $USERDB_LABEL
e2label $ACCTDB_DEV  $ACCTDB_LABEL
e2label $DATA_DEV    $DATA_LABEL
e2label $BUILDER_DEV $BUILDER_LABEL
set +x

if [[ -n $HAS_BUILDER_DIR ]]; then
  # stash vmbuilder home for move to mounted volume
  tar -Pcf "${BUILDER_DIR}.tar" "${BUILDER_DIR}"
  rm -rf "${BUILDER_DIR}"
fi

# # MAKE MOUNTPOINTS
mkdir -p $APPDB_DIR
mkdir -p $USERDB_DIR
mkdir -p $ACCTDB_DIR
mkdir -p $DATA_DIR
mkdir -p $BUILDER_DIR

# UPDATE /ETC/FSTAB
cat >> /etc/fstab <<EOF

LABEL=$APPDB_LABEL $APPDB_DIR ext4 nofail,defaults 0  0
LABEL=$USERDB_LABEL $USERDB_DIR ext4 nofail,defaults 0  0
LABEL=$ACCTDB_LABEL $ACCTDB_DIR ext4 nofail,defaults 0  0
LABEL=$DATA_LABEL $DATA_DIR ext4 nofail,defaults 0  0
LABEL=$BUILDER_LABEL $BUILDER_DIR ext4 nofail,defaults 0  0
EOF

# MOUNT ALL
mount -a

if [[ -n $HAS_BUILDER_DIR ]]; then
  # restore to mounted volume
  tar -Pxf "${BUILDER_DIR}.tar"
  rm "${BUILDER_DIR}.tar"
fi

# UPDATE PERMISSIONS ON MOUNTED DEVICES
chown oracle:oinstall $USERDB_DIR
chown oracle:oinstall $APPDB_DIR
chown oracle:oinstall $ACCTDB_DIR
chmod 1777 $DATA_DIR
