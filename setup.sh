#!/bin/bash

set -e

# --- OS Detection and Dependency Installation ---
install_dependencies() {
    if ! command -v curl &> /dev/null; then
        echo "'curl' not found. Attempting to install..."
        if [ -f /etc/debian_version ]; then
            echo "Detected Debian-based OS."
            sudo apt-get update
            sudo apt-get install -y curl
        elif [ -f /etc/redhat-release ]; then
            echo "Detected Red Hat-based OS."
            if command -v dnf &> /dev/null; then
                sudo dnf install -y curl
            else
                sudo yum install -y curl
            fi
        else
            echo "Unsupported OS. Please install 'curl' manually and re-run this script."
            exit 1
        fi
    fi
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Docker not found. Installing Docker..."
  install_dependencies
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
  sudo usermod -aG docker $USER
  echo "-----------------------------------------------------"
  echo "Docker installed successfully."
  echo "IMPORTANT: You must log out and log back in for the 'docker' group changes to take effect."
  echo "Alternatively, you can run 'newgrp docker' in your current shell."
  echo "The script will now continue to start the services."
  echo "-----------------------------------------------------"
else
  echo "Docker is already installed."
fi

# Check if Docker Compose is available
if docker compose version &> /dev/null; then
  COMPOSE_CMD="docker compose"
else
  if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
  else
    echo "Neither 'docker compose' nor 'docker-compose' found. Please install Docker Compose V2."
    exit 1
  fi
fi

# Navigate to the directory where docker-compose.yml is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Start the services
echo "Starting AutoMonitoringStack services..."
$COMPOSE_CMD up -d

# Wait for services to be healthy
echo "Waiting for services to start (this may take a minute)..."
sleep 45

# Print access information
echo ""
echo "----------------------------------------"
echo "✅ Monitoring stack is running!"
echo "----------------------------------------"
echo "Grafana: http://localhost:3000 (admin/admin)"
echo "Prometheus: http://localhost:9090"
echo "Alertmanager: http://localhost:9093"
echo "Kibana: http://localhost:5601"
echo "Jaeger UI: http://localhost:16686"
echo ""
echo "To stop all services, run: $COMPOSE_CMD down"

echo "To view logs, run: $COMPOSE_CMD logs -f"

exit 0
