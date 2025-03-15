#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# Install C++ plugin for the current user
#
# NOTE: For the C++ plugin to work adding `~/.local/lib/qml` to `QML_IMPORT_PATH` is needed
# in `~/.config/plasma-workspace/env/path.sh` add:
# export QML_IMPORT_PATH="$HOME/.local/lib/qml:$QML_IMPORT_PATH"
#
# For more information see https://userbase.kde.org/Session_Environment_Variables
cmake -B build/plugin -S . -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX=~/.local
cmake --build build/plugin && cmake --install build/plugin
