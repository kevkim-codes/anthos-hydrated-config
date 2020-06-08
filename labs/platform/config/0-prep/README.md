tf init && tf apply
kubectx
kubectx <new_name>=.
    - dev stage prod

kubectl apply -f config-management-operator.yaml --context stage