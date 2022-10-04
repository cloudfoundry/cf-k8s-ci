#!/bin/bash

set -euo pipefail

KBLD_CONFIG_DIR="$PWD/korifi-ci/build/kbld/release"
VALUES_BASE="$PWD/korifi-ci/build/overlays/acceptance"
COMMIT_SHA=$(cat korifi/.git/ref)
VERSION="dev-$(cat korifi-release-version/version)-$COMMIT_SHA"

source korifi-ci/pipelines/scripts/common/gcloud-functions
source korifi-ci/pipelines/scripts/common/kbld-korifi

generate_kube_config() {
  gcloud-login
  export-kubeconfig "$CLUSTER_NAME"
}

update_config_with_version() {
  yq -i "with(.destinations[]; .tags=[\"$VERSION\"])" "$KBLD_CONFIG_DIR/korifi-kbld.yml"
}

publish_images() {
  pushd korifi
  {
    build-korifi >/dev/null

    echo "============================================================================="
    echo "  Dev images have been successfully published on dockerhub."
    echo "    commit sha:  $COMMIT_SHA"
    echo "    images tag:  $VERSION"
    echo "============================================================================="
  }
  popd
}

main() {
  generate_kube_config
  docker_login
  update_config_with_version
  publish_images
}

main
