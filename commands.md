kubectl create ns ikigai

###

kubectl create configmap wso2is-config --from-file=deployment.toml=./deployment.toml -n ikigai

###

kubectl apply -f wso2-deployment.yaml -n ikigai
kubectl logs -f deploy/wso2is -n ikigai

###

kubectl apply -f wso2-service.yaml -n ikigai
kubectl get service -n ikigai

###

