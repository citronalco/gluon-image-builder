# Bernies Gluon-Bau-Container
## Anleitung:

1. `config.env.example` kopieren zu `config.env`
2. `config.env` anpassen:
   ```
   GLUON_GIT_URL=<URL zum Gluon-Repository>
   GLUON_GIT_BRANCH=<Branch im Gluon-Repository>
   SITE_GIT_URL=<URL zum Site-Repository>
   SITE_GIT_BRANCH=<Branch im Site-Repository>

   MANIFEST_BRANCHES=<Branchname1>:<Autoupdater-Priority1> <Branchname2>:<Autoupdater-Priority2> ...
   ECDSA_PRIVATE_KEYS=<ECDSA-Private-Key1> <ECDSA-Private-Key2> ...
   TARGETS=<Target1> <Target2> ...
   DEBUG=<true|false>
   ```
   **Erforderliche Variablen:**
   - `GLUON_GIT_URL`
   - `GLUON_GIT_BRANCH`
   - `SITE_GIT_URL`
   - `SITE_GIT_BRANCH`
   
   **Optionale Variablen:**
   - `MANIFEST_BRANCHES` und `ECDSA_PRIVATE_KEYS`: Wenn "MANIFEST_BRANCHES" gesetzt ist werden die entsprechenden Manifest-Dateien für den Autoupdater mit der angegebenen Autoupdater-Priorität erstellt und, wenn "ECDSA_PRIVATE_KEYS" gesetzt ist, mit dem/den dort angegebenen Key(s) signiert.
   - `TARGETS`: Hier können die Targets angegeben werden, für die Images gebaut werden sollen. Fehlt die Variable oder ist sie auf "all" gesetzt, werden Images für alle verfügbaren Targets erstellt.
   - `DEBUG`: Wenn "DEBUG" auf "true" gesetzt ist, wird Gluon mit den für das Debugging des Build-Prozesses empfohlenen make-Optionen "-j1 V=s" gebaut. Standardwert ist "false".

3. `./start.sh`

Der Gluon-Quellcode wird ins Unterverzeichnis `./gluon` heruntergeladen und dort compiliert. Die fertigen Firmware-Images landen im Unterverzeichnis `./images`.
