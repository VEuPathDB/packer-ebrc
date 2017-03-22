#!/bin/bash

Bin="$( readlink -f -- "$( dirname -- "$0" )" )"

cd "${Bin}/.."

ansible-playbook -i "localhost," -c local playbook.yml
