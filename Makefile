# Use microk8s kubectl and microk8s docker
KUBECTL=kubectl
DOCKER=docker
KUBE=microk8s

APP_NAME=github.com/creotiv/sidecar-demo
IMAGE_NAME=$(APP_NAME):latest
NAMESPACE=default

.PHONY: k8s-up k8s-config k8s-down build deploy clean bench urls

export KUBECONFIG := "$(HOME)/.kube/config:$(HOME)/.kube/microk8s-config
NODE_IP := $(shell microk8s kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
export NODE_IP

# Start MicroK8s with required addons
k8s-up:
	$(KUBE) start
	$(KUBE) enable dns hostpath-storage registry

k8s-config:
	mkdir -p $(HOME)/.kube
	$(KUBE) config > $(HOME)/.kube/microk8s-config

# Stop MicroK8s
k8s-down:
	$(KUBE) stop

# Build Docker image using MicroK8s Docker daemon
build:
	$(DOCKER) build -t $(IMAGE_NAME) .
	$(DOCKER) save $(IMAGE_NAME) > app.tar
	multipass transfer app.tar microk8s-vm:/tmp/app.tar
	$(KUBE) images import /tmp/app.tar 
	$(KUBE) ctr images ls | grep demo

# Deploy app and monitoring stack
deploy: build
	$(KUBECTL) apply -f deploy/app.yml
	$(KUBECTL) apply -f deploy/prometheus.yml
	$(KUBECTL) apply -f deploy/loki.yml

restart:
	$(KUBECTL) rollout restart deployment/go-echo-app

# Delete all deployed resources
clean:
	$(KUBECTL) delete -f deploy/app.yml || true
	$(KUBECTL) delete -f deploy/prometheus.yml || true
	$(KUBECTL) delete -f deploy/loki.yml || true

urls:
	@echo "Forwarding ports for access (run these in separate terminals):"
	@echo "Web server:  http://$(NODE_IP):30000"
	@echo "Envoy Proxy: http://$(NODE_IP):30005"
	@echo "Prometheus:  http://$(NODE_IP):30002"
	@echo "Grafana:     http://$(NODE_IP):30007"

# run k6 bench
bench:
	k6 run k6.js
