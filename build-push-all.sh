#!/bin/bash

for version in latest dubnium erbium fermium gallium; do
	ALPINE_VERSION='latest' NODE_VERSION=$version ./build-node-image.sh
done

docker images --format '{{ .Repository }}:{{ .Tag }}' slimnode |\
	while read image; do
		docker tag $image kwetlesen/$image
		docker push kwetlesen/$image
	done
