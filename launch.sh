#!/bin/bash

set -x

cd /data

packInfoPath="/pack-info.json"
packUrl=$(jq -r .packUrl "$packInfoPath")
forgeUrl=$(jq -r .forgeUrl "$packInfoPath")
forgeVersion=$(jq -r .forgeVersion "$packInfoPath")

if ! [[ "$EULA" = "false" ]]; then
  echo "eula=true" > eula.txt
else
  echo "You must accept the EULA to install"
  exit 99
fi

if ! [[ -f "Server-Files-$PROJECT_VERSION.zip" ]]; then
  # Cleanup old install
  rm -fr rm config resources libraries scripts tmp mods Server*.zip minecraft_server* forge*

  # Get and install Forge
  curl -Lo "forge-${forgeVersion}-installer.jar" "$forgeUrl"
  java -jar "forge-${forgeVersion}-installer.jar" --installServer

  # Get pack files
  curl -Lo "Server-Files-$PROJECT_VERSION.zip" "$packUrl" || exit 9
  unzip -u -o "Server-Files-$PROJECT_VERSION.zip" -d /data/tmp
  mv /data/tmp/overrides/* /data

  # Download all mods
  for modUrl in $(jq -r '.modUrls[]' "$packInfoPath"); do
    curl -L "$modUrl" -o "mods/${modUrl##*/}";
  done
fi

java $JVM_OPTS -jar "forge-${forgeVersion}.jar" --nogui
