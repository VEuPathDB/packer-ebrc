#!/bin/bash

SOURCE_SITE=w1.trichdb.org
_INT_REGEX='^[0-9]+$'

function errlog() {
  echo "$@"
}

# Files to cache on host then Packer uploads to guest.
#
# rsync apiSiteFiles from source so we know how big to make the data volume
# and so we can fail early.
#
# project_home

type -p bc > /dev/null || {
  errlog "'bc' calculator command not found."
  exit 1
}

curl -s --fail "http://${SOURCE_SITE}/dashboard/xml/vmenv/value" -o setenv || {
  errlog "unable to get 'http://${SOURCE_SITE}/dashboard/xml/vmenv/value'"
  exit 1
}

. setenv || {
  errlog "unable to source 'setenv'"
  exit 1
}

BUILD_DIR=builds/staging/${PRODUCT}

APPDB_SIZE_GB_ON_DISK="$(curl -s --fail http://${SOURCE_SITE}/dashboard/xml/appdb/sizeondisk/value)" || {
  errlog "unable to get 'http://${SOURCE_SITE}/dashboard/xml/appdb/sizeondisk/value'"
  exit 1
}
if ! [[ $APPDB_SIZE_GB_ON_DISK =~ $_INT_REGEX ]] ; then
   errlog "error: APPDB_SIZE_GB_ON_DISK is not a number"
   exit 1
fi


USERDB_SIZE_GB_ON_DISK="$(curl -s --fail http://${SOURCE_SITE}/dashboard/xml/userdb/sizeondisk/value)" || {
  errlog "unable to get 'http://${SOURCE_SITE}/dashboard/xml/userdb/sizeondisk/value'"
  exit 1
}
if ! [[ $USERDB_SIZE_GB_ON_DISK =~ $_INT_REGEX ]] ; then
   errlog "error: USERDB_SIZE_GB_ON_DISK is not a number"
   exit 1
fi

DATA_SIZE_GB_ON_DISK=10

APPDB_IMG_SIZE="$(bc -l <<< "${APPDB_SIZE_GB_ON_DISK} * 1.10")"
USERDB_IMG_SIZE="$(bc -l <<< "${USERDB_SIZE_GB_ON_DISK} * 1.10")"
DATA_IMG_SIZE="$(bc -l <<< "${DATA_SIZE_GB_ON_DISK} * 1.05")"

echo "PRODUCT ${PRODUCT}"
echo "APPDB_SIZE_GB_ON_DISK ${APPDB_SIZE_GB_ON_DISK}"
echo "APPDB_IMG_SIZE ${APPDB_IMG_SIZE}"
echo "USERDB_SIZE_GB_ON_DISK ${USERDB_SIZE_GB_ON_DISK}"
echo "USERDB_IMG_SIZE ${USERDB_IMG_SIZE}"
echo "DATA_SIZE_GB_ON_DISK ${DATA_SIZE_GB_ON_DISK}"
echo "DATA_IMG_SIZE ${DATA_IMG_SIZE}"

mkdir -p $BUILD_DIR


qemu-img create -f qcow2 "${BUILD_DIR}/${PRODUCT}_${BUILD_NUMBER}_appdb.img" "${APPDB_IMG_SIZE}G"
qemu-img create -f qcow2 "${BUILD_DIR}/${PRODUCT}_${BUILD_NUMBER}_userdb.img" "${USERDB_IMG_SIZE}G"
qemu-img create -f qcow2 "${BUILD_DIR}/${PRODUCT}_${BUILD_NUMBER}_data.img" "${DATA_IMG_SIZE}G"

