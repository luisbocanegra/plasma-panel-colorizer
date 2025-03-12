import QtQuick
import org.kde.taskmanager as TaskManager

Item {
    id: root

    property var screenGeometry
    property bool activeExists: false
    property bool maximizedExists: false
    property bool fullscreenExists: false
    property bool visibleExists: false
    property var abstractTasksModel: TaskManager.AbstractTasksModel
    property var isMaximized: abstractTasksModel.IsMaximized
    property var isActive: abstractTasksModel.IsActive
    property var isWindow: abstractTasksModel.IsWindow
    property var isFullScreen: abstractTasksModel.IsFullScreen
    property var isMinimized: abstractTasksModel.IsMinimized
    property bool filterByActive: false
    property var activeTask: null

    function updateWindowsinfo() {
        let activeCount = 0;
        let visibleCount = 0;
        let maximizedCount = 0;
        let fullscreenCount = 0;
        for (var i = 0; i < tasksModel.count; i++) {
            const currentTask = tasksModel.index(i, 0);
            if (currentTask === undefined || !tasksModel.data(currentTask, isWindow))
                continue;

            const active = tasksModel.data(currentTask, isActive);
            if (!tasksModel.data(currentTask, isMinimized))
                visibleCount += 1;

            if (filterByActive && !active)
                continue;

            if (active)
                activeTask = currentTask;

            if (tasksModel.data(currentTask, isMaximized))
                maximizedCount += 1;

            if (tasksModel.data(currentTask, isFullScreen))
                fullscreenCount += 1;
        }
        root.visibleExists = visibleCount > 0;
        root.maximizedExists = filterByActive ? tasksModel.data(activeTask, isMaximized) : maximizedCount > 0;
        root.fullscreenExists = filterByActive ? tasksModel.data(activeTask, isFullScreen) : fullscreenCount > 0;
        root.activeExists = activeCount > 0;
    }

    Connections {
        function onValueChanged() {
            if (!updateTimer.running)
                updateTimer.start();
        }

        target: plasmoid.configuration
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
            Qt.callLater(() => {
                if (!updateTimer.running)
                    updateTimer.start();
            });
        }
        onCountChanged: {
            Qt.callLater(() => {
                if (!updateTimer.running)
                    updateTimer.start();
            });
        }
    }

    Timer {
        id: updateTimer

        interval: 5
        onTriggered: {
            root.updateWindowsinfo();
        }
    }
}
