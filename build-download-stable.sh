#!/bin/bash

if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
  echo "To download the latest godot export templates:"
  echo "  docker exec -d $DOCKER_TAG_NAME $DOCKER_BUILD_SCRIPT/${0}"
  echo "After the download is complete, save the current state:"
  echo "  docker commit <container-id> $DOCKER_TAG_NAME"
  exit 0
fi

cd "$DOCKER_GODOT_EXPORT_TEMPLATES"
wget --quiet https://downloads.tuxfamily.org/godotengine/3.0/Godot_v3.0-stable_export_templates.tpz
mv Godot_v3.0-stable_export_templates.tpz Godot_v3.0-stable_export_templates.zip
unzip Godot_v3.0-stable_export_templates.zip
mv templates/* .
rmdir templates

echo "** Download and unzip complete!"

echo "Export templates in: $DOCKER_GODOT_EXPORT_TEMPLATES"