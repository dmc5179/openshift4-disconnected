#!/bin/bash -xe

# This script will build an ollama image with models built into it
# The image can be saved and moved to an offline container registry

podman run -d -p 11434:11434 --name ollama docker.io/ollama/ollama:latest

# Import granite-code:8b model
curl -X POST http://127.0.0.1:11434/api/pull -d '{"name": "granite-code:8b"}'
# Import codellama:13b model
#curl -X POST http://127.0.0.1:11434/api/pull -d '{"name": "codellama:13b"}'
# Import llama3.2 model
#curl -X POST http://127.0.0.1:11434/api/pull -d '{"name": "llama3.2"}'

# Save the running container image as a new image
podman commit ollama quay.io/danclark/ollama:granite-code-8b

# Stop the running ollama container
podman stop ollama

# Things to do after building the image

# Push the container image to a repository
#podman push --authfile /home/danclark/quay-pull-secret.json quay.io/danclark/ollama:granite-code-8b

# Run the container
#podman run -d -p 11434:11434 --name new_ollama quay.io/danclark/ollama:granite-code-8b

# Save the container image to disk for transport
#skopeo copy containers-storage:quay.io/danclark/ollama:granite-code-8b docker-archive:ollama-granite-code-8b.tar

# Example on how to query ollama service with curl
#curl http://localhost:11434/api/generate -d '{"model": "llama3.2", "prompt": "Why is the sky blue?"}'

