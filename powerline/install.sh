#!/bin/bash

# Update ~/.bashrc file
if ! grep --quiet --extended-regexp "powerline.sh" ~/.bashrc; then
cat <<EOF >> ~/.bashrc
if [ -f /usr/share/powerline/bindings/bash/powerline.sh ]; then
  powerline-daemon -q
  POWERLINE_BASH_CONTINUATION=1
  POWERLINE_BASH_SELECT=1
  source /usr/share/powerline/bindings/bash/powerline.sh
fi
EOF
fi

# Create a Directory
mkdir --parents ~/.config/powerline/

# Copy Powerline Config Default
cp /usr/share/powerline/config_files/config.json ~/.config/powerline/config.json

# Change Theme
sed 's/default_leftonly/default/g' ~/.config/powerline/config.json --in-place

# ~/.vimrc
cat <<EOF > ~/.vimrc
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
set laststatus=2
EOF
