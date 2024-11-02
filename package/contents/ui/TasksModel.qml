/*
 *  Copyright 2018 Rog131 <samrog131@hotmail.com>
 *  Copyright 2019 adhe   <adhemarks2@gmail.com>
 *  Copyright 2024 Luis Bocanegra <luisbocanegra17b@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick
import org.kde.taskmanager as TaskManager

Item {

    id: root
    property var screenGeometry
    property bool activeExists: false
    property bool maximizedExists: false
    property bool visibleExists: false
    property var abstractTasksModel: TaskManager.AbstractTasksModel
    property var isMaximized: abstractTasksModel.IsMaximized
    property var isActive: abstractTasksModel.IsActive
    property var isWindow: abstractTasksModel.IsWindow
    property var isFullScreen: abstractTasksModel.IsFullScreen
    property var isMinimized: abstractTasksModel.IsMinimized
    property bool filterByActive: false
    property var activeTask: null

    Connections {
        target: plasmoid.configuration
        function onValueChanged() {
            if (!updateTimer.running) {
                updateTimer.start()
            }
        }
    }

    TaskManager.VirtualDesktopInfo {
        id: virtualDesktopInfo
    }

    TaskManager.ActivityInfo {
        id: activityInfo
        readonly property string nullUuid: "00000000-0000-0000-0000-000000000000"
    }

    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
        groupMode: TaskManager.TasksModel.GroupDisabled
        virtualDesktop: virtualDesktopInfo.currentDesktop
        activity: activityInfo.currentActivity
        screenGeometry: root.screenGeometry
        filterByVirtualDesktop: true
        filterByScreen: true
        filterByActivity: true
        filterMinimized: true

        onDataChanged: {
            if (!updateTimer.running) {
                updateTimer.start()
            }
        }
    }

    Timer {
        id: updateTimer
        interval: 5
        onTriggered: {
            updateWindowsinfo()
        }
    }

    function updateWindowsinfo() {
        let activeCount = 0
        let visibleCount = 0
        let maximizedCount = 0
        for (var i = 0; i < tasksModel.count; i++) {
            const currentTask = tasksModel.index(i, 0)
            if (currentTask === undefined || !tasksModel.data(currentTask, isWindow)) continue
            const active = tasksModel.data(currentTask, isActive)
            if (filterByActive && !active) continue
            if (active) activeTask = currentTask
            if (tasksModel.data(currentTask, isMaximized)) maximizedCount += 1
        }
        root.visibleExists = visibleCount > 0
        root.maximizedExists = filterByActive ? tasksModel.data(activeTask, isMaximized) : maximizedCount > 0
        root.activeExists = activeCount > 0
    }
}

