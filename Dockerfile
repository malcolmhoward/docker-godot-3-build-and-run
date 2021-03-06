# FROM ubuntu:bionic
FROM debian:stable-slim

LABEL maintainer="h4de5@users.noreply.github.com" \
  version="3.0.4" \
  description="Docker image to create a godot v3.0.4 build environment, export your game as binary and run your game as headless server. use --build-arg serverport=<port> to select an open port."

# a serverport can be given at build time
ARG serverport=8910
ARG godotversion=3.0.5
# which will be exposed
EXPOSE $serverport

# fetch updates and packetlist
# install build environment and additionals
# skip upgrade and autoremove for now
# apt-get --yes upgrade && \ 
# apt-get --yes autoremove && \
RUN apt-get --yes update && \
  apt-get --yes install \
    build-essential scons pkg-config libx11-dev libxcursor-dev libxinerama-dev \
	  libgl1-mesa-dev libglu-dev libasound2-dev libpulse-dev libfreetype6-dev libssl-dev libudev-dev \
	  libxi-dev libxrandr-dev mingw-w64 \
	  git unzip upx vim wget ca-certificates


# setting up build environment
ENV DOCKER_WORKING_DIR="/root/workspace/" \
  DOCKER_BUILD_SCRIPT="/root/workspace/build-scripts/" \
  DOCKER_GODOT_SOURCE="/root/workspace/godot/" \
  DOCKER_GODOT_VERSION="$godotversion" \
  DOCKER_GODOT_EXPORT_TEMPLATES="/root/workspace/godot/templates/" \
  DOCKER_GODOT_EDITOR="/root/workspace/editor/" \
  DOCKER_GODOT_GAME_SOURCE="/root/workspace/game/" \
  DOCKER_GODOT_EXPORT_GAME="/root/workspace/exports/" \
  DOCKER_GODOT_EMSCRIPTEN="/root/workspace/emscripten/" \
  DOCKER_GODOT_SERVER_BINARY="/root/workspace/editor/linux_server" \
  DOCKER_TAG_NAME="docker-godot-3-build-and-run:latest" \
  EMSCRIPTEN_ROOT="/root/workspace/emscripten/" \
  GODOT_HOME="~/.godot/" \
  XDG_CACHE_HOME="~/.cache/" \
  XDG_DATA_HOME="~/.local/share/" \
  XDG_CONFIG_HOME="~/.config/"

# create some directories for later use
RUN mkdir -p "$DOCKER_WORKING_DIR" \
    "$DOCKER_BUILD_SCRIPT" \
    "$DOCKER_GODOT_EDITOR" \
    "$DOCKER_GODOT_GAME_SOURCE" \
    "$DOCKER_GODOT_EXPORT_GAME" \
    "$DOCKER_GODOT_EMSCRIPTEN" \
    "$GODOT_HOME" \
    "$XDG_CACHE_HOME" \
    "$XDG_DATA_HOME" \
    "$XDG_CONFIG_HOME"

WORKDIR $DOCKER_WORKING_DIR

# copy our build scripts into the directory
COPY *.sh $DOCKER_BUILD_SCRIPT

# make scripts executable
# get godot source
# download stable export templates
# install emscripten
RUN chmod +x ${DOCKER_BUILD_SCRIPT}*.sh && \
  git clone -b master --single-branch https://github.com/godotengine/godot.git $DOCKER_GODOT_SOURCE && \
  ${DOCKER_BUILD_SCRIPT}download-godot.sh all && \ 
  ${DOCKER_BUILD_SCRIPT}install-emscripten.sh

# run shell
CMD ["/bin/bash"]

# run godot build
# CMD ["/root/workspace/build-scripts/build-godot.sh"]
