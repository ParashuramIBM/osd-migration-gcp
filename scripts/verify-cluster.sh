#!/bin/bash

set -e

echo "=== OpenShift Cluster Verification ==="

# Load cluster credentials
if [ ! -f "../terraform/cluster_credentials.json" ]; then
    echo "Error: cluster_credentials.json not found"
    exit 1
fi

KUBECONFIG=$(jq -r '.kubeconfig' ../terraform/cluster_credentials.json)
echo "$KUBECONFIG" > /tmp/kubeconfig.yaml
export KUBECONFIG=/tmp/kubeconfig.yaml

echo "1. Checking cluster version..."
oc version

echo "2. Checking node status..."
oc get nodes -o wide

echo "3. Checking cluster operators..."
oc get clusteroperators

echo "4. Checking pods in all namespaces..."
oc get pods --all-namespaces | grep -v Running | grep -v Completed || true

echo "5. Checking ingress controller..."
oc get svc -n openshift-ingress

echo "6. Checking storage classes..."
oc get storageclass

echo "7. Checking machine sets..."
oc get machinesets -n openshift-machine-api

echo "8. Checking cluster authentication..."
oc whoami

echo "=== Verification Complete ==="