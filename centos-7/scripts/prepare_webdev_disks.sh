#!/bin/bash
# Format and mount external disks for web development VMs

######################################################################

# CONFIGURE
APPDB_DIR=/u02/oradata/appdb
APPDB_DEV=/dev/sdb
APPDB_LABEL=appdb

USERDB_DIR=/u02/oradata/userdb
USERDB_DEV=/dev/sdc
USERDB_LABEL=userdb

DATA_DIR=/var/www/Common/apiSiteFilesMirror
DATA_DEV=/dev/sdd
DATA_LABEL=data

######################################################################
# FORMAT DISKS - full disk, no partition
mkfs.ext4 -F $APPDB_DEV
mkfs.ext4 -F $USERDB_DEV
mkfs.ext4 -F $DATA_DEV

# LABEL DISKS
e2label $APPDB_DEV  $APPDB_LABEL
e2label $USERDB_DEV $USERDB_LABEL
e2label $DATA_DEV   $DATA_LABEL

# # MAKE MOUNTPOINTS
mkdir -p $APPDB_DIR
mkdir -p $USERDB_DIR
mkdir -p $DATA_DIR

# UPDATE /ETC/FSTAB
cat >> /etc/fstab <<EOF

LABEL=$APPDB_LABEL $APPDB_DIR ext4 nofail,defaults 0  0
LABEL=$USERDB_LABEL $USERDB_DIR ext4 nofail,defaults 0  0
LABEL=$DATA_LABEL $DATA_DIR ext4 nofail,defaults 0  0
EOF

# MOUNT ALL
mount -a

# UPDATE PERMISSIONS ON MOUNTED DEVICES
chown oracle:oinstall $USERDB_DIR
chown oracle:oinstall $APPDB_DIR
chmod 1777 $DATA_DIR
