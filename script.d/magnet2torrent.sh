#!/bin/bash

# Loop through watch directory
watchdir=#ROOT_WATCH_DIR#
for filename in $watchdir/*/*.magnet; do
  [ -e "$filename" ] || continue;
#  echo $filename
  folder="$(dirname "${filename}")"
  file=$(basename "${filename}")
#  echo $folder
#  echo $file
#  exit;
#  cd to watch/* directoryx
  cd $folder
  # Assign the contents of the magnet file to a variable
  magnet="`cat "$file"`"
  # Check if magnet file contains hash
  [[ "$magnet" =~ xt=urn:btih:([^&/]+) ]] || continue;
  # Create torrent file with data in expected format
  echo "d10:magnet-uri${#magnet}:${magnet}e" > "meta-${BASH_REMATCH[1]}.torrent"
  # Delete the magnet file
  rm "$file"
done