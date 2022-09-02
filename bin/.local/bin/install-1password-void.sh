#!/bin/sh
set -eu

APP_URL="https://downloads.1password.com/linux/tar/stable/x86_64/1password-latest.tar.gz"
TMP_TAR="1password-latest.tar.gz"

echo "[+] Installing dependencies..."
sudo xbps-install -S gnome-keyring libsecret dbus xdg-utils || true

echo "[+] Downloading 1Password..."
curl -sSO "$APP_URL"

echo "[+] Extracting..."
sudo tar -xf "$TMP_TAR"

echo "[+] Installing to /opt/1Password..."
sudo mkdir -p /opt/1Password
sudo mv 1password-*/* /opt/1Password

echo "[+] Fixing base permissions..."
sudo chown -R root:root /opt/1Password

sudo chmod 4755 /opt/1Password/chrome-sandbox || true

echo "[+] Setting up group..."
sudo groupadd onepassword 2>/dev/null || true
sudo chgrp onepassword /opt/1Password/1Password-BrowserSupport
sudo chmod g+s /opt/1Password/1Password-BrowserSupport

echo "[+] Creating symlink..."
sudo ln -sf /opt/1Password/1password /usr/local/bin/1password

echo "[+] Installing desktop entry + icons..."
sudo install -Dm644 /opt/1Password/resources/1password.desktop /usr/share/applications/1password.desktop || true
sudo cp -r /opt/1Password/resources/icons/* /usr/share/icons/ || true

echo "[+] Generating polkit policy..."

cd /opt/1Password

POLICY_OWNERS="$(cut -d: -f1,3 /etc/passwd | grep -E ':[0-9]{4}$' | cut -d: -f1 | head -n 10 | sed 's/^/unix-user:/' | tr '\n' ' ')"

export POLICY_OWNERS

if [ -f com.1password.1Password.policy.tpl ]; then
  eval "cat <<EOF
$(cat ./com.1password.1Password.policy.tpl)
EOF" | sudo tee com.1password.1Password.policy >/dev/null

  sudo install -Dm644 com.1password.1Password.policy \
    /usr/share/polkit-1/actions/com.1password.1Password.policy
fi

echo "[+] Ensuring final ownership safety..."
sudo chown -R root:root /opt/1Password
sudo chgrp onepassword /opt/1Password/1Password-BrowserSupport
sudo chmod g+s /opt/1Password/1Password-BrowserSupport
sudo chmod 4755 /opt/1Password/chrome-sandbox

echo "[+] Done. Launch with: 1password"
