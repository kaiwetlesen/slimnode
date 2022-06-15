#!/bin/bash

# Current releases:
latest='v18.3.0'
gallium='v16.15.1'
fermium='v14.19.3'
erbium='v12.22.12'
# Source: https://nodejs.org/en/about/releases/

if [ -z "$NODE_VERSION" ]; then
	NODE_VERSION='latest'
fi

if [ -n "${!NODE_VERSION}" ]; then
	if [ ${NODE_VERSION} != 'latest' ]; then
		node_lts_ver="${NODE_VERSION}"
	fi
	node_version="${!NODE_VERSION}"
else
	node_version="$NODE_VERSION"

fi

set -e

curl -L -o node-${node_version}.tar.gz https://nodejs.org/dist/${node_version}/node-${node_version}.tar.gz
if [ -n "${node_lts_ver}" ]; then
	echo "Building LTS image ${node_lts_ver}..."
	docker build --build-arg "NODE_LTS_VER=${node_lts_ver}" --build-arg "NODE_VERSION=${node_version}" -f Dockerfile -t slimnode:${node_version} .
	docker tag slimnode:${node_version} slimnode:${node_lts_ver}
else
	echo "Building node image ${node_version}..."
	docker build --build-arg "NODE_NODE_VERSION=${node_version}" -f Dockerfile -t slimnode:${node_version} .
fi
