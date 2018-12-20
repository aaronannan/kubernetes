#!/bin/bash
cd /home/ubuntu/
/rke up --config /home/ubuntu/cluster.yml
export KUBECONFIG=/home/ubuntu/kube_config_cluster.yml
sleep 3m
kubectl get nodes
kubectl get cs
kubectl -n kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
sudo snap install helm --classic
sleep 3m
/snap/bin/helm version
/snap/bin/helm init --service-account tiller
kubectl -n kube-system  rollout status deploy/tiller-deploy
/snap/bin/helm version
/snap/bin/helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
/snap/bin/helm install rancher-stable/rancher --name rancher --namespace cattle-system --set hostname=rancher.tusimple.io --set tls=external
kubectl -n cattle-system rollout status deploy/rancher

echo "apiVersion: v1
kind: Service
metadata:
  annotations:
  labels:
    app: rancher
    chart: rancher-2018.12.1
    heritage: Tiller
    release: rancher
  name: rancher-public
  namespace: cattle-system
spec:
  externalTrafficPolicy: Cluster
  ports:
  - nodePort: 30569
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: rancher
  sessionAffinity: None
  type: NodePort
status:
  loadBalancer: {}" > loadBalancer.yml

kubectl -n cattle-system create -f loadBalancer.yml
