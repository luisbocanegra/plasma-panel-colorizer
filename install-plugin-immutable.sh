#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# Install C++ plugin for the current user
#
# NOTE: For the C++ plugin to work add the `QML_IMPORT_PATH` environment variable
# in `$HOME/.config/plasma-workspace/env/path.sh`:
# export QML_IMPORT_PATH="$HOME/.local/lib64/qml:$HOME/.local/lib/qml:$QML_IMPORT_PATH"
#
# For more information see https://userbase.kde.org/Session_Environment_Variables
cmake -B build/plugin -S . -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build/plugin && cmake --install build/plugin
