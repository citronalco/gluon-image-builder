#!/bin/bash

# Wenn dieses Skript als root aufgerufen wird: Das Skript nochmal mit dem User aufrufen, der auch den Container gestartet hat.
# So gehören dann der heruntergeladene Quellcode und die erzeugten Images dem aufrufenden Benutzer und nicht root
if [ $(id -u) -eq 0 ]; then
    chown ${HOST_UID}:${HOST_GID} /gluon
    chown ${HOST_UID}:${HOST_GID} /images
    exec setpriv --reuid=${HOST_UID} --regid=${HOST_GID} --clear-groups "$0"
fi

### setpriv ändert $HOME nicht, steht nach wie vor auf /root. Darum manuell setzen
HOME=/gluon

[ -z "${GLUON_DEPRECATED}" ] && export GLUON_DEPRECATED="full"

### Quellcodes besorgen
# Gluon auschecken und auf gewählten Branch wechseln
cd /gluon

if [ ! -d .git ]; then
    git init
    git remote add origin ${GLUON_GIT_URL}
fi
git fetch origin
git checkout ${GLUON_GIT_BRANCH} || exit 1
git pull

GLUON_COMMIT=$(git rev-list --max-count=1 HEAD)

# Site-Konfiguration auschecken und auf gewählten Branch wechseln
mkdir -p /gluon/site
cd /gluon/site

if [ ! -d .git ]; then
    git init
    git remote add origin ${SITE_GIT_URL}
fi
git fetch origin
git checkout ${SITE_GIT_BRANCH} || exit 1
git pull

SITE_COMMIT=$(git rev-list --max-count=1 HEAD)
export GLUON_RELEASE=$(make show-release)


### Bauen
cd /gluon

# Build-Targets setzen: Wenn Benutzer die Variable "TARGET" nicht oder auf "all" oder "ALL" gesetzt hat: TARGET mit allen verfügbaren Targets füllen
if [ -z "${TARGETS}" ] || [[ ":all:ALL:" = *:${TARGETS}:* ]]; then
    TARGETS=$(make list-targets)
fi

# VPN-Typen und zugehöriges Ausgabeverzeichnis festlegen
declare -A VPNTYPEIMAGES
if [ -z "${VPN_TYPES}" ]; then
    VPNTYPEIMAGES["/images"]=""
else
    for TYPE in ${VPN_TYPES}; do
	VPNTYPEIMAGES["/images/${TYPE}"]="${TYPE}"
    done
fi

# OpenWRT aktualisieren
make update

# Für jeden VPN-Typ....
for IMAGEDIR in "${!VPNTYPEIMAGES[@]}"; do
    export VPN_TYPE="${VPNTYPEIMAGES[${IMAGEDIR}]}"
    export GLUON_IMAGEDIR="${IMAGEDIR}"

    # ...für jedes Target compilieren
    for TARGET in ${TARGETS}; do
	if [[ ":true:TRUE:yes:YES:1:" = *:${DEBUG}:* ]]; then
	    # DEBUG gesetzt
	    make GLUON_TARGET=${TARGET} -j1 V=s || exit 1
	else
	    # DEBUG nicht gesetzt
	    # Eskalationsstufen bei Build-Fehlern laut Gluon-Doku
	    if ! make GLUON_TARGET=${TARGET} -j$(nproc); then
		make clean GLUON_TARGET=${TARGET}

		if ! make GLUON_TARGET=${TARGET} -j$(nproc); then
		    make dirclean
		    mkdir -p tmp

		    if ! make GLUON_TARGET=${TARGET} -j$(nproc); then
		    exit 1
		    fi
		fi
	    fi
	fi
    done

    ### build_info.txt-Datei anlegen
    cat > ${GLUON_IMAGEDIR}/build_info.txt << EOF
    GLUON_COMMIT=${GLUON_COMMIT}
    GLUON_BASE=${GLUON_GIT_BRANCH}
    GLUON_REPO_URL=${GLUON_GIT_URL}
    SITE_COMMIT=${SITE_COMMIT}
    SITE_BASE=${SITE_GIT_BRANCH}
    SITE_REPO_URL=${GLUON_GIT_URL}
    GLUON_RELEASE=${GLUON_RELEASE}
EOF

    ### Manifest-Dateien erstellen
    for BRANCH in ${MANIFEST_BRANCHES}; do
	make manifest GLUON_BRANCH=${BRANCH/:*/} GLUON_PRIORITY=${BRANCH/*:/}

	# Signieren
	for KEY in ${ECDSA_PRIVATE_KEYS}; do
	    contrib/sign.sh <(echo ${KEY}) $GLUON_IMAGEDIR/sysupgrade/${BRANCH/:*/}.manifest
	done
    done
done
