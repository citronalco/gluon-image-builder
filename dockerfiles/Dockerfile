FROM debian:stable-slim

RUN apt-get update && \
      apt-get install -y --no-install-recommends git subversion python2 python3 build-essential gawk unzip libncurses5-dev zlib1g-dev libssl-dev wget rsync time lua-check shellcheck && \
      apt-get install -y --no-install-recommends ecdsautils && \
      apt-get install -y --no-install-recommends ca-certificates file && \
      rm -rf /var/lib/apt/lists/*

# Buildskript kopieren und als Startskript definieren
COPY build.sh /build.sh

ENTRYPOINT /build.sh
