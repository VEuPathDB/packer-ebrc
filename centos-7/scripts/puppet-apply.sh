#!/bin/sh

# Apply puppet manifests and test for '2' detailed exit code.

#
# --detailed-exitcodes
#
# Provide extra information about the run via exit codes; only works if
# '--test' or '--onetime' is also specified. If enabled, 'puppet agent'
# will use the following exit codes:
#
# 0: The run succeeded with no changes or failures; the system was
# already in the desired state.
# 1: The run failed, or wasn't attempted due to another run already in
# progress.
# 2: The run succeeded, and some resources were changed.
# 4: The run succeeded, and some resources failed.
# 6: The run succeeded, and included both changes and failures.
#

PATH=$PATH:/opt/puppetlabs/bin

puppet_environment=${puppet_environment:-savm} 
puppet_code_dir=${puppet_code_dir:-/media/sf_scratch/puppet/code}

puppet --version

set -x
puppet apply \
  --detailed-exitcodes \
  --test \
  --environment="${puppet_environment}" \
  --codedir=/media/sf_scratch/puppet/code \
  "${puppet_code_dir}/environments/${puppet_environment}/manifests"
puppet_exit_code=$?
set +x

echo "puppet apply exited with exit code: ${puppet_exit_code}"

if [[ $puppet_exit_code != 2 ]]; then
  exit 1
else
  exit 0
fi
