#!/bin/bash
# TOOD: Besser(?): Zuerst gluon klonen, dann gleich das Dockerfile aus contrib als Grundlage nutzen
docker build --tag gluon-build-machine ./dockerfiles

docker run \
    -ti --init \
    --volume $(pwd)/gluon:/gluon \
    --volume $(pwd)/images:/images \
    --env HOST_UID=$(id -u) --env HOST_GID=$(id -g) \
    --env-file ./config.env \
    gluon-build-machine

# TODO:
# - ccache (Testen ob's was bringt)/distcc/icecream?
