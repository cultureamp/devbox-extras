#!/bin/sh
# Mocking MacOS programs for linux based docker container 

mkdir -p /tmp/test-metadata

export TMPDIR="/tmp"
export INSTALLER_EXTRA_ARGS="linux --init none"
export SHELL="zsh"
export NIX_FINAL_SSL_FILE="/etc/ssl/certs/ca-certificates.crt"

echo '
#!/bin/sh
echo "dseditgroup ran with args: $@" > /tmp/test-metadata/dseditgroup.txt' | sudo tee -a /bin/dseditgroup
sudo chmod a+x /bin/dseditgroup

echo '
#!/bin/sh
echo "security ran with args: $@"' | sudo tee -a /bin/security
sudo chmod a+x /bin/security

sed -i 's/ sudo / /g' ./scripts/bootstrap.sh 

. ./scripts/bootstrap.sh
