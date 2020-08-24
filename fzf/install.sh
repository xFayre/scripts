#!/bin/bash
set -e

if [[ ! -e ~/.fzf ]]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
fi

~/.fzf/install --key-bindings --completion --update-rc

if ! grep --quiet --extended-regexp "^export FZF_" ~/.bashrc; then
cat <<EOF >> ~/.bashrc
# FZF
export FZF_DEFAULT_COMMAND="fd --type f --follow --exclude .git"
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
EOF
fi
