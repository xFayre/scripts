#!/bin/bash
set -e 

VERSION="0.6.2"

TAR_FILE="ytop-${VERSION}-x86_64-unknown-linux-gnu.tar.gz"

wget "https://github.com/cjbassi/ytop/releases/download/0.6.2/${TAR_FILE}"

[ ! -e ~/bin ] && mkdir ~/bin

tar xvf "${TAR_FILE}" && \
mv ytop ~/bin/ && \
rm "${TAR_FILE}"

mkdir -p ~/.config/ytop/

cp ./monokai.json ~/.config/ytop/monokai.json

if ! grep --quiet --extended-regexp "^export YTOP" ~/.bashrc; then
cat <<EOF >> ~/.bashrc
## YTOP
export YTOP_HOME="~/bin/ytop:$PATH"
alias ytop='~/bin/ytop -c monokai'
EOF
fi