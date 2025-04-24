#!/bin/bash
# Script to tear down WSO2 IS 7.0.0 deployment

NAMESPACE="wso2is-local"
CONFIGMAP_NAME="wso2is-config"
MANIFEST_FILE="wso2is-manifest.yaml"

echo "Deleting WSO2 IS resources from namespace '${NAMESPACE}'..."

# Delete resources defined in the manifest (Namespace, Deployment, Service, PVC)
kubectl delete -f ${MANIFEST_FILE} --ignore-not-found=true --wait=false

# Explicitly delete the ConfigMap created by the setup script
echo "Deleting ConfigMap ${CONFIGMAP_NAME}..."
kubectl delete configmap ${CONFIGMAP_NAME} -n ${NAMESPACE} --ignore-not-found=true

# Optional: Delete namespace (uncomment if desired)
echo "Deleting namespace ${NAMESPACE}..."
kubectl delete namespace ${NAMESPACE} --ignore-not-found=true --wait=true

echo ""
echo "Teardown complete."
echo "Note: The actual persistent data directory created by the PVC"
echo "might still exist on your host system (check Rancher Desktop docs/settings)."