.PHONY: build test lint security-scan docker-build docker-push

SERVICE_NAME := ${{ values.serviceName }}
IMAGE_REGISTRY ?= quay.io
IMAGE_ORG ?= my-org
IMAGE_TAG ?= latest
IMAGE := $(IMAGE_REGISTRY)/$(IMAGE_ORG)/$(SERVICE_NAME):$(IMAGE_TAG)

build:
	@echo "Building $(SERVICE_NAME)..."
	# Add your build commands here

test:
	@echo "Running tests for $(SERVICE_NAME)..."
	# Add your test commands here

lint:
	@echo "Running linters for $(SERVICE_NAME)..."
	# Linting configuration is in .linting/
	# Add your lint commands here

security-scan:
	@echo "Running security scan for $(SERVICE_NAME)..."
	# Security config is in .security/
	# Add your security scan commands here

docker-build:
	podman build -t $(IMAGE) .

docker-push:
	podman push $(IMAGE)
