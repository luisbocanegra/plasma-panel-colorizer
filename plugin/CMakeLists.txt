set(PLUGIN_NAME "panelcolorizerplugin")
set(LIB_NAME "panelcolorizer")

add_library(${PLUGIN_NAME} SHARED ${PLUGIN_NAME}.cpp ${LIB_NAME}.cpp)

target_link_libraries(${PLUGIN_NAME}
    Qt6::Gui
    Qt6::Qml
)

install(TARGETS ${PLUGIN_NAME} DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/${LIB_NAME})
install(FILES qmldir DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/plasma/${LIB_NAME})
