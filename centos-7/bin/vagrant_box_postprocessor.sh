#!/bin/bash

set -e

# Required shell variables:
#
# PROVIDER - virtualbox or vmware
# BOX_NAME - e.g. centos-7-webdev.box or centos-7-64-virtualbox-puppet.box
#            This is the name of the file on the BOX_SERVER, it will be used 
#            as part of the 'url:' in the $BOX_JSON file.
# BOX_JSON - e.g. webdev.json or centos-7-64-puppet.json
#            A Vagrantfile will reference this in its `config.vm.box_url` setting.
# VM_NAME -  e.g. centos-7-webdev or centos-7-64-puppet
# SHORT_VM_NAME - optional, e.g. webdev. VM_NAME is used if short name is not defined
#            This will be used to determine the subdirectory name on the BOX_SERVER.
#             /var/www/software.apidb.org/vagrant/webdev
# LOCAL_BOX - e.g. 'builds/vagrant/virtualbox/centos-7-virtualbox-web.box' or 'builds/vagrant/virtualbox/centos-7-64-virtualbox-puppet.box'

BOX_POSTPROCESSOR_DRYRUN=${BOX_POSTPROCESSOR_DRYRUN:-0}
CHANGELOG="${CHANGELOG:-routine update}"
SHORT_VM_NAME=${SHORT_VM_NAME:-$VM_NAME}
LOCAL_BOX_JSON="builds/vagrant/${BOX_JSON}"
VERSION="$(date +'%Y%m%d')"
BOX_URL='https://software.apidb.org/vagrant'
BOX_SERVER=${BOX_SERVER:-software.apidb.org}
BOX_SERVER_PATH='/var/www/software.apidb.org/vagrant'

. bin/functions

for c in sponge jq curl; do
  type $c >/dev/null 2>&1 || {
    echoerr "EBRC: FAIL: '$c' command not found. Quiting..."
    exit 1
  }
done

echo "EBRC: getting ${BOX_URL}/${SHORT_VM_NAME}.json"
curl --fail -Ss "${BOX_URL}/${BOX_JSON}" -o "$LOCAL_BOX_JSON"

echo "EBRC: checking ${SHORT_VM_NAME}.json is valid"
[ "$(jq '.versions' "$LOCAL_BOX_JSON")" != "null" ] || {
  echoerr "EBRC: FAIL: no 'versions' section found in ${LOCAL_BOX_JSON}"
  exit 1
}

echo "EBRC: checking for conflicting version in ${LOCAL_BOX_JSON}"
set +e
jq -e  ".versions | any(.version == \"${VERSION}\")"  "$LOCAL_BOX_JSON"
jq_ret=$?
set -e
if [ $jq_ret -eq 1 ]; then
  echo 'EBRC: ok'
elif [ $jq_ret -eq 0 ]; then
  echoerr "EBRC: FAIL: version '${VERSION}' was already found in"
  echoerr "'${BOX_URL}/${SHORT_VM_NAME}.json'."
  echoerr 'If this is a redo, remove the version entry from'
  echoerr "${BOX_URL}/${SHORT_VM_NAME}.json and"
  echoerr 'run `packer build` again, or run this'
  echoerr "script ($0) again."
  echoerr 'Quitting...'
  exit 1
else
  echoerr "EBRC: FAIL: jq exited with $?"
  exit 1
fi

if [[ ! -f "${LOCAL_BOX}" ]]; then
  echoerr "EBRC: FAIL: '${LOCAL_BOX}' not found"
  exit 1
fi

echo 'EBRC: generating sha256 checksum'
if type shasum >/dev/null 2>&1; then
  SHA2=(`shasum -a 256 ${LOCAL_BOX}`)
else
  SHA2=(`sha256sum ${LOCAL_BOX}`)
fi
echo "EBRC: checksum is $SHA2"

echo "EBRC: Appending an entry for this new version in '${LOCAL_BOX_JSON}'."

# This requires that ${SHORT_VM_NAME}.json already have a versions array to append to.
jq \
  --arg ver "$VERSION" \
  --arg sha2 "$SHA2" \
  --arg changelog "$CHANGELOG" \
  --arg box_url "$BOX_URL" \
  --arg SHORT_VM_NAME "$SHORT_VM_NAME" \
  --arg box_name "$BOX_NAME" \
  --arg provider "$PROVIDER" \
  '.versions += ( [{
  "providers": [
    {
      "checksum": $sha2,
      "checksum_type": "sha256",
      "name": "virtualbox",
      "url": "\($box_url)/\($SHORT_VM_NAME)/\($provider)/\($ver)/\($box_name)"
    }
  ],
  "version": $ver,
  "changelog": $changelog
}
] )' "$LOCAL_BOX_JSON" | sponge "$LOCAL_BOX_JSON"


if [[ "$BOX_POSTPROCESSOR_DRYRUN" -eq 0 ]]; then
  echo 'EBRC: Create a directory on our vagrant box server'
  ssh "${BOX_SERVER}" "mkdir -p ${BOX_SERVER_PATH}/${SHORT_VM_NAME}/${PROVIDER}/${VERSION}"
  echo 'EBRC: Upload the box to versioned directory, and json file to web root directory.'
  rsync -qaPv "${LOCAL_BOX}" \
    "${BOX_SERVER}:${BOX_SERVER_PATH}/${SHORT_VM_NAME}/${PROVIDER}/${VERSION}"
  rsync -qaPv "$LOCAL_BOX_JSON" "${BOX_SERVER}:${BOX_SERVER_PATH}/"
else
  echo 'EBRC: (DRY-RUN:) Create a directory on our vagrant box server'
  echo "(DRY-RUN:) ssh ${BOX_SERVER}" "mkdir -p ${BOX_SERVER_PATH}/${SHORT_VM_NAME}/${PROVIDER}/${VERSION}"
  echo 'EBRC: (DRY-RUN:) Upload the box to versioned directory, and json file to web root directory.'
  echo "(DRY-RUN:) rsync -qaPv ${LOCAL_BOX} \
    ${BOX_SERVER}:${BOX_SERVER_PATH}/${SHORT_VM_NAME}/${PROVIDER}/${VERSION}"
  echo "(DRY-RUN:) rsync -qaPv $LOCAL_BOX_JSON" "${BOX_SERVER}:${BOX_SERVER_PATH}/"
fi
