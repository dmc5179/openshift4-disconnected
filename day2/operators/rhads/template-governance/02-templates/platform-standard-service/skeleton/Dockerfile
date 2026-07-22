FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

LABEL name="${{ values.serviceName }}" \
      description="${{ values.description }}" \
      io.k8s.display-name="${{ values.serviceName }}" \
      io.openshift.tags="platform-managed"

WORKDIR /app

COPY . .

USER 1001

EXPOSE 8080

CMD ["./start.sh"]
