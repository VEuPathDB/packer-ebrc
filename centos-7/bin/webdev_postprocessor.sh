#!/bin/bash

set -e

WEBDEV_POSTPROCESSOR_DRYRUN=${WEBDEV_POSTPROCESSOR_DRYRUN:-0}
CHANGELOG="${CHANGELOG:-routine update}"
LOCAL_WEBDEV_JSON='builds/vagrant/webdev.json'
LOCAL_BOX='builds/vagrant/virtualbox/centos-7-64-virtualbox-web.box'
VERSION="$(date +'%Y%m%d')"
BOX_URL='https://software.apidb.org/vagrant'
BOX_SERVER='software.apidb.org'
BOX_SERVER_PATH='/var/www/software.apidb.org/vagrant'

. bin/functions

for c in sponge jq curl; do
  type $c >/dev/null 2>&1 || {
    echoerr "EBRC: FAIL: '$c' command not found. Quiting..."
    exit 1
  }
done

echo "EBRC: getting ${BOX_URL}/webdev.json"
curl --fail -Ss "${BOX_URL}/webdev.json" -o "$LOCAL_WEBDEV_JSON"


echo 'EBRC: checking webdev.json is valid'
[ 0"$(jq '.versions | length' builds/vagrant/webdev.json)" -gt 1 ] || {
  echoerr "EBRC: FAIL: no versions found in ${LOCAL_WEBDEV_JSON}"
  exit 1
}

echo "EBRC: checking for conflicting version in ${LOCAL_WEBDEV_JSON}"
set +e
jq -e  ".versions | any(.version == \"${VERSION}\")"  "$LOCAL_WEBDEV_JSON"
jq_ret=$?
set -e
if [ $jq_ret -eq 1 ]; then
  echo 'EBRC: ok'
elif [ $jq_ret -eq 0 ]; then
  echoerr "EBRC: FAIL: version '${VERSION}' was already found in"
  echoerr "'${BOX_URL}/webdev.json'."
  echoerr 'If this is a redo, remove the version entry from'
  echoerr "${BOX_URL}/webdev.json and"
  echoerr 'run `packer build` again, or run this'
  echoerr "script ($0) again."
  echoerr 'Quitting...'
  exit 1
else
  echoerr "EBRC: FAIL: jq exited with $?"
  exit 1
fi

echo 'EBRC: generating sha256 checksum'
SHA2=(`shasum -a 256 builds/vagrant/virtualbox/centos-7-64-virtualbox-web.box`)
echo "EBRC: checksum is $SHA2"

echo "EBRC: Appending an entry for this new version in '${LOCAL_WEBDEV_JSON}'."

# This requires that webdev.json already have a versions array to append to.
jq \
  --arg ver "$VERSION" \
  --arg sha2 "$SHA2" \
  --arg changelog "$CHANGELOG" \
  --arg box_url "$BOX_URL" \
  '.versions += ( [{
  "providers": [
    {
      "checksum": $sha2,
      "checksum_type": "sha256",
      "name": "virtualbox",
      "url": "\($box_url)/webdev/\($ver)/centos-7-64-virtualbox-web.box"
    }
  ],
  "version": $ver,
  "changelog": $changelog
}
] )' "$LOCAL_WEBDEV_JSON" | sponge "$LOCAL_WEBDEV_JSON"

echo 'EBRC: Create a directory on our vagrant box server'
ssh "${BOX_SERVER}" "mkdir -p ${BOX_SERVER_PATH}/webdev/${VERSION}"

if [[ "$WEBDEV_POSTPROCESSOR_DRYRUN" -eq 0 ]]; then
  echo 'EBRC: Upload the box to versioned directory, and json file to web root directory.'
  rsync -qaPv "$LOCAL_WEBDEV_JSON" "${BOX_SERVER}:${BOX_SERVER_PATH}/"
  rsync -qaPv builds/vagrant/virtualbox/centos-7-64-virtualbox-web.box \
    "${BOX_SERVER}:${BOX_SERVER_PATH}/webdev/${VERSION}"
else
  echo 'EBRC: (DRY-RUN:) Upload the box to versioned directory, and json file to web root directory.'
  echo "(DRY-RUN:) rsync -qaPv $LOCAL_WEBDEV_JSON" "${BOX_SERVER}:${BOX_SERVER_PATH}/"
  echo "(DRY-RUN:) rsync -qaPv builds/vagrant/virtualbox/centos-7-64-virtualbox-web.box \
    ${BOX_SERVER}:${BOX_SERVER_PATH}/webdev/${VERSION}"
fi