#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# Install widget for current user
cmake -B build/plasmoid -S . -DINSTALL_PLASMOID=ON -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build/plasmoid
cmake --install build/plasmoid
# CMakeLists.txt plasma_install_package does't copy executable permission
chmod 700 "$HOME/.local/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/tools/list_presets.sh"
chmod 700 "$HOME/.local/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/tools/gdbus_get_signal.sh"

# Install plugin system-wide (required for qml modules)
cmake -B build/plugin -S . -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build/plugin
sudo cmake --install build/plugin
