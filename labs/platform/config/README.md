
# Prep 
Get cluster config repo

```shell
git clone https://github.com/cgrant/cluster_config

```

# Watch the cluster sync resources

Split screen
- Watch Cluster resources
- Apply sync


## Split screen

```shell
watch \
    "echo '## Prod1 Namespaces ##'; \
    kubectl --context prod1 get ns; \
    echo '\n\n## Prod2 Namespaces##'; \
    kubectl --context prod2 get ns; \
    echo '\n## bank-of-anthos pods  ##'; \
    kubectl --context prod2 get po -n bank-of-anthos"
```

## Apply Sync

```shell
kubectx prod2
kubectl apply -f config-management-operator.yaml 

kubectl apply -f acm-repo.yaml

```


## New Namespace

```shell
cd cluster_config/
NS=nginx

mkdir sample/namespaces/${NS}
cat <<EOF > sample/namespaces/${NS}/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ${NS}
  labels: 
    istio-injection: enabled
EOF


git add . && git commit -m "new NS" && git push origin stage

```

## Config Drift Management
kubectl delete ns ${NS}
kubectl delete deployment contacts -n bank-of-anthos

## NS Isolation
cp ../nginx.yaml ./sample/namespaces/${NS}
git add . && git commit -m "adding nginx" && git push origin stage