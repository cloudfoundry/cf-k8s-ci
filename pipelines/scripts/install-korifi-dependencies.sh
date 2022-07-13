#!/bin/bash

set -euo pipefail

# shellcheck disable=SC1091
source korifi-ci/pipelines/scripts/common/gcloud-functions

echo "$GCP_SERVICE_ACCOUNT_JSON" >"$PWD/service-account.json"
export GOOGLE_APPLICATION_CREDENTIALS="$PWD/service-account.json"

gcloud-login
export-kubeconfig "$CLUSTER_NAME"

ip_addr="$(<terraform-output/result)"
pushd korifi
{
  ./scripts/install-dependencies.sh
  kubectl patch service envoy -n projectcontour -p "{\"spec\": { \"loadBalancerIP\": $ip_addr }}"
}
