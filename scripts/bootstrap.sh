#! /bin/sh

set -e

# Script to install `nix`, `devbox`, `direnv`, and `nix-direnv` and get them all working together

NETSKOPE_DATA_DIR="/Library/Application Support/Netskope/STAgent/data"

# Copy create Netskope combined cert and save to known location recommended by their docs:
# https://docs.netskope.com/en/netskope-help/data-security/netskope-secure-web-gateway/configuring-cli-based-tools-and-development-frameworks-to-work-with-netskope-ssl-interception/#mac-1
generate_combined_netskope_cert() {
  echo "=== generating combined CA certificate from system keychain..."
  security find-certificate -a -p \
    /System/Library/Keychains/SystemRootCertificates.keychain \
    /Library/Keychains/System.keychain \
    >/tmp/nscacert_combined.pem
  echo "=== combined CA certificate generated"

  echo "=== moving combined CA certificate to Netskope data folder (requires sudo)..."
  sudo mkdir -p "$NETSKOPE_DATA_DIR"
  sudo cp /tmp/nscacert_combined.pem "$NETSKOPE_DATA_DIR"
  echo "=== moved combined CA certificate"
}

# Install nix using the determinate systems installer because it has good defaults and an uninstall script
# Also set current user as a trusted user so they can add substituters/caches
# And set the ssl cert file globally
install_nix() {
  echo "=== installing nix (requires sudo)..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix |
    sh -s -- install --no-confirm \
      --extra-conf "trusted-users = root $(whoami)" \
      --ssl-cert-file "$NETSKOPE_DATA_DIR/nscacert_combined.pem"
  echo "=== nix installed..."
}

install_devbox() {
  echo "=== installing devbox..."
  curl -fsSL https://get.jetpack.io/devbox | FORCE=1 bash
  echo "=== devbox installed..."
}

install_direnv() {
  if command -v direnv >/dev/null 2>&1; then
    echo "=== direnv is already installed, doing nothing"
    DID_INSTALL_DIRENV=0
  else
    echo "=== direnv is not installed, installing..."
    nix profile install nixpkgs#direnv
    echo "=== direnv installed"
    DID_INSTALL_DIRENV=1
  fi
}

install_nix_direnv() {
  echo "=== installing nix-direnv..."
  nix profile install nixpkgs#nix-direnv
  echo "=== nix-direnv installed"

  if [ ! -e "$HOME/.config/direnv/direnvrc" ]; then
    echo "=== direnvrc doesn't exist, creating it with config"
    mkdir -p "$HOME/.config/direnv"
    echo "source $HOME/.nix-profile/share/nix-direnv/direnvrc" >"$HOME/.config/direnv/direnvrc"
  else
    if grep -q "^source.*\/nix-direnv\/direnvrc$" "$HOME/.config/direnv/direnvrc"; then
      echo "=== direnvrc exists and is configured to use nix-direnv, doing nothing"
    else
      echo "=== direnvrc exists but is not configured to use nix-direnv, updating..."
      echo "source $HOME/.nix-profile/share/nix-direnv/direnvrc" >>"$HOME/.config/direnv/direnvrc"
      echo "=== direnvrc updated to use nix-direnv"
    fi
  fi
}

print_further_steps() {
  echo "================================================================"
  echo "Nix, direnv, and devbox have been installed and setup"
  echo "but there is ONE MANUAL STEP LEFT!"

  if [ "$DID_INSTALL_DIRENV" ]; then
    echo "You had direnv already installed, if you've already configured it you can skip the last step"
  fi
  echo "You have to hook direnv into your shell as described here:"
  echo "https://direnv.net/docs/hook.html"

  echo "================================================================"

  echo ""
  echo "If you've had any issues with this install process please reach out to #team_delivery_eng on slack"
}

main() {
  generate_combined_netskope_cert
  install_nix
  install_devbox
  install_direnv
  install_nix_direnv
  print_further_steps
}

main
