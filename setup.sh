#!/bin/bash
# Script to deploy WSO2 IS 7.0.0 for local Kubernetes

NAMESPACE="wso2is-local"
CONFIG_SOURCE_FILE="deployment.toml"
CONFIGMAP_NAME="wso2is-config"
MANIFEST_FILE="wso2is-manifest.yaml"

echo "Applying WSO2 IS manifests to namespace '${NAMESPACE}'..."

# Ensure namespace exists
kubectl get namespace ${NAMESPACE} > /dev/null 2>&1 || kubectl create namespace ${NAMESPACE}

echo "Creating/Updating ConfigMap '${CONFIGMAP_NAME}' from '${CONFIG_SOURCE_FILE}'..."
# This command creates the CM if it doesn't exist, or updates it if it does.
kubectl create configmap ${CONFIGMAP_NAME} --from-file=${CONFIG_SOURCE_FILE} \
  -n ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
# Check if ConfigMap creation was successful
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to create/update ConfigMap ${CONFIGMAP_NAME}. Aborting."
    exit 1
fi
# ------------------------

# Apply the rest of the manifests (Namespace, PVC, Deployment, Service)
echo "Applying resources from ${MANIFEST_FILE}..."
kubectl apply -f ${MANIFEST_FILE}

echo ""
echo "Waiting up to 5 minutes for deployment rollout to finish..."
kubectl rollout status deployment/wso2is -n ${NAMESPACE} --timeout=5m

if [ $? -eq 0 ]; then
  echo ""
  echo "Deployment successfully rolled out."
  echo "You can check status:"
  echo "  kubectl get pods,svc,pvc -n ${NAMESPACE}"
  echo ""
  # Adjust port based on deployment.toml offset and Service definition (default 9453)
  ACCESS_PORT="9453"
  echo "Access the WSO2 IS Console (allow time for LoadBalancer):"
  echo "  https://localhost:${ACCESS_PORT}/console"
  echo "  Login: admin / admin"
else
  echo ""
  echo "Deployment rollout failed or timed out."
  echo "Check pod status and logs:"
  echo "  kubectl get pods -n ${NAMESPACE}"
  echo "  kubectl logs -f deployment/wso2is -n ${NAMESPACE}"
fi

exit $?