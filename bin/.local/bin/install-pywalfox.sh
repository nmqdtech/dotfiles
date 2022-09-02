#/bin/sh

set -eu
xi python3-pip python3-pipx
pipx install pywalfox

if $BROWSER=librewolf;
	pywalfox install --manifest-path ~/.mozilla/native-messaging-hosts
    --profile-path  ~/.config/librewolf/librewolf
else
	pywalfox install
fi

