import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    pluginId: "vpnControl"

    ToggleSetting {
        settingKey: "showLabel"
        label: I18n.trFor("vpnControl", "Show connection name")
        description: I18n.trFor("vpnControl", "Show the active VPN's name next to the icon in the bar")
        defaultValue: true
    }

    SelectionSetting {
        settingKey: "iconStyle"
        label: I18n.trFor("vpnControl", "Bar icon")
        description: I18n.trFor("vpnControl", "Globe matches the Control Center's VPN icon; key or shield keep them apart")
        options: [
            {
                label: I18n.trFor("vpnControl", "Key"),
                value: "key"
            },
            {
                label: I18n.trFor("vpnControl", "Shield"),
                value: "shield"
            },
            {
                label: I18n.trFor("vpnControl", "Globe"),
                value: "globe"
            }
        ]
        defaultValue: "key"
    }

    ToggleSetting {
        settingKey: "singleActive"
        label: I18n.trFor("vpnControl", "One VPN at a time")
        description: I18n.trFor("vpnControl", "Connecting a VPN disconnects any other active VPN")
        defaultValue: true
    }

    SelectionSetting {
        settingKey: "rightClickMode"
        label: I18n.trFor("vpnControl", "Right-click action")
        description: I18n.trFor("vpnControl", "Quick toggle reconnects the last VPN, or disconnects all if one is active")
        options: [
            {
                label: I18n.trFor("vpnControl", "Quick toggle"),
                value: "toggle"
            },
            {
                label: I18n.trFor("vpnControl", "Nothing"),
                value: "none"
            }
        ]
        defaultValue: "toggle"
    }
}
