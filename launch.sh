#!/bin/bash

set -x

cd /data

minecraft_version=""
forge_version=""

if ! [[ "$EULA" = "false" ]]; then
  echo "eula=true" > eula.txt
else
  echo "You must accept the EULA to install"
  exit 99
fi

if ! [[ -f "Server-Files-$PROJECT_VERSION.zip" ]]; then
  rm -fr rm -fr config defaultconfigs resources libraries kubejs scripts tmp mods packmenu Server*.zip forge*
  curl -Lo "Server-Files-$PROJECT_VERSION.zip" "$(jq -r '.downloadUrl' /pack-info.json)" || exit 9
  unzip -u -o "Server-Files-$PROJECT_VERSION.zip" -d /data/tmp
  mv -r /data/tmp/overrides/* /data/ # extract pack data
  minecraft_version=$(jq -r '.minecraft.version' /data/tmp/manifest.json)
  forge_version="${minecraft_version}-$(jq -r '.minecraft.modLoaders[] | select(.id | contains("forge")) | .id' /data/tmp/manifest.json | awk -F"-" '{print $2}')"
  curl -Lo "forge-${forge_version}-installer.jar" "http://files.minecraftforge.net/maven/net/minecraftforge/forge/${forge_version}/forge-${forge_version}-installer.jar"
  java -jar "forge-${forge_version}-installer.jar" --installServer
fi

java $JVM_OPTS -jar "forge-${forge_version}.jar" --nogui