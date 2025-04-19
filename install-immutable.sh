#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# Install widget and C++ plugin for current user
#
# NOTE: For the C++ plugin to work add the `QML_IMPORT_PATH` environment variable
# in `$HOME/.config/plasma-workspace/env/path.sh`:
# export QML_IMPORT_PATH="$HOME/.local/lib64/qml:$HOME/.local/lib/qml:$QML_IMPORT_PATH"
#
# For more information see https://userbase.kde.org/Session_Environment_Variables
cmake -B build/ -S . -DINSTALL_PLASMOID=ON -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build/
cmake --install build/
# CMakeLists.txt plasma_install_package does't copy executable permission
chmod 700 "$HOME/.local/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/tools/list_presets.sh"
chmod 700 "$HOME/.local/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/tools/gdbus_get_signal.sh"
