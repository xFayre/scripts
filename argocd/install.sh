#!/bin/bash
SECONDS=0

# Install ArgoCD on a new minikube cluster

KUBERNETES_BASE_VERSION=$(apt-cache madison kubeadm | head -1 | awk -F '|' '{ print $2 }' | tr -d ' ')
KUBERNETES_VERSION="${KUBERNETES_BASE_VERSION%-*}"

echo "Kubernetes version: ${KUBERNETES_VERSION}"

export MINIKUBE_IN_STYLE=false && \
minikube start \
  --kubernetes-version "v${KUBERNETES_VERSION}" \
  --driver=docker \
  --network-plugin=cni

kubectl config use-context minikube

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

for deploymentName in $(kubectl -n kube-system get deploy -o name); do
   echo "Waiting for: ${deploymentName}"

   kubectl \
     -n kube-system \
     wait \
     --for condition=available \
     --timeout=90s \
     ${deploymentName};
done

kubectl create namespace argocd

kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

if ! which argocd &> /dev/null; then
  echo "Need to download and install argocd CLI..."

  VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

  echo "Downloading version: ${VERSION}"

  sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64

  sudo chmod +x /usr/local/bin/argocd
fi

for deploymentName in $(kubectl -n argocd get deploy -o name); do
   echo "Waiting for: ${deploymentName}"

   kubectl \
     -n argocd \
     wait \
     --for condition=available \
     --timeout=120s \
     ${deploymentName};
done

kubectl apply -n argocd -f argocd-server-service.yaml

ARGOCD_INITIAL_PASSWORD=$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d '/' -f 2)
ARGOCD_URL=$(minikube service argocd-server -n argocd --url | grep 32443 | sed "s/http:\/\///")

clear && \
echo "ARGOCD_URL...............: ${ARGOCD_URL}" && \
echo "ARGOCD_INITIAL_PASSWORD..: ${ARGOCD_INITIAL_PASSWORD}"

argocd login \
  ${ARGOCD_URL} \
  --username admin \
  --password "${ARGOCD_INITIAL_PASSWORD}" \
  --insecure

argocd account update-password \
  --account admin \
  --current-password "${ARGOCD_INITIAL_PASSWORD}" \
  --new-password "anystrongpassword"


kubectl create ns dev

argocd repo add git@github.com:xFayre/argocd.git --ssh-private-key-path ~/.ssh/id_rsa
argocd repo add --insecure-skip-server-verification https://github.com/xFayre/argocd.git

argocd app create nginx \
  --repo https://github.com/xFayre/argocd.git \
  --path nginx \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace dev

argocd app list

argocd app get nginx

argocd app sync nginx

argocd app set nginx --sync-policy automated
argocd app set nginx --auto-prune
argocd app set nginx --self-heal

for deploymentName in $(kubectl -n dev get deploy -o name); do
   echo "Waiting for: ${deploymentName}"

   kubectl \
     -n dev \
     wait --for condition=available \
     --timeout=90s \
     ${deploymentName};
done

curl $(minikube service nginx -n dev --url) -Is | head -2

elapsed ${SECONDS}