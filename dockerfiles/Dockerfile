FROM debian:stable-slim

RUN apt-get update && \
      apt-get install -y --no-install-recommends git subversion python build-essential gawk unzip libncurses5-dev zlib1g-dev libssl-dev wget time && \
      apt-get install -y --no-install-recommends ecdsautils && \
      apt-get install -y --no-install-recommends ca-certificates file && \
      rm -rf /var/lib/apt/lists/*

# Buildskript kopieren und als Startskript definieren
COPY build.sh /build.sh

ENTRYPOINT /build.sh
