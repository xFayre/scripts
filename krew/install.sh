#!/bin/bash

(
  set -x; cd "$(mktemp -d)" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" &&
  "$KREW" install krew
)

if ! grep --quiet --extended-regexp "^export KREW" ~/.bashrc; then
cat <<EOF >> ~/.bashrc
# KREW
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
EOF
fi

kubectl krew install ctx
kubectl krew install fuzzy
kubectl krew install ns
kubectl krew install pod-dive
