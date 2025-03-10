#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

cmake -B build/plugin -S . -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX=~/.local
cmake --build build/plugin && cmake --install build/plugin
