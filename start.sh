#!/bin/bash

if [ ! -f ./config.env ]; then
    echo "ERROR: config.env is missing."
    exit 1
fi

docker build --tag gluon-build-container ./dockerfiles

docker run \
    -ti --init \
    --volume "$(pwd)/gluon:/gluon" \
    --volume "$(pwd)/images:/images" \
    --env HOST_UID="$(id -u)" --env HOST_GID="$(id -g)" \
    --env-file ./config.env \
    gluon-build-container
