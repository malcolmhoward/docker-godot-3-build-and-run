#!/bin/bash

if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
  echo "To compile the godot source from current master: "
  echo "  docker exec -d h4de5/docker-godot-3-build-and-run:latest /root/workspace/build-scripts/${0}" [all]
  echo "use with parameter 'all' to compile export templates for X11, windows and javascript"
  echo "this should only be called once a container is made from the image."
  exit 0
fi

# see: http://docs.godotengine.org/en/3.0/development/compiling/batch_building_templates.html

# different javascript export way
# RUN LLVM_EXPERIMENTAL_TARGETS_TO_BUILD=WebAssembly

# used for exporting to windows
# RUN update-alternatives --config x86_64-w64-mingw32-gcc
# <choose x86_64-w64-mingw32-gcc-posix from the list>
# RUN update-alternatives --config x86_64-w64-mingw32-g++
# <choose x86_64-w64-mingw32-g++-posix from the list>

cd $DOCKER_GODOT_SOURCE

# remove any local changes
# git stash

# get latest changes
git pull

# rm -rf templates/*
mkdir -p $DOCKER_GODOT_EXPORT_TEMPLATES

# will be used to export and run games
echo "* Building godot for Linux Server"
scons -j 2 p=server target=release tools=false bits=64
cp bin/godot_server.server.opt.64 $DOCKER_GODOT_EXPORT_TEMPLATES/linux_server_64
upx $DOCKER_GODOT_EXPORT_TEMPLATES/linux_server_64

# scons -j 2 p=server target=release_debug tools=false bits=64
# cp bin/godot_server.server.opt.debug.64 $DOCKER_GODOT_EXPORT_TEMPLATES/linux_server_64_debug
# upx $DOCKER_GODOT_EXPORT_TEMPLATES/linux_server_64_debug

scons -j 2 p=server target=release_debug tools=true bits=64
cp bin/godot_server.server.opt.debug.tools.64 $DOCKER_GODOT_EXPORT_TEMPLATES/linux_server_64_tools
upx $DOCKER_GODOT_EXPORT_TEMPLATES/linux_server_64_tools

cd 
if [ "$1" == "all" ] ; then
	
	echo "* Building godot for Linux X11"
	scons -j 2 p=x11 target=release tools=no bits=64
	cp bin/godot.x11.opt.64 $DOCKER_GODOT_EXPORT_TEMPLATES/linux_x11_64_release
	upx $DOCKER_GODOT_EXPORT_TEMPLATES/linux_x11_64_release
	scons -j 2 p=x11 target=release_debug tools=no bits=64
	cp bin/godot.x11.opt.debug.64 $DOCKER_GODOT_EXPORT_TEMPLATES/linux_x11_64_debug
	upx $DOCKER_GODOT_EXPORT_TEMPLATES/linux_x11_64_debug
	
	
	echo "* Building godot for Windows"
	scons -j 2 p=windows target=release tools=no bits=64
	cp bin/godot.windows.opt.64.exe $DOCKER_GODOT_EXPORT_TEMPLATES/windows_64_release.exe
	x86_64-w64-mingw32-strip $DOCKER_GODOT_EXPORT_TEMPLATES/windows_64_release.exe
	scons -j 2 p=windows target=release_debug tools=no bits=64
	cp bin/godot.windows.opt.debug.64.exe $DOCKER_GODOT_EXPORT_TEMPLATES/windows_64_debug.exe
	x86_64-w64-mingw32-strip $DOCKER_GODOT_EXPORT_TEMPLATES/windows_64_debug.exe
	
	
	echo "* Building godot for Javascript"
	scons -j 2 p=javascript target=release
	cp bin/godot.javascript.opt.zip $DOCKER_GODOT_EXPORT_TEMPLATES/webassembly_release.zip
	scons -j 2 p=javascript target=release_debug
	cp bin/godot.javascript.opt.debug.zip $DOCKER_GODOT_EXPORT_TEMPLATES/webassembly_debug.zip

fi


# TODO link /root/.godot/templates to templates

echo "** Building complete!"
echo "Export templates in: $DOCKER_GODOT_EXPORT_TEMPLATES"
