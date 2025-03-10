set(PLUGIN_NAME "panelcolorizerplugin")
set(LIB_NAME "panelcolorizer")
set(PLUGIN_ID "luisbocanegra.panel.colorizer")

add_library(${PLUGIN_NAME} SHARED ${PLUGIN_NAME}.cpp ${LIB_NAME}.cpp)

target_link_libraries(${PLUGIN_NAME}
    Qt6::Gui
    Qt6::Qml
)

install(TARGETS ${PLUGIN_NAME} DESTINATION ${PLASMA_DATA_INSTALL_DIR}/plasmoids/${PLUGIN_ID}/contents/ui)
install(FILES qmldir DESTINATION ${PLASMA_DATA_INSTALL_DIR}/plasmoids/${PLUGIN_ID}/contents/ui)
