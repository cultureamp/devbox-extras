#!/bin/sh
# Mocking MacOS programs for linux based docker container 

mkdir -p /tmp/test-metadata

export TMPDIR="/tmp"
export INSTALLER_EXTRA_ARGS="linux --init none"

echo '
#!/bin/sh
echo "dseditgroup ran with args: $@" > /tmp/test-metadata/dseditgroup.txt' | sudo tee -a /bin/dseditgroup
sudo chmod a+x /bin/dseditgroup

echo '
#!/bin/sh
echo "security ran with args: $@"' | sudo tee -a /bin/security
sudo chmod a+x /bin/security

echo '
#!/bin/sh
echo "direnv ran with args: $@" > /tmp/test-metadata/direnv.txt' | sudo tee -a /bin/direnv
sudo chmod a+x /bin/direnv

. ./scripts/bootstrap.sh
