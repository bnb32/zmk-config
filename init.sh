#!/bin/bash

bash <(curl -L https://nixos.org/nix/install) --no-daemon
source "/home/$USER/.nix-profile/etc/profile.d/nix.sh"
nix profile install nixpkgs#direnv nixpkgs#nix-direnv --extra-experimental-features nix-command --extra-experimental-features flakes
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
mkdir -p ~/.config/direnv
echo "source $HOME/.nix-profile/share/nix-direnv/direnvrc" >> ~/.config/direnv/direnvrc
source ~/.bashrc

cd "$HOME/repos/zmk-config"
pipx install rust-just keymap-drawer zmk west
direnv allow
just init
