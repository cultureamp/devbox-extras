#!/bin/sh
# Mocking MacOS programs for linux based docker container 

mkdir -p /tmp/test-metadata

export TMPDIR="/tmp"
export INSTALLER_EXTRA_ARGS="linux --init none"
export NIX_FINAL_SSL_FILE="/etc/ssl/certs/ca-certificates.crt"

echo '
#!/bin/sh
echo "dseditgroup ran with args: $@" > /tmp/test-metadata/dseditgroup.txt' | sudo tee -a /bin/dseditgroup
sudo chmod a+x /bin/dseditgroup

echo '
#!/bin/sh
echo "security ran with args: $@" > /tmp/test-metadata/security.txt' | sudo tee -a /bin/security
sudo chmod a+x /bin/security

# The below removes all sudo commands from install script
# Required as the docker container runs as root and the docker container 
# must be run as root because the nix installer only supports single user 
# root installs in containers 
sed -i 's/sudo / /g' ./scripts/bootstrap.sh 

. ./scripts/bootstrap.sh
