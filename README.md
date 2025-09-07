# AutoMonitoringStack

A comprehensive, Docker-based monitoring solution that is **fully auto-configured** and ready to run out of the box. This stack provides a powerful combination of tools for metrics and logs:

*   **Metrics Visualization:** Use **Grafana** to view pre-built dashboards for system metrics.
*   **Log Analysis and Long-Term Storage:** Leverage the **ELK Stack** (Elasticsearch, Logstash, Kibana) for centralized log aggregation, analysis, and long-term storage. Explore your logs visually in the **Kibana dashboard**.

The entire system is orchestrated with Docker Compose, making setup and management incredibly simple.

## Components

- **Prometheus** (`http://localhost:9090`): Metrics collection and time-series database
- **Grafana** (`http://localhost:3000`): Visualization and dashboards (default credentials: admin/admin)
- **Alertmanager** (`http://localhost:9093`): Alert management and routing
- **Node Exporter** (`http://localhost:9100`): Hardware and OS metrics
- **Blackbox Exporter** (`http://localhost:9115`): Probes endpoints over HTTP, HTTPS, etc.
- **Jaeger** (`http://localhost:16686`): Distributed tracing system
- **Redis** (`localhost:6379`): In-memory cache for Grafana
- **Elasticsearch** (`http://localhost:9200`): Log storage and search
- **Logstash** (`http://localhost:5044` for input): Log processing pipeline
- **Kibana** (`http://localhost:5601`): Log visualization

## Quick Start

1. Clone or download this repository
2. Run the setup script: `./setup.sh`
   - This will install Docker if not already present
   - Start all services in detached mode using Docker Compose

## User Guide

This guide provides detailed instructions on how to use and customize the monitoring stack.

### 1. Installation and Setup

The easiest way to get started is by using the provided setup script:

```bash
./setup.sh
```

This script will:
- Check for and install Docker if it's not already present.
- Start all services in the background using `docker-compose up -d`.

Alternatively, you can manually start the services if you already have Docker and Docker Compose installed:

```bash
docker-compose up -d
```

### 2. Accessing the Services

Once the stack is running, you can access the different components via your web browser:

- **Grafana:** `http://localhost:3000` (for visualizing metrics)
- **Prometheus:** `http://localhost:9090` (for querying metrics)
- **Alertmanager:** `http://localhost:9093` (for managing alerts)
- **Jaeger:** `http://localhost:16686` (for viewing traces)
- **Kibana:** `http://localhost:5601` (for exploring logs)
- **Elasticsearch:** `http://localhost:9200` (for direct access to log data)

### 3. Using Grafana for Visualization

Grafana is pre-configured with a Prometheus data source and a dashboard for Node Exporter metrics.

1.  **Log in to Grafana:**
    -   Navigate to `http://localhost:3000`.
    -   Use the default credentials:
        -   **Username:** `admin`
        -   **Password:** `admin`
    -   You will be prompted to change the password after your first login.

2.  **View the Dashboard:**
    -   Click on the "Dashboards" icon on the left sidebar.
    -   Go to "Browse" to see the "Node Exporter Full" dashboard, which displays system metrics like CPU, memory, and disk usage.

### 4. Monitoring Your Own Applications

To monitor your own application, you need to add it as a target for Prometheus to scrape.

1.  **Expose metrics from your application:** Your application must expose metrics in a Prometheus-compatible format. This is usually done by adding a client library to your application.

2.  **Add the target to Prometheus:**
    -   Open the `prometheus/prometheus.yml` file.
    -   Add a new job under the `scrape_configs` section. For example, to monitor an application running on the host machine at port `8080`:

    ```yaml
    - job_name: 'my-application'
      static_configs:
        - targets: ['host.docker.internal:8080']
    ```
    > **Note:** `host.docker.internal` is a special DNS name that resolves to the host machine's IP address from within a Docker container.

3.  **Restart Prometheus:**
    ```bash
    docker-compose restart prometheus
    ```

### 5. Managing Alerts

You can define custom alert rules in Prometheus and configure Alertmanager to send notifications.

1.  **Define Alert Rules:**
    -   Create a file named `alert_rules.yml` inside the `prometheus` directory.
    -   Add your alert rules to this file. For example:

    ```yaml
    groups:
    - name: example-alerts
      rules:
      - alert: InstanceDown
        expr: up == 0
        for: 1m
        labels:
          severity: "critical"
        annotations:
          summary: "Instance {{ $labels.instance }} down"
          description: "{{ $labels.job }} at {{ $labels.instance }} has been down for more than 1 minute."
    ```

2.  **Configure Alertmanager:**
    -   Open `alertmanager/alertmanager.yml`.
    -   Configure a receiver to send notifications to your preferred channel (e.g., Slack, PagerDuty, email). The default configuration sends alerts to a dummy webhook.

3.  **Restart Prometheus and Alertmanager:**
    ```bash
    docker-compose restart prometheus alertmanager
    ```

### 6. Configuring Alert Notifications (Telegram & Gmail)

The system supports sending alerts via Telegram and Gmail in addition to the default webhook.

#### Telegram Alert Setup

1. **Create a Telegram Bot:**
   - Message @BotFather on Telegram to create a new bot.
   - Follow the instructions to get your BOT_TOKEN.

2. **Get Your Chat ID:**
   - Start a chat with your bot or add the bot to a group.
   - Send a message to the bot/group.
   - Visit `https://api.telegram.org/bot<BOT_TOKEN>/getUpdates` to get the chat_id.

3. **Configure Environment Variables:**
   ```bash
   export TELEGRAM_BOT_TOKEN="your_bot_token_here"
   export TELEGRAM_CHAT_ID="your_chat_id_here"
   ```

4. **Restart Alertmanager:**
   ```bash
   docker-compose restart alertmanager
   ```

#### Gmail Alert Setup

1. **Enable 2FA on Gmail:**
   - Go to your Google account settings and enable 2-step verification.

2. **Generate App Password:**
   - Visit Google App Passwords.
   - Generate a password for "Mail".
   - Use this app password instead of your regular Gmail password.

3. **Configure Environment Variables:**
   ```bash
   export GMAIL_FROM="your_email@gmail.com"
   export GMAIL_TO="recipient_email@gmail.com"
   export GMAIL_USER="your_email@gmail.com"
   export GMAIL_APP_PASSWORD="your_16_char_app_password"
   ```

4. **Restart Alertmanager:**
   ```bash
   docker-compose restart alertmanager
   ```

**Note:** After setting environment variables, add them to your shell configuration (e.g., `~/.bashrc`) or create a `.env` file and use `docker-compose --env-file .env up -d`.

### 7. Log Management with the ELK Stack

The ELK Stack is pre-configured to automatically handle log processing and visualization.

1.  **Send Logs to Logstash:**
    -   The Logstash pipeline is set up to listen for log events on port `5044` using the Beats protocol.
    -   Configure your log shipper (like Filebeat) to send logs to `localhost:5044`.

2.  **Explore Logs in Kibana:**
    -   Navigate to `http://localhost:5601`.
    -   Kibana is set up to automatically find logs sent to Elasticsearch.
    -   Go to **Analytics > Discover** to view and search your logs. The `logstash-*` index pattern is automatically recognized.

### 8. Agent Connection Guide

This guide explains how to connect various monitoring agents and exporters to different endpoints in your AutoMonitoringStack.

#### Overview of Connection Endpoints

| Service | Protocol | Port | Purpose | Endpoint |
|---------|----------|------|---------|----------|
| Prometheus | HTTP | 9090 | Metrics scraping | `http://localhost:9090/metrics` |
| Logstash | TCP/Beats | 5044 | Log collection | `localhost:5044` |
| Jaeger | UDP/HTTP | 6831/16686/14268 | Trace collection | See details below |
| Blackbox Exporter | HTTP/POST | 9115 | Service probing | `http://localhost:9115/probe` |
| Elasticsearch | HTTP | 9200 | Log storage | `http://localhost:9200` |
| Redis | TCP | 6379 | Caching | `localhost:6379` |

#### 8.1 Connecting Prometheus Exporters

**Built-in Exporters:**
- **Node Exporter** (Already configured): Monitors host system metrics
- **Blackbox Exporter** (Already configured): Probes external services

**Adding Custom Exporters:**

1. **Deploy a new exporter:**
```bash
# Example: Adding MySQL Exporter
docker run -d --name mysql-exporter \
  -p 9104:9104 \
  -e DATA_SOURCE_NAME="mysql_monitor:password@(mysql:3306)/" \
  prom/mysqld-exporter

# Or add to docker-compose.yml
mysql-exporter:
  image: prom/mysqld-exporter
  ports:
    - "9104:9104"
  environment:
    - DATA_SOURCE_NAME="user:password@(mysql:3306)/"
```

2. **Add to Prometheus scrape config:**
```yaml
# Add to prometheus/prometheus.yml
scrape_configs:
  - job_name: 'mysql'
    static_configs:
      - targets: ['mysql-exporter:9104']
```

3. **Restart Prometheus:**
```bash
docker-compose restart prometheus
```

#### 8.2 Connecting Log Shipping Agents (ELK Stack)

**Using Filebeat:**

1. **Install Filebeat on target machine:**
```bash
# On Linux:
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.11.1-amd64.deb
sudo dpkg -i filebeat-8.11.1-amd64.deb

# Or on macOS:
brew tap elastic/tap
brew install elastic/tap/filebeat-full
```

2. **Configure Filebeat:**
```yaml
# /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/nginx/*.log
    - /var/log/apache2/*.log
    - /var/log/application.log

output.logstash:
  hosts: ["localhost:5044"]
```

3. **Start Filebeat:**
```bash
sudo systemctl enable filebeat
sudo systemctl start filebeat
```

**Using Metricbeat for System Metrics:**

```yaml
# /etc/metricbeat/metricbeat.yml
metricbeat.modules:
- module: system
  metricsets:
    - cpu
    - load
    - memory
    - network
    - process
    - process_summary
  enabled: true
  period: 10s
  processes: ['.*']

output.elasticsearch:
  hosts: ["localhost:9200"]
```

#### 8.3 Connecting Tracing Agents (Jaeger)

**Jaeger supports multiple trace ingestion methods:**

1. **OTLP (Recommended):**
```bash
# Using OpenTelemetry Collector
OTEL_EXPORTER_OTLP_ENDPOINT="localhost:14268" \
OTEL_SERVICE_NAME="my-service" \
./your-application
```

2. **Jaeger Client Libraries:**
```python
from jaeger_client import Config

def init_jaeger(service_name='my-service'):
    config = Config(
        config={
            'sampler': {'type': 'const', 'param': 1},
            'logging': True,
        },
        service_name=service_name,
        validate=True,
    )
    return config.initialize_tracer()

tracer = init_jaeger('my-service')
```

3. **Envoy Proxy Configuration:**
```yaml
# envoy.yaml
tracing:
  http:
    name: envoy.tracers.zipkin
    typed_config:
      "@type": type.googleapis.com/config.trace.v3.ZipkinConfig
      collector_cluster: jaeger
      collector_endpoint: "/api/traces"
      trace_id_128bit: true
      shared_span_context: false

static_resources:
  clusters:
  - name: jaeger
    connect_timeout: 1.25s
    type: STRICT_DNS
    lb_policy: ROUND_ROBIN
    hosts:
    - socket_address:
        address: localhost
        port_value: 9411
```

#### 8.4 Connecting Application Metrics

**Using Prometheus Client Libraries:**

1. **Python Application:**
```python
from prometheus_client import start_http_server, Counter
import time

REQUEST_COUNT = Counter('request_count', 'App Request Count')

start_http_server(8080)

while True:
    REQUEST_COUNT.inc()
    time.sleep(1)
```

2. **Java Application:**
```java
import io.prometheus.client.hotspot.DefaultExports;
import io.prometheus.client.springweb.EnableSpring-bootMetricsCollector;
import org.springframework.boot.SpringApplication;

@SpringBootApplication
@EnableSpring_bootMetricsCollector
public class Application {
    public static void main(String[] args) {
        DefaultExports.initialize();
        SpringApplication.run(Application.class, args);
    }
}
```

3. **Go Application:**
```go
package main

import (
    "net/http"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    requestCount = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total HTTP requests",
        },
        []string{"method", "endpoint"},
    )
)

func init() {
    prometheus.Register(requestCount)
}

func main() {
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":8080", nil)
}
```

#### 8.5 Connecting Blackbox Probes

**Testing HTTP/HTTPS endpoints:**

```bash
# Test a website
curl "http://localhost:9115/probe?target=https://httpbin.org&module=http_2xx"

# Test TCP connectivity
curl "http://localhost:9115/probe?target=tcp://google.com:80&module=tcp_connect"
```

**Add custom probes to Prometheus:**

```yaml
# Add to prometheus/prometheus.yml
scrape_configs:
  - job_name: 'blackbox_http'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - https://example.com
        - https://github.com
        - https://prometheus.io
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115
```

#### 8.6 Connecting SNMP Devices

**Configure SNMP Exporter:**

1. **snmp.yml configuration:**
```yaml
# /etc/snmp_exporter/snmp.yml
mydevice:
  walk:
  - 1.3.6.1.2.1.1  # System
  - 1.3.6.1.2.1.2  # Interfaces
  get:
  - 1.3.6.1.2.1.1.3.0  # Uptime
  metrics:
  - name: device_info
    oid: 1.3.6.1.2.1.1.1.0
    type: DisplayString
```

2. **Add to docker-compose.yml:**
```yaml
snmp-exporter:
  image: prom/snmp-exporter
  ports:
    - "9116:9116"
  volumes:
    - ./snmp_exporter/snmp.yml:/etc/snmp_exporter/snmp.yml
```

3. **Configure in Prometheus:**
```yaml
# prometheus/prometheus.yml
scrape_configs:
  - job_name: 'snmp'
    static_configs:
      - targets: ['192.168.1.10']  # SNMP device IP
    metrics_path: /snmp
    params:
      module: [mydevice]
    relabel_configs:
      - target_label: __address__
        replacement: snmp-exporter:9116
```

### 9. Stopping and Cleaning Up

-   To **stop** all the services without deleting any data:
    ```bash
    docker-compose down
    ```

-   To **stop** the services and **delete all data** (including metrics and logs):
    ```bash
    docker-compose down -v
    ```

## Prerequisites

- Linux/MacOS or WSL
- No manual Docker installation required - the setup script handles it

## File Structure

```
AutoMonitoringStack/
├── docker-compose.yml          # Orchestration of all services
├── setup.sh                    # Automated setup script
├── prometheus/
│   └── prometheus.yml          # Prometheus configuration with metrics scraping
├── alertmanager/
│   └── alertmanager.yml        # Alertmanager configuration for webhook notifications
├── grafana/
│   ├── provisioning/
│   │   ├── datasources/
│   │   │   └── datasources.yml     # Grafana datasource provisioning
│   │   └── dashboards/
│   │       └── dashboards.yml      # Dashboard provisioning configuration
│   └── dashboards/
│       └── node-exporter-dashboard.json # Sample dashboard for Node Exporter
├── elk/
│   └── logstash.conf            # Logstash pipeline configuration
```

## Services Overview

### Prometheus
- Scrapes metrics from:
  - Itself (runtime metrics)
  - Alertmanager (alert states)
  - Node Exporter (system metrics)
  - ELK components (health metrics)
- Rules file: `alert_rules.yml` (can be added for custom alerts)

### Grafana
- Pre-configured datasources:
  - Prometheus (default)
  - Elasticsearch
- Pre-loaded dashboard:
  - Node Exporter Full dashboard with CPU, Memory, and Disk usage
- **Caching**: Uses Redis for improved performance.

### ELK Stack
- **Logstash**: Auto-configured pipeline processes logs from Beats (port 5044).
- **Elasticsearch**: Provides scalable, long-term storage for logs in daily indices (`logstash-*`).
- **Kibana**: Offers a powerful dashboard for exploring, visualizing, and searching your logs.

### Alertmanager
- Configured with webhook routing to `http://127.0.0.1:5001` (can be modified for actual webhook service)
- Supports alert grouping and inhibition rules

## Management Commands

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker-compose logs -f

# Restart specific service
docker-compose restart grafana

# Scale a service (example)
docker-compose up -d --scale node-exporter=2
```

## Customization

### Adding Custom Alerts
Edit `prometheus/prometheus.yml` and add rules to `alert_rules.yml`:

```yaml
groups:
- name: example
  rules:
  - alert: HighRequestLatency
    expr: http_request_duration_seconds{quantile="0.5"} > 0.5
    for: 10m
    labels:
      severity: warning
    annotations:
      summary: "High request latency"
```

### Modifying Dashboards
- Add new dashboards to `grafana/dashboards/`
- Update `grafana/provisioning/dashboards/dashboards.yml` if needed

### Logstash Pipeline
Modify `elk/logstash.conf` to adjust filters, inputs, or outputs.

## Security Note

This setup uses default configurations and simple authentication for demonstration:
- Grafana admin/admin (change after first login)
- Elasticsearch without X-Pack security (not production-ready)
- No TLS/SSL certificates

For production use, enable security features in each component.

## Troubleshooting

- If ports are already in use, modify `docker-compose.yml` port mappings
- For permission issues, ensure current user is in the `docker` group
- Check service health: `docker-compose ps`
- View individual service logs: `docker-compose logs <service_name>`

## Contributing

Feel free to submit issues and enhancement requests!
