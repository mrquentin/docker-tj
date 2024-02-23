#! /bin/bash

# Global variables
packFileName="pack.zip"
manifestFile="manifest.json"
packInfoFile="pack-info.json"

# Create output file
jq -n '{ }' > "$packInfoFile"

# Get pack manifest
echo "$CURSE_TOKEN"
filesList=$(curl -H "x-api-key: $CURSE_TOKEN" "https://api.curseforge.com/v1/mods/$PROJECT_ID/files")
packUrl=$(echo "$filesList" | jq -r --arg version "$PROJECT_VERSION" '.data[] | select(.fileName | contains($version)) | .downloadUrl')
jq --arg packUrl "$packUrl" '.packUrl = $packUrl' "$packInfoFile" > tmp.json && mv tmp.json "$packInfoFile"
curl -Lo "$packFileName" "$packUrl" || exit 9
unzip -j "$packFileName" "$manifestFile"

# Get Forge version
minecraftVersion=$(jq -r '.minecraft.version' "$manifestFile")
forgeVersion="${minecraftVersion}-$(jq -r '.minecraft.modLoaders[] | select(.id | contains("forge")) | .id' "$manifestFile" | awk -F"-" '{print $2}')"
forgeUrl="http://files.minecraftforge.net/maven/net/minecraftforge/forge/${forgeVersion}/forge-${forgeVersion}-installer.jar"
jq --arg forgeUrl "$forgeUrl" '.forgeUrl = $forgeUrl' "$packInfoFile" > tmp.json && mv tmp.json "$packInfoFile"
jq --arg forgeVersion "$forgeVersion" '.forgeVersion = $forgeVersion' "$packInfoFile" > tmp.json && mv tmp.json "$packInfoFile"

# Get mods Download URLs
jq '.modUrls = []' "$packInfoFile" > tmp.json && mv tmp.json "$packInfoFile"
for key in $(jq -r '.files[] | "\(.projectID):\(.fileID)"' "$manifestFile"); do
  IFS=':' read -r modId fileId <<< "$key"
  modInfo=$(curl -H "x-api-key: $CURSE_TOKEN" "https://api.curseforge.com/v1/mods/${modId}/files/${fileId}")
  echo "$modInfo" | jq -r '.data.downloadUrl' >> mods.json
  jq --arg modUrl "$(echo "$modInfo" | jq -r '.data.downloadUrl')" '.modUrls += [$modUrl]' "$packInfoFile" > tmp.json && mv tmp.json "$packInfoFile"
done