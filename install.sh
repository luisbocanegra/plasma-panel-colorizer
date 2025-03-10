#!/bin/sh

if [ -d "build" ]; then
    rm -rf build
fi

# Install widget for current user
cmake -B build/ -S . -DINSTALL_PLASMOID=ON -DBUILD_PLUGIN=ON -DCMAKE_INSTALL_PREFIX=~/.local
cmake --build build/
cmake --install build/
# CMakeLists.txt plasma_install_package does't copy executable permission
chmod 700 "$HOME/.local/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/tools/list_presets.sh"
