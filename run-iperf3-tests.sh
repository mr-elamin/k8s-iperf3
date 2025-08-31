#!/bin/bash

# Namespace where the iperf3 DaemonSet is deployed
NAMESPACE="default"

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get the number of iperf3 server pods
NUM_PODS=$(kubectl get pods -n $NAMESPACE -l app=iperf3 --no-headers | wc -l)

# Iterate through each pod as the client
for ((i=0; i<NUM_PODS; i++)); do
  CLIENT_POD=$(kubectl get pods -n $NAMESPACE -l app=iperf3 -o jsonpath="{.items[$i].metadata.name}")
  CLIENT_POD_IP=$(kubectl get pod -n $NAMESPACE $CLIENT_POD -o jsonpath='{.status.podIP}')
  CLIENT_NODE=$(kubectl get pod -n $NAMESPACE $CLIENT_POD -o jsonpath='{.spec.nodeName}')
  CLIENT_NODE_IP=$(kubectl get pod -n $NAMESPACE $CLIENT_POD -o jsonpath='{.status.hostIP}')
  
  echo -e "======= Running iperf3 tests from client pod $CLIENT_POD (node ${GREEN}$CLIENT_NODE${NC}, pod IP $CLIENT_POD_IP, node IP $CLIENT_NODE_IP) ======="
  
  # Iterate through each pod as the server
  for ((j=0; j<NUM_PODS; j++)); do
    SERVER_POD=$(kubectl get pods -n $NAMESPACE -l app=iperf3 -o jsonpath="{.items[$j].metadata.name}")
    SERVER_POD_IP=$(kubectl get pod -n $NAMESPACE $SERVER_POD -o jsonpath='{.status.podIP}')
    SERVER_NODE=$(kubectl get pod -n $NAMESPACE $SERVER_POD -o jsonpath='{.spec.nodeName}')
    SERVER_NODE_IP=$(kubectl get pod -n $NAMESPACE $SERVER_POD -o jsonpath='{.status.hostIP}')
    
    echo "====================================== Client No. $((i + 1))/$NUM_PODS Server No. $((j + 1))/$NUM_PODS ======================================"
    echo -e "Client pod: $CLIENT_POD (node ${GREEN}$CLIENT_NODE${NC}, pod IP $CLIENT_POD_IP, node IP $CLIENT_NODE_IP)"
    echo -e "Server pod: $SERVER_POD (node ${RED}$SERVER_NODE${NC}, pod IP $SERVER_POD_IP, node IP $SERVER_NODE_IP)"
    echo "Running traceroute from client pod $CLIENT_POD to server pod $SERVER_POD (pod IP: $SERVER_POD_IP)"
    kubectl exec -n $NAMESPACE -it $CLIENT_POD -- traceroute $SERVER_POD_IP
    
    echo "Running iperf3 test from client pod $CLIENT_POD to server pod $SERVER_POD (pod IP: $SERVER_POD_IP)"
    kubectl exec -n $NAMESPACE -it $CLIENT_POD -- iperf3 -c $SERVER_POD_IP -p 5201 -t 30
  done
done