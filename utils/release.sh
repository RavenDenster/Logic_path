#!/bin/bash
set -ex


if [[ -f godot4 ]]; then
    echo "Godot binary already exists"
else
    wget -O godot.zip "https://github.com/godotengine/godot/releases/download/4.5.1-stable/Godot_v4.5.1-stable_linux.x86_64.zip"
    unzip godot.zip
    rm godot.zip
    mv Godot_v4.5.1-stable_linux.x86_64 godot4
fi

rm -rf build

mkdir build
mkdir build/linux
mkdir build/windows
mkdir build/web

./godot4 --headless --export-release "Linux"
./godot4 --headless --export-release "Windows Desktop"
./godot4 --headless --export-release "Web"

cp -r levels build/linux/
cp -r levels build/windows/
# web version embeds the levels 

tar -cJf build/linux.tar.xz build/linux
7z a -t7z -mx=9 -m0=lzma2 build/windows.7z build/windows
7z a -t7z -mx=9 -m0=lzma2 build/web.7z build/web
