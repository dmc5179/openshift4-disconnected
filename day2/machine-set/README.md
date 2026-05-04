#

## Spot instances

helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-node-termination-handler \
  --namespace kube-system \
  --set enableSqsTerminationDraining=false \
  --set heartbeatInterval=1000 \
  --set heartbeatUntil=4500 \
  --set nodeSelector."node-role\\.kubernetes\\.io/worker"="" \
  --set deleteLocalData=true \
  --set awsRegion=${AWS_DEFAULT_REGION} \
  eks/aws-node-termination-handler
