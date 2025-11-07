#!/bin/bash
set -e # Para o script se qualquer comando falhar

# 1. Atualiza o sistema
yum update -y

# 2. Instala o Docker
yum install docker -y
systemctl start docker
usermod -aG docker ec2-user

# 3. Instala o kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 4. Instala o Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# 5. Instala o Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# # Inicie o Cluster Kubernetes: (Dentro do SSH)
# minikube start --driver=docker

# # Adicione o Repositório do NGINX: (O único que a sua rede permitiu)
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update

# # Instale o NGINX com Helm:
# helm install nginx-ingress ingress-nginx/ingress-nginx

# kubectl get pods -w

# # Terminal 1 (Onde você já está): Execute o port-forward na nossa porta "limpa", a 8081.
# kubectl port-forward --namespace default service/nginx-ingress-ingress-nginx-controller 8081:80 --address 0.0.0.0