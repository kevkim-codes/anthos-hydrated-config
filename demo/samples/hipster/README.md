# Hipster


## Deploy Single Cluster

```bash

kubectl apply -f single-cluster
watch kubectl get pods
kubectl get svc istio-ingressgateway -n istio-system

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo http://${INGRESS_HOST}

```