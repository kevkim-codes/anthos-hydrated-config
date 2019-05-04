


# Hipster Single Cluster
```
#kubectl apply -f samples/hipster/single-cluster
kubectl apply -f samples/hipster/single-cluster/kubernetes-manifests.yaml
watch kubectl get po
kubectl get service/frontend-external

```


# Hipster Multi Cluster

```
kubectl apply -f samples/hipster/cluster1 
kubectl apply -f samples/hipster/cluster2 


```

# CSM Notes

```
bash <( gsutil cat gs://csm-alpha-artifacts/quickstart/csm-alpha-onboard.sh )
bash <( gsutil cat gs://csm-alpha-artifacts/quickstart/csm-alpha-cleanup.sh )
```

```
kubectl get pods --context=central
watch kubectl get pods --context=west
kubectx central
kubectl get pods
kubectl get svc istio-ingressgateway -n istio-system


export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo http://${GATEWAY_URL}/productpage

export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
```






# Bookinfo

```
kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl apply -f samples/bookinfo/platform/kube/bookinfo-add-serviceaccount.yaml

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml
kubectl get gateway
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].port}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].port}')
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo http://${GATEWAY_URL}/productpage

samples/bookinfo/platform/kube/cleanup.sh
```
