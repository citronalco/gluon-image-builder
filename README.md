# Gluon Image Builder

Baut Gluon Firmware-Images für Freifunk in einem Docker-Container anhand einer einfachen Konfigurationsdatei.

## Voraussetzungen:
- Linux-Rechner mit installiertem Docker und Docker-Compose (Debian/Ubuntu/Mint: `sudo apt-get install docker-compose docker.io`)
- mindestens 150 GByte freier Festplattenplatz

## Anleitung:

1. `config.env.example` kopieren zu `config.env`
2. `config.env` anpassen:
   ```
   # Erforderlich:
   GLUON_GIT_URL=<URL zum Gluon-Repository>
   GLUON_GIT_BRANCH=<Branch im Gluon-Repository>
   SITE_GIT_URL=<URL zum Site-Repository>
   SITE_GIT_BRANCH=<Branch im Site-Repository>

   # Optional:
   MANIFEST_BRANCHES=<Branchname1>:<Autoupdater-Priority1> <Branchname2>:<Autoupdater-Priority2> ...
   ECDSA_PRIVATE_KEYS=<ECDSA-Private-Key1> <ECDSA-Private-Key2> ...
   TARGETS=<Target1> <Target2> ...
   DEBUG=<true|false>
   VPN_TYPES=<VPN-Typ1> <VPN-Typ2> ...
   ```

   **Erforderliche Variablen:**
   - `GLUON_GIT_URL`: URL zum Git-Repository von Gluon, z.B. für das offizielle Gluon-Repository: "https://github.com/freifunk-gluon/gluon.git"
   - `GLUON_GIT_BRANCH`: zu verwendender Branch/Tag im Gluon-Repository, z.B. "v2019.2", "v2020.1.2", "master", "next",...
   - `SITE_GIT_URL`: URL zum Git-Repository der Site-Konfiguration deiner Freifunk-Community
   - `SITE_GIT_BRANCH`: zu verwendender Branch im Git-Repository der Site-Konfiguration

   **Optionale Variablen:**
   - `MANIFEST_BRANCHES` und `ECDSA_PRIVATE_KEYS`: Wenn "MANIFEST_BRANCHES" gesetzt ist werden die entsprechenden Manifest-Dateien für den Autoupdater mit der angegebenen Autoupdater-Priorität erstellt und, wenn "ECDSA_PRIVATE_KEYS" gesetzt ist, mit dem/den dort angegebenen Key(s) signiert.
   - `TARGETS`: Hier können die Targets (z.B. "ath79-generic ramips-mt76x8") angegeben werden, für die Images gebaut werden sollen. Fehlt die Variable oder ist sie auf "all" gesetzt, werden Images für alle verfügbaren Targets erstellt.
   - `DEBUG`: Wenn "DEBUG" auf "true" gesetzt ist, wird Gluon mit den für das Debugging des Build-Prozesses empfohlenen make-Optionen "-j1 V=s" gebaut. Standardwert ist "false".
   - `VPN_TYPES`: Nur relevant für Freifunk Ingolstadt, sonst weglassen: Wahl der VPN-Techniken, für die Images gebaut werden sollen. Mögliche Werte siehe https://git.bingo-ev.de/freifunk/ffin-site/blob/master/site.mk

   Wenn Variablen zum Gluon-Build-Prozess durchgereicht werden sollen (siehe https://gluon.readthedocs.io/en/latest/user/site.html#user-site-build-configuration): Einfach auch in die config.env eintragen.

3. `./start.sh` ausführen.

Der Gluon-Quellcode wird ins Unterverzeichnis `./gluon` heruntergeladen und dort compiliert. Die fertigen Firmware-Images landen im Unterverzeichnis `./images`.
Das Compilieren der Firmware für alle verfügbaren Targets dauert einige Stunden.
