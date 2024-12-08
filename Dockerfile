# Use a smaller Debian-based image
FROM debian:bullseye-slim

# Install iperf3 and traceroute
RUN apt-get update && apt-get install -y iperf3 traceroute && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the startup scripts
COPY start-iperf3-server.sh /usr/local/bin/start-iperf3-server.sh
COPY start-iperf3-client.sh /usr/local/bin/start-iperf3-client.sh

# Make the scripts executable
RUN chmod +x /usr/local/bin/start-iperf3-server.sh /usr/local/bin/start-iperf3-client.sh

# Expose the default iperf3 port
EXPOSE 5201

# Default entrypoint
ENTRYPOINT ["/usr/local/bin/start-iperf3-server.sh"]