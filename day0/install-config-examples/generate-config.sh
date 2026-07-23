#!/usr/bin/env bash

set -euo pipefail

# Check for required tools
for cmd in aws yq curl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: Required tool '$cmd' is not installed." >&2
        exit 1
    fi
done

# Verify input
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <VPC_ID>"
    exit 1
fi

VPC_ID="$1"
TEMPLATE_URL="https://raw.githubusercontent.com/dmc5179/openshift4-disconnected/refs/heads/master/day0/install-config-examples/install-config.yaml.existingvpc"
OUTPUT_FILE="install-config.yaml"

echo "Step 1: Fetching the base install-config template..."
curl -sS "$TEMPLATE_URL" -o "$OUTPUT_FILE"

echo "Step 2: Querying AWS for Route53 base domain..."
# Assumes exactly one public hosted zone exists
BASE_DOMAIN=$(aws route53 list-hosted-zones \
    --query "HostedZones[?Config.PrivateZone==\`false\`].Name" \
    --output text | sed 's/\.$//')

if [ -z "$BASE_DOMAIN" ]; then
    echo "Error: No public Route53 hosted zone found." >&2
    exit 1
fi
echo "Found base domain: $BASE_DOMAIN"

echo "Step 3: Finding private and public subnets in VPC $VPC_ID..."
# Fetch subnets matching "private" in the Name tag
PRIVATE_SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=*private*" \
    --query "Subnets[*].SubnetId" \
    --output text)

# Fetch subnets matching "public" in the Name tag
PUBLIC_SUBNETS=$(aws ec2 describe-subnets \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=*public*" \
    --query "Subnets[*].SubnetId" \
    --output text)

# Combine and convert to a space-separated string for yq ingestion
ALL_SUBNETS="$PRIVATE_SUBNETS $PUBLIC_SUBNETS"

# Clean up whitespace
ALL_SUBNETS=$(echo "$ALL_SUBNETS" | xargs)

if [ -z "$ALL_SUBNETS" ]; then
    echo "Error: No subnets found with 'private' or 'public' in their Name tags." >&2
    exit 1
fi

echo "Found subnets: $ALL_SUBNETS"

echo "Step 4: Updating local install-config.yaml..."

# 1. Update the baseDomain field
# 2. Clear out the stub subnets array and inject our newly found subnet list
yq -y -i --arg domain "${BASE_DOMAIN}" '.baseDomain = $domain' "$OUTPUT_FILE"
yq -y -i '.platform.aws.vpc.subnets = []' "$OUTPUT_FILE"

# Append each subnet as a distinct item in the platform.aws.vpc.subnets array
#for subnet in $ALL_SUBNETS; do
#    yq eval -i ".platform.aws.vpc.subnets += [\"$subnet\"]" "$OUTPUT_FILE"
#done

for subnet in $ALL_SUBNETS; do
    yq -y -i --arg net "${subnet}" '.platform.aws.vpc.subnets += [$net]' "$OUTPUT_FILE"
done

echo "Success! Modified config saved to $OUTPUT_FILE"
