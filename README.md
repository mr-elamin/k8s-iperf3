
### README

# iperf3 Network Benchmarking in Kubernetes

This repository contains the necessary files to deploy and run `iperf3` for network benchmarking in a Kubernetes cluster. The setup includes a DaemonSet to deploy `iperf3` server pods on each node and a script to run `iperf3` tests between these pods.

## Contents

- **Dockerfile**: Builds a Debian-based image with `iperf3` installed.
- **DaemonSet YAML**: Deploys `iperf3` server pods on each node in the Kubernetes cluster.
- **Benchmark Script**: A Bash script to run `iperf3` tests between the deployed pods.

## How to Use

### 1. Clone the Repository

First, clone the repository from GitHub:

```sh
git clone https://github.com/mr-elamin/k8s-iperf3.git
cd k8s-iperf3
```

### 2. Deploy the DaemonSet

Apply the DaemonSet YAML to deploy `iperf3` server pods on each node in your Kubernetes cluster. The image can be pulled from the public registry:

```sh
kubectl apply -f daemonSet-iperf3.yaml
```

### 3. Update the Namespace in the Script

Ensure that the namespace in which the `iperf3` DaemonSet was deployed matches the namespace specified in the script. By default, the script uses the default namespace. If you deployed the DaemonSet in a different namespace, update the `NAMESPACE` variable in the run-iperf3-tests.sh script accordingly. You can find the line to change [here](https://github.com/mr-elamin/k8s-iperf3/blob/b43b04c3cb46dd48db297fd2db940b13cedb2d9c/run-iperf3-tests.sh#L4):
```bash
# Namespace where the iperf3 DaemonSet is deployed
NAMESPACE="your-namespace"
```

### 4. Run the Benchmark Script

Make the script executable and then execute it to run `iperf3` tests between the deployed pods:

```sh
chmod +x run-iperf3-tests.sh
./run-iperf3-tests.sh
```

## Understanding the Results

The benchmark script will run `iperf3` tests between all the `iperf3` server pods deployed on each node. The output will include:

- **Client and Server Pod Information**: Details about the client and server pods, including their node and IP addresses.
- **Traceroute Output**: The network path from the client pod to the server pod.
- **iperf3 Test Results**: The bandwidth, transfer rate, and retransmissions for each test.

### Key Metrics:

- **Transfer**: The total amount of data transferred during the test.
- **Bitrate**: The average data transfer rate (bandwidth) during the test.
- **Retr**: The number of retransmissions, indicating packet loss or network issues.

### Example Output:

```sh
Client pod: iperf3-server-abc123 (node kube-node-1, pod IP 10.0.0.1, node IP 192.168.1.1)
Server pod: iperf3-server-def456 (node kube-node-2, pod IP 10.0.0.2, node IP 192.168.1.2)
Running traceroute from client pod iperf3-server-abc123 to server pod iperf3-server-def456 (pod IP: 10.0.0.2)
traceroute to 10.0.0.2 (10.0.0.2), 30 hops max, 60 byte packets
 1  10.0.0.2 (10.0.0.2)  0.123 ms  0.456 ms  0.789 ms

Running iperf3 test from client pod iperf3-server-abc123 to server pod iperf3-server-def456 (pod IP: 10.0.0.2)
Connecting to host 10.0.0.2, port 5201
[  5] local 10.0.0.1 port 5201 connected to 10.0.0.2 port 5201
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  1.25 GBytes  1.07 Gbits/sec  0             sender
[  5]   0.00-10.00  sec  1.25 GBytes  1.07 Gbits/sec                  receiver
```

### Interpreting the Results:

- **High Bitrate**: Indicates good network performance.
- **Low Retransmissions**: Indicates a stable and reliable network connection.
- **Consistent Results**: Across multiple tests, consistent results indicate a well-performing network.

By following these steps, you can benchmark the network performance within your Kubernetes cluster and gain insights into the network's reliability and capacity.
