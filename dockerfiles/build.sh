#!/bin/bash

# TODO:
# - Ab Gluon v2020 wird "GLUON_BRANCH" ersetzt durch "GLUON_AUTOUPDATER_BRANCH" und "GLUON_AUTOUPDATER_ENABLED"

# Wenn dieses Skript als root aufgerufen wird: Das Skript nochmal mit dem User aufrufen, der auch den Container gestartet hat.
# So gehören dann der heruntergeladene Quellcode und die erzeugten Images dem aufrufenden Benutzer und nicht root
if [ "$(id -u)" -eq 0 ]; then
    chown "${HOST_UID}":"${HOST_GID}" /gluon
    chown "${HOST_UID}":"${HOST_GID}" /images

    exec setpriv --reuid="${HOST_UID}" --regid="${HOST_GID}" --clear-groups "$0"
fi


# setpriv ändert $HOME nicht, steht nach wie vor auf /root. Darum manuell setzen
export HOME=/gluon

if [ -n "${GLUON_GIT_URL}" ] && [ -n "${GLUON_GIT_BRANCH}" ]; then
    echo
    echo "####################################################################################"
    echo "## GLUON IMAGE BUILDER: Fetching Gluon source from ${GLUON_GIT_URL}/${GLUON_GIT_BRANCH}"
    echo "####################################################################################"

    cd /gluon

    if [ ! -d .git ]; then
	git init
	git remote add origin "${GLUON_GIT_URL}"
    else
	git remote set-url origin "${GLUON_GIT_URL}"
    fi
    git fetch origin || exit 1
    git checkout "${GLUON_GIT_BRANCH}" || exit 1
    git pull || exit 1
fi

if [ -n "${SITE_GIT_URL}" ] && [ -n "${SITE_GIT_BRANCH}" ]; then
    echo
    echo "####################################################################################"
    echo "## GLUON IMAGE BUILDER: Fetching Site source from ${SITE_GIT_URL}/${SITE_GIT_BRANCH}"
    echo "####################################################################################"

    mkdir -p /gluon/site
    cd /gluon/site

    if [ ! -d .git ]; then
	git init
	git remote add origin "${SITE_GIT_URL}"
    else
	git remote set-url origin "${SITE_GIT_URL}"
    fi
    git fetch origin || exit 1
    git checkout "${SITE_GIT_BRANCH}" || exit 1
    git pull || exit 1
fi

echo
echo "####################################################################################"
echo "## GLUON IMAGE BUILDER: Updating OpenWRT"
echo "####################################################################################"
cd /gluon
make update || exit 1


# Variable GLUON_DEPRECATED setzen
[ -z "${GLUON_DEPRECATED}" ] && export GLUON_DEPRECATED="full"

# Build-Targets setzen: Wenn Benutzer die Variable "TARGET" nicht oder auf "all" oder "ALL" gesetzt hat: TARGET mit allen verfügbaren Targets füllen
if [ -z "${TARGETS}" ] || [[ ":all:ALL:" = *:${TARGETS}:* ]]; then
    TARGETS=$(make list-targets)
fi

# Ein Ausgabeverzeichnis für jeden VPN-Typ festlegen
declare -A VPNTYPEDIRS
if [ -z "${VPN_TYPES}" ]; then
    VPNTYPEDIRS["/images"]=""
else
    for TYPE in ${VPN_TYPES}; do
	VPNTYPEDIRS["/images/${TYPE}"]="${TYPE}"
    done
fi


# Für jeden VPN-Typ....
for DIR in "${!VPNTYPEDIRS[@]}"; do
    export GLUON_IMAGEDIR="${DIR}"		# Ausgabeverzeichnis für die Images
    export GLUON_RELEASE=$(make show-release)	# wird für Dateinamen der Images verwendet
    export VPN_TYPE="${VPNTYPEDIRS[${DIR}]}"

    # ...für jedes Target compilieren
    for TARGET in ${TARGETS}; do
	echo
	echo "####################################################################################"
	echo "## GLUON IMAGE BUILDER: Building target ${TARGET} ${VPN_TYPE}"
	echo "####################################################################################"
	if [[ ":true:TRUE:yes:YES:1:" = *:${DEBUG}:* ]]; then
	    # DEBUG gesetzt
	    make GLUON_TARGET="${TARGET}" -j1 V=s || exit 1
	else
	    # DEBUG nicht gesetzt
	    if ! make GLUON_TARGET="${TARGET}" -j"$(nproc)"; then
		make clean GLUON_TARGET="${TARGET}"	# Gluon-Doku: "Ensure all packages are rebuilt for a single target. This is usually not necessary, but may fix certain kinds of build failures."

		if ! make GLUON_TARGET="${TARGET}" -j"$(nproc)"; then
		    make dirclean	# Gluon-Doku: "Clean the entire tree, so the toolchain will be rebuilt as well, which will take a while."
		    mkdir -p tmp

		    if ! make GLUON_TARGET="${TARGET}" -j"$(nproc)"; then
			echo "####################################################################################"
			echo "## GLUON IMAGE BUILDER: ERROR - Could not build target ${TARGET} ${VPN_TYPE}"
			echo "####################################################################################"
			exit 1
		    fi
		fi
	    fi
	    echo "####################################################################################"
	    echo "## GLUON IMAGE BUILDER: Sucessfully built target ${TARGET} ${VPN_TYPE}"
	    echo "####################################################################################"
	fi
    done

    ### build_info.txt-Datei anlegen
    cat > "${DIR}"/build_info.txt << EOF
GLUON_RELEASE=${GLUON_RELEASE}
GLUON_REPO_URL=${GLUON_GIT_URL}
GLUON_BASE=${GLUON_GIT_BRANCH}
GLUON_COMMIT=$(git --git-dir /gluon/.git rev-list --max-count=1 HEAD)
SITE_REPO_URL=${SITE_GIT_URL}
SITE_BASE=${SITE_GIT_BRANCH}
SITE_COMMIT=$(git --git-dir /gluon/site/.git rev-list --max-count=1 HEAD)
EOF

    ### Manifest-Dateien erstellen
    for BRANCH in ${MANIFEST_BRANCHES}; do
	echo
	echo "####################################################################################"
	echo "## GLUON IMAGE BUILDER: Creating Manifest for ${BRANCH/:*/} ${VPN_TYPE}"
	echo "####################################################################################"
	make manifest \
	    GLUON_AUTOUPDATER_BRANCH="${BRANCH/:*/}" GLUON_BRANCH="${BRANCH/:*/}" GLUON_PRIORITY="${BRANCH/*:/}" || exit 1

	for KEY in ${ECDSA_PRIVATE_KEYS}; do
	    contrib/sign.sh <(echo "${KEY}") "${GLUON_IMAGEDIR}"/sysupgrade/"${BRANCH/:*/}".manifest || exit 1
	done
    done
done
