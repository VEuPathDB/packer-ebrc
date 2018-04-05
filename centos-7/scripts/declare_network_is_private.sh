#/bin/sh -x

# Remove security features that are not needed on a
# privately-hosted Vagrant box.

cat >> /etc/sysconfig/httpd <<EOF

# websites that derive configurations from QaAuth.pm
# can disable basic auth by setting IS_PRIVATE_NETWORK=1.
IS_PRIVATE_NETWORK=1
EOF
