#!/usr/bin/env bash
#
# Apply a single blueprint layer locally, the same way the CI pipeline does:
# resolve the S3 state bucket + DynamoDB lock table from the SSM backend-config
# parameter, init with the per-environment backend config, and apply the chosen
# compliance profile. Terraform runs with -parallelism=1 (parallel AWS-provider
# requests were observed to intermittently corrupt each other on the wire).
#
# Usage:
#   ./scripts/apply-module.sh <layer> <environment> <region> [compliance-profile]
#
# Examples:
#   ./scripts/apply-module.sh 01-network dev us-east-1 general
#   ./scripts/apply-module.sh 06-aurora dev us-east-1 hipaa
#
# NAMESPACE defaults to "eksblueprint-arc"; override with the NAMESPACE env var.
# For 03-github-runner, export TF_VAR_github_token (and TF_VAR_github_owner) first.
set -euo pipefail

LAYER="${1:?layer required, e.g. 04-eks}"
ENV="${2:-dev}"
REGION="${3:-us-east-1}"
PROFILE="${4:-$ENV}"                 # a compliance profile (general|hipaa|pci) or the env name
NS="${NAMESPACE:-eksblueprint-arc}"

DIR="modules/${LAYER}"
[ -d "$DIR" ] || { echo "no such layer: $DIR" >&2; exit 1; }
[ -f "${DIR}/tfvars/${PROFILE}.tfvars" ] || { echo "no tfvars: ${DIR}/tfvars/${PROFILE}.tfvars" >&2; exit 1; }

# Resolve the backend (bucket + lock table) from the SSM parameter bootstrap wrote.
BACKEND=$(aws ssm get-parameter --name "/${NS}/${ENV}/terraform/backend-config" \
            --query Parameter.Value --output text)
BUCKET=$(printf '%s' "$BACKEND" | python3 -c "import sys,json;print(json.load(sys.stdin)['bucket_name'])")
TABLE=$(printf  '%s' "$BACKEND" | python3 -c "import sys,json;print(json.load(sys.stdin)['dynamodb_name'])")

echo ">> ${LAYER}: init (backend s3://${BUCKET}) + apply (profile: ${PROFILE}, region: ${REGION})"
cd "$DIR"
terraform init -reconfigure \
  -backend-config="backend/config.${ENV}.hcl" \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="dynamodb_table=${TABLE}"
terraform apply -auto-approve -parallelism=1 \
  -var-file="tfvars/${PROFILE}.tfvars" \
  -var="region=${REGION}"
