# Gluon Image Builder

Baut Gluon Firmware-Images anhand einer Konfigurationsdatei in einem Docker-Container.

## Anleitung:

1. `config.env.example` kopieren zu `config.env`
2. `config.env` anpassen:
   ```
   # Erforderlich:
   GLUON_GIT_URL=<URL zum Gluon-Repository>
   GLUON_RELEASE=<Branch im Gluon-Repository>
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
   - `GLUON_GIT_URL`
   - `GLUON_RELEASE`
   - `SITE_GIT_URL`
   - `SITE_GIT_BRANCH`

   **Optionale Variablen:**
   - `MANIFEST_BRANCHES` und `ECDSA_PRIVATE_KEYS`: Wenn "MANIFEST_BRANCHES" gesetzt ist werden die entsprechenden Manifest-Dateien für den Autoupdater mit der angegebenen Autoupdater-Priorität erstellt und, wenn "ECDSA_PRIVATE_KEYS" gesetzt ist, mit dem/den dort angegebenen Key(s) signiert.
   - `TARGETS`: Hier können die Targets angegeben werden, für die Images gebaut werden sollen. Fehlt die Variable oder ist sie auf "all" gesetzt, werden Images für alle verfügbaren Targets erstellt.
   - `DEBUG`: Wenn "DEBUG" auf "true" gesetzt ist, wird Gluon mit den für das Debugging des Build-Prozesses empfohlenen make-Optionen "-j1 V=s" gebaut. Standardwert ist "false".
   - `VPN_TYPES`: Nur relevant für Freifunk Ingolstadt: Wahl der VPN-Techniken, für die Images gebaut werden sollen. Mögliche Werte siehe https://git.bingo-ev.de/freifunk/ffin-site/blob/master/site.mk

   Es können weitere Variablen in config.env angegeben werden (siehe https://gluon.readthedocs.io/en/latest/user/site.html#user-site-build-configuration).
   Diese werden dann einfach zum Gluon-Build-Prozess durchgereicht.

3. `./start.sh`

Der Gluon-Quellcode wird ins Unterverzeichnis `./gluon` heruntergeladen und dort compiliert. Die fertigen Firmware-Images landen im Unterverzeichnis `./images`.
