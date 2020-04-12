#!/bin/bash

# Wenn dieses Skript als root aufgerufen wird: Das Skript nochmal mit dem User aufrufen, der auch den Container startet
if [ $(id -u) -eq 0 ]; then
    chown ${HOST_UID}:${HOST_GID} /gluon
    chown ${HOST_UID}:${HOST_GID} /images
    exec setpriv --reuid=${HOST_UID} --regid=${HOST_GID} --clear-groups "$0"
fi

# setpriv ändert $HOME nicht, steht nach wie vor auf /root
HOME=/gluon

# Gluon aktualisieren und auf gewählten Branch wechseln
cd /gluon
if [ ! -d .git ]; then
    git init
    git remote add origin ${GLUON_GIT_URL}
fi
git fetch origin
git checkout ${GLUON_GIT_BRANCH}
GLUON_COMMIT=$(git rev-list --max-count=1 HEAD)

# Site aktualisieren und auf gewählten Branch wechseln
mkdir -p /gluon/site
cd /gluon/site
if [ ! -d .git ]; then
    git init
    git remote add origin ${SITE_GIT_URL}
fi
git fetch origin
git checkout ${SITE_GIT_BRANCH}
SITE_COMMIT=$(git rev-list --max-count=1 HEAD)

# Gluon-Variablen setzen
cd /gluon
export GLUON_DEPRECATED="full"
export GLUON_RELEASE=$(make show-release)
export GLUON_IMAGEDIR="/images"

# Bauen
make update
#for TARGET in ar71xx-tiny; do
for TARGET in $(make list-targets); do
    make GLUON_TARGET=${TARGET} -j$(nproc) || exit 1
    #make GLUON_TARGET=$TARGET -j1 V=s || exit 1
done

# build_info.txt-Datei anlegen
cat > ${GLUON_IMAGEDIR}/build_info.txt << EOF
GLUON_COMMIT=${GLUON_COMMIT}
GLUON_BASE=${GLUON_GIT_BRANCH}
GLUON_REPO_URL=${GLUON_GIT_URL}
SITE_COMMIT=${SITE_COMMIT}
SITE_BASE=${SITE_GIT_BRANCH}
SITE_REPO_URL=${GLUON_GIT_URL}
GLUON_RELEASE=${GLUON_RELEASE}
EOF

# Manifest-Dateien erstellen
for BRANCH in ${MANIFEST_BRANCHES}; do
    make manifest GLUON_BRANCH=${BRANCH/:*/} GLUON_PRIORITY=${BRANCH/*:/}

    for KEY in ${ECDSA_PRIVATE_KEYS}; do
	contrib/sign.sh <(echo ${KEY}) $GLUON_IMAGEDIR/sysupgrade/${BRANCH/:*/}.manifest
    done
done
