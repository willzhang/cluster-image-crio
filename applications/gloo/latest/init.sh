#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

export readonly ARCH=${1:-amd64}
export readonly NAME=${2:-$(basename "${PWD%/*}")}
export readonly VERSION=${3:-$(basename "$PWD")}

rm -rf charts/
mkdir -p charts/

helm repo add gloo --force-update https://storage.googleapis.com/solo-public-helm
if [ $VERSION = "latest" ]
then helm pull gloo/gloo --untar -d charts/
else helm pull gloo/gloo --version=$VERSION --untar -d charts/
fi
#https://docs.solo.io/gloo-edge/latest/reference/helm_chart_values/open_source_helm_chart_values/
cat <<'EOF' >"Kubefile"
FROM scratch
COPY charts charts
COPY registry registry
CMD ["helm upgrade -i gloo charts/gloo -n gloo-system --create-namespace --set gateway.enabled=true,ingress.enabled=true,ingressProxy.service.type=NodePort,gatewayProxies.gatewayProxy.service.type=NodePort,global.glooStats.serviceMonitorEnabled=true,gatewayProxies.gatewayProxy.service.externalTrafficPolicy=Local"]
EOF

