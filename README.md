
# Go Echo Sidecar Demo

This project demonstrates:
- Building a Go Echo web server with metrics and logging
- Dockerizing the server
- Deploying to Kubernetes with sidecars for metrics, logging, and traffic control
- Integrating with Prometheus and Grafana Loki

## Instalation

### Mac
```bash
# download Lense, K8S dashboard
https://k8slens.dev/download

brew install ubuntu/microk8s/microk8s
brew install k6
microk8s install
microk8s status --wait-ready
```

## Usage

### Start local Kubernetes:
`make k8s-up`

### Build, push, and deploy:
`make deploy`

### Run benchmark
`make bench`

### Check prometheus metrics

1. Get urls: `make urls`
2. Open Prometheus
3. Enter `echo_requests_total`

### Check Loki logs

1. Get urls: `make urls`
2. Open Grafana (admin:admin)
3. Open `Explore->Query`
4. Enter 
```
{job="go-echo"} |= ``
```

### Clean up:
`make clean`
`make k8s-down`

## Sidecars

- **Promtail**: ships logs to Loki
- **Traffic-proxy**: controls traffic (simulate latency, loss)
- **Metrics-sidecar**: exposes metrics for Prometheus

## License

MIT
