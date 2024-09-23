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
import org.kde.taskmanager 0.1 as TaskManager

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

    Connections {
        target: plasmoid.configuration
        function onValueChanged() {
            updateWindowsinfo()
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

        onActiveTaskChanged: {
            updateWindowsinfo()
        }
        onDataChanged: {
            updateWindowsinfo()
        }
        onCountChanged: {
            updateWindowsinfo()
        }
    }

    function updateWindowsinfo() {
        let activeCount = 0
        let visibleCount = 0
        let maximizedCount = 0
        for (var i = 0; i < tasksModel.count; i++) {
            const currentTask = tasksModel.index(i, 0)
            if (currentTask === undefined) continue
            if (tasksModel.data(currentTask, isWindow)) {
                if (tasksModel.data(currentTask, isMaximized) || tasksModel.data(currentTask, isFullScreen)) maximizedCount+=1
            }
        }
        root.visibleExists = visibleCount > 0
        root.maximizedExists = maximizedCount > 0
        root.activeExists = activeCount > 0
    }
}

