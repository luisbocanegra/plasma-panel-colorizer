#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

cmake -B build -S . -DINSTALL_PLASMOID=ON -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
sudo cmake --install build
