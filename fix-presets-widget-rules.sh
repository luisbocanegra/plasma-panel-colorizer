#!/usr/bin/env bash
# Restore/clean default rules in all saved presets to work with the new format
# Only required if you have updated from an older version to v0.5.0
# https://github.com/luisbocanegra/plasma-panel-colorizer/issues/34
# Pipe character | must be used as separator

BLACKLIST_WIDGETS="org.kde.plasma.panelspacer|luisbocanegra.panelspacer.extended|org.kde.plasma.marginsseparator|org.kde.plasma.taskmanager|org.kde.plasma.icontasks|org.kde.plasma.pager|org.kde.plasma.activitypager|org.kde.plasma.systemmonitor.memory|org.kde.plasma.systemmonitor.diskusage|org.kde.plasma.systemmonitor.cpu|org.kde.plasma.systemmonitor.diskactivity|org.kde.plasma.systemmonitor.net|org.kde.plasma.systemmonitor|org.kde.plasma.systemmonitor.cpucore"
MARGIN_WIDGET_RULES="org.kde.plasma.kickoff,0,0|"
FORCE_ICON_COLOR_WIDGETS=""

find ~/.config/panel-colorizer/ -type f -exec sed -i "s/^blacklist=.*/blacklist=$BLACKLIST_WIDGETS/" {} \;
find ~/.config/panel-colorizer/ -type f -exec sed -i "s/^marginRules=.*/marginRules=$MARGIN_WIDGET_RULES/" {} \;
find ~/.config/panel-colorizer/ -type f -exec sed -i "s/^forceRecolor=.*/forceRecolor=$FORCE_ICON_COLOR_WIDGETS/" {} \;
