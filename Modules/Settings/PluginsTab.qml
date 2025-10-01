import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Common
import qs.Services
import qs.Widgets

Item {
    id: pluginsTab

    property string expandedPluginId: ""

    Component.onCompleted: {
        console.log("PluginsTab: Component completed")
        console.log("PluginsTab: PluginService available:", typeof PluginService !== "undefined")
        if (typeof PluginService !== "undefined") {
            console.log("PluginsTab: Available plugins:", Object.keys(PluginService.availablePlugins).length)
            console.log("PluginsTab: Plugin directory:", PluginService.pluginDirectory)
        }
    }

    DankFlickable {
        anchors.fill: parent
        anchors.topMargin: Theme.spacingL
        clip: true
        contentHeight: mainColumn.height
        contentWidth: width

        Column {
            id: mainColumn

            width: parent.width
            spacing: Theme.spacingXL

            StyledRect {
                width: parent.width
                height: headerColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0

                Column {
                    id: headerColumn

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankIcon {
                            name: "extension"
                            size: Theme.iconSize
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: Theme.spacingXS

                            StyledText {
                                text: "Plugin Management"
                                font.pixelSize: Theme.fontSizeLarge
                                color: Theme.surfaceText
                                font.weight: Font.Medium
                            }

                            StyledText {
                                text: "Manage and configure plugins for extending DMS functionality"
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                            }
                        }
                    }

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        DankButton {
                            text: "Scan for Plugins"
                            iconName: "refresh"
                            onClicked: {
                                PluginService.scanPlugins()
                                ToastService.showInfo("Scanning for plugins...")
                            }
                        }

                        DankButton {
                            text: "Create Plugin Directory"
                            iconName: "create_new_folder"
                            onClicked: {
                                PluginService.createPluginDirectory()
                                ToastService.showInfo("Created plugin directory: " + PluginService.pluginDirectory)
                            }
                        }
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: directoryColumn.implicitHeight + Theme.spacingL * 2
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0

                Column {
                    id: directoryColumn

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Plugin Directory"
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    StyledText {
                        text: PluginService.pluginDirectory
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        font.family: "monospace"
                    }

                    StyledText {
                        text: "Place plugin directories here. Each plugin should have a plugin.json manifest file."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            StyledRect {
                width: parent.width
                height: Math.max(200, availableColumn.implicitHeight + Theme.spacingL * 2)
                radius: Theme.cornerRadius
                color: Theme.surfaceContainerHigh
                border.width: 0

                Column {
                    id: availableColumn

                    anchors.fill: parent
                    anchors.margins: Theme.spacingL
                    spacing: Theme.spacingM

                    StyledText {
                        text: "Available Plugins"
                        font.pixelSize: Theme.fontSizeLarge
                        color: Theme.surfaceText
                        font.weight: Font.Medium
                    }

                    Item {
                        width: parent.width
                        height: Math.max(150, pluginListView.contentHeight)

                        ListView {
                            id: pluginListView

                            anchors.fill: parent
                            model: PluginService.getAvailablePlugins()
                            spacing: Theme.spacingM
                            clip: true

                            delegate: StyledRect {
                                id: pluginDelegate
                                width: pluginListView.width
                                height: pluginItemColumn.implicitHeight + Theme.spacingM * 2 + settingsContainer.height
                                radius: Theme.cornerRadius

                                property var pluginData: modelData
                                property string pluginId: pluginData ? pluginData.id : ""
                                property string pluginName: pluginData ? (pluginData.name || pluginData.id) : ""
                                property string pluginVersion: pluginData ? (pluginData.version || "1.0.0") : ""
                                property string pluginAuthor: pluginData ? (pluginData.author || "Unknown") : ""
                                property string pluginDescription: pluginData ? (pluginData.description || "") : ""
                                property string pluginIcon: pluginData ? (pluginData.icon || "extension") : "extension"
                                property string pluginSettingsPath: pluginData ? (pluginData.settingsPath || "") : ""
                                property var pluginPermissions: pluginData ? (pluginData.permissions || []) : []
                                property bool hasSettings: pluginData && pluginData.settings !== undefined && pluginData.settings !== ""
                                property bool isExpanded: pluginsTab.expandedPluginId === pluginId

                                onIsExpandedChanged: {
                                    console.log("Plugin", pluginId, "isExpanded changed to:", isExpanded)
                                }

                                color: pluginMouseArea.containsMouse ? Theme.surfacePressed : (isExpanded ? Theme.surfaceContainerHighest : Theme.surfaceContainer)
                                border.width: 0

                                Behavior on height {
                                    NumberAnimation {
                                        duration: Theme.mediumDuration
                                        easing.type: Theme.standardEasing
                                    }
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.shortDuration
                                        easing.type: Theme.standardEasing
                                    }
                                }

                                MouseArea {
                                    id: pluginMouseArea
                                    anchors.fill: parent
                                    anchors.bottomMargin: pluginDelegate.isExpanded ? settingsContainer.height : 0
                                    hoverEnabled: true
                                    cursorShape: pluginDelegate.hasSettings ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        console.log("Plugin clicked:", pluginDelegate.pluginId, "hasSettings:", pluginDelegate.hasSettings, "isLoaded:", PluginService.isPluginLoaded(pluginDelegate.pluginId))
                                        if (pluginDelegate.hasSettings) {
                                            if (pluginsTab.expandedPluginId === pluginDelegate.pluginId) {
                                                console.log("Collapsing plugin:", pluginDelegate.pluginId)
                                                pluginsTab.expandedPluginId = ""
                                            } else {
                                                console.log("Expanding plugin:", pluginDelegate.pluginId)
                                                pluginsTab.expandedPluginId = pluginDelegate.pluginId
                                            }
                                        }
                                    }
                                }

                                Column {
                                    id: pluginItemColumn
                                    width: parent.width
                                    anchors.top: parent.top
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.margins: Theme.spacingM
                                    spacing: Theme.spacingS

                                    Row {
                                        width: parent.width
                                        spacing: Theme.spacingM

                                        DankIcon {
                                            name: pluginDelegate.pluginIcon
                                            size: Theme.iconSize
                                            color: PluginService.isPluginLoaded(pluginDelegate.pluginId) ? Theme.primary : Theme.surfaceVariantText
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Column {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 2
                                            width: parent.width - 250

                                            Row {
                                                spacing: Theme.spacingXS
                                                width: parent.width

                                                StyledText {
                                                    text: pluginDelegate.pluginName
                                                    font.pixelSize: Theme.fontSizeMedium
                                                    color: Theme.surfaceText
                                                    font.weight: Font.Medium
                                                    anchors.verticalCenter: parent.verticalCenter
                                                }

                                                DankIcon {
                                                    name: pluginDelegate.hasSettings ? (pluginDelegate.isExpanded ? "expand_less" : "expand_more") : ""
                                                    size: 16
                                                    color: pluginDelegate.hasSettings ? Theme.primary : "transparent"
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    visible: pluginDelegate.hasSettings

                                                    Behavior on rotation {
                                                        NumberAnimation {
                                                            duration: Theme.shortDuration
                                                            easing.type: Theme.standardEasing
                                                        }
                                                    }
                                                }
                                            }

                                            StyledText {
                                                text: "v" + pluginDelegate.pluginVersion + " by " + pluginDelegate.pluginAuthor
                                                font.pixelSize: Theme.fontSizeSmall
                                                color: Theme.surfaceVariantText
                                                width: parent.width
                                                elide: Text.ElideRight
                                            }
                                        }

                                        Item {
                                            width: 10
                                            height: 1
                                        }

                                        DankToggle {
                                            anchors.verticalCenter: parent.verticalCenter
                                            checked: PluginService.isPluginLoaded(pluginDelegate.pluginId)
                                            onToggled: (isChecked) => {
                                                if (isChecked) {
                                                    if (PluginService.enablePlugin(pluginDelegate.pluginId)) {
                                                        ToastService.showInfo("Plugin enabled: " + pluginDelegate.pluginName)
                                                    } else {
                                                        ToastService.showError("Failed to enable plugin: " + pluginDelegate.pluginName)
                                                        checked = false
                                                    }
                                                } else {
                                                    if (PluginService.disablePlugin(pluginDelegate.pluginId)) {
                                                        ToastService.showInfo("Plugin disabled: " + pluginDelegate.pluginName)
                                                        if (pluginsTab.expandedPluginId === pluginDelegate.pluginId) {
                                                            pluginsTab.expandedPluginId = ""
                                                        }
                                                    } else {
                                                        ToastService.showError("Failed to disable plugin: " + pluginDelegate.pluginName)
                                                        checked = true
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    StyledText {
                                        width: parent.width
                                        text: pluginDelegate.pluginDescription
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        wrapMode: Text.WordWrap
                                        visible: pluginDelegate.pluginDescription !== ""
                                    }

                                    Flow {
                                        width: parent.width
                                        spacing: Theme.spacingXS
                                        visible: pluginDelegate.pluginPermissions && Array.isArray(pluginDelegate.pluginPermissions) && pluginDelegate.pluginPermissions.length > 0

                                        Repeater {
                                            model: pluginDelegate.pluginPermissions

                                            Rectangle {
                                                height: 20
                                                width: permissionText.implicitWidth + Theme.spacingXS * 2
                                                radius: 10
                                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                                                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
                                                border.width: 1

                                                StyledText {
                                                    id: permissionText
                                                    anchors.centerIn: parent
                                                    text: modelData
                                                    font.pixelSize: Theme.fontSizeSmall - 1
                                                    color: Theme.primary
                                                }
                                            }
                                        }
                                    }
                                }

                                // Settings container
                                Item {
                                    id: settingsContainer
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    height: pluginDelegate.isExpanded && pluginDelegate.hasSettings ? Math.min(500, settingsLoader.item ? settingsLoader.item.implicitHeight + Theme.spacingL * 2 : 200) : 0
                                    clip: true

                                    onHeightChanged: {
                                        console.log("Settings container height changed:", height, "for plugin:", pluginDelegate.pluginId)
                                    }

                                    Behavior on height {
                                        NumberAnimation {
                                            duration: Theme.mediumDuration
                                            easing.type: Theme.standardEasing
                                        }
                                    }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: Theme.surfaceContainerHighest
                                        radius: Theme.cornerRadius
                                        anchors.topMargin: Theme.spacingXS
                                        border.width: 0
                                    }

                                    DankFlickable {
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacingL
                                        contentHeight: settingsLoader.height
                                        contentWidth: width
                                        clip: true

                                        Loader {
                                            id: settingsLoader
                                            width: parent.width
                                            active: pluginDelegate.isExpanded && pluginDelegate.hasSettings && PluginService.isPluginLoaded(pluginDelegate.pluginId)
                                            asynchronous: false

                                            onActiveChanged: {
                                                console.log("Settings loader active changed to:", active, "for plugin:", pluginDelegate.pluginId,
                                                          "isExpanded:", pluginDelegate.isExpanded, "hasSettings:", pluginDelegate.hasSettings,
                                                          "isLoaded:", PluginService.isPluginLoaded(pluginDelegate.pluginId))
                                            }

                                            source: {
                                                if (active && pluginDelegate.pluginSettingsPath) {
                                                    console.log("Loading plugin settings from:", pluginDelegate.pluginSettingsPath)
                                                    var path = pluginDelegate.pluginSettingsPath
                                                    if (!path.startsWith("file://")) {
                                                        path = "file://" + path
                                                    }
                                                    return path
                                                }
                                                return ""
                                            }

                                            onStatusChanged: {
                                                console.log("Settings loader status changed:", status, "for plugin:", pluginDelegate.pluginId)
                                                if (status === Loader.Error) {
                                                    console.error("Failed to load plugin settings:", pluginDelegate.pluginSettingsPath)
                                                } else if (status === Loader.Ready) {
                                                    console.log("Settings successfully loaded for plugin:", pluginDelegate.pluginId)
                                                }
                                            }

                                            onLoaded: {
                                                if (item) {
                                                    console.log("Plugin settings loaded for:", pluginDelegate.pluginId)

                                                    // Make PluginService available to the loaded component
                                                    if (typeof PluginService !== "undefined") {
                                                        console.log("Making PluginService available to plugin settings")
                                                        console.log("PluginService functions available:",
                                                                  "savePluginData" in PluginService,
                                                                  "loadPluginData" in PluginService)
                                                        item.pluginService = PluginService
                                                        console.log("PluginService assignment completed, item.pluginService:", item.pluginService !== null)
                                                    } else {
                                                        console.error("PluginService not available in PluginsTab context")
                                                    }

                                                    // Connect to height changes for dynamic resizing
                                                    if (item.implicitHeightChanged) {
                                                        item.implicitHeightChanged.connect(function() {
                                                            console.log("Plugin settings height changed:", item.implicitHeight)
                                                        })
                                                    }

                                                    // Force load timezones for WorldClock plugin
                                                    if (item.loadTimezones) {
                                                        console.log("Calling loadTimezones for WorldClock plugin")
                                                        item.loadTimezones()
                                                    }
                                                    // Generic initialization for any plugin
                                                    if (item.initializeSettings) {
                                                        item.initializeSettings()
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: !PluginService.isPluginLoaded(pluginDelegate.pluginId) ?
                                              "Enable plugin to access settings" :
                                              (settingsLoader.status === Loader.Error ?
                                               "Failed to load settings" :
                                               "No configurable settings")
                                        font.pixelSize: Theme.fontSizeSmall
                                        color: Theme.surfaceVariantText
                                        visible: pluginDelegate.isExpanded && (!settingsLoader.active || settingsLoader.status === Loader.Error)
                                    }
                                }
                            }
                        }

                        StyledText {
                            anchors.centerIn: parent
                            text: "No plugins found.\nPlace plugins in " + PluginService.pluginDirectory
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceVariantText
                            horizontalAlignment: Text.AlignHCenter
                            visible: pluginListView.model.length === 0
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: PluginService
        function onPluginLoaded() {
            pluginListView.model = PluginService.getAvailablePlugins()
        }
        function onPluginUnloaded() {
            pluginListView.model = PluginService.getAvailablePlugins()
            if (pluginsTab.expandedPluginId !== "" && !PluginService.isPluginLoaded(pluginsTab.expandedPluginId)) {
                pluginsTab.expandedPluginId = ""
            }
        }
    }
}