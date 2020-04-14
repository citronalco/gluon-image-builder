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
   ```
   "MANIFEST_BRANCHES" und "ECDSA_PRIVATE_KEYS" sind optional:
   Wenn "MANIFEST_BRANCHES" gesetzt ist werden die entsprechenden Manifest-Dateien für den Autoupdater mit der angegebenen Autoupdater-Priorität erstellt und, wenn "ECDSA_PRIVATE_KEYS" gesetzt ist, mit dem/den dort angegebenen Keys signiert.
3. `./start.sh`

Der Gluon-Quellcode wird ins Unterverzeichnis `./gluon` heruntergeladen und dort compiliert, die Firmware-Images landen dann im Unterverzeichnis `./images`.
