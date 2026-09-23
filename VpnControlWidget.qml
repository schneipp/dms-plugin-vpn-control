import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    layerNamespacePlugin: "vpn-control"

    // Keeps DMSNetworkService subscribed to backend state while the widget exists.
    Ref {
        service: DMSNetworkService
    }

    property bool showLabel: pluginData.showLabel ?? true
    property bool singleActive: pluginData.singleActive ?? true
    property string rightClickMode: pluginData.rightClickMode ?? "toggle"

    readonly property bool available: DMSNetworkService.vpnAvailable
    readonly property bool connected: DMSNetworkService.vpnConnected
    readonly property bool busy: DMSNetworkService.vpnIsBusy
    readonly property var profiles: DMSNetworkService.vpnProfiles || []
    readonly property var activeNames: DMSNetworkService.activeNames || []

    readonly property string statusText: {
        if (!root.available)
            return I18n.trFor("vpnControl", "Unavailable");
        if (root.busy && !root.connected)
            return I18n.trFor("vpnControl", "Connecting…");
        if (!root.connected)
            return I18n.trFor("vpnControl", "VPN off");
        if (root.activeNames.length > 1)
            return I18n.trFor("vpnControl", "%1 +%2").arg(root.activeNames[0]).arg(root.activeNames.length - 1);
        return root.activeNames[0] || I18n.trFor("vpnControl", "Connected");
    }

    property string iconStyle: pluginData.iconStyle ?? "key"

    // "globe" matches the icon the Control Center button already shows, so it isn't the default.
    readonly property var iconSets: ({
            "key": {
                on: "vpn_key",
                off: "vpn_key_off"
            },
            "shield": {
                on: "shield_lock",
                off: "remove_moderator"
            },
            "globe": {
                on: "vpn_lock",
                off: "vpn_key_off"
            }
        })
    readonly property var iconSet: root.iconSets[root.iconStyle] ?? root.iconSets.key
    readonly property string statusIcon: root.available && root.connected ? root.iconSet.on : root.iconSet.off
    readonly property color statusColor: !root.available ? Theme.error : (root.connected ? Theme.primary : Theme.widgetIconColor)

    function toggleProfile(uuid) {
        if (!root.available || root.busy)
            return;
        if (DMSNetworkService.isActiveVpnUuid(uuid))
            DMSNetworkService.disconnectVpn(uuid);
        else
            DMSNetworkService.connectVpn(uuid, root.singleActive);
    }

    function quickToggle() {
        if (!root.available || root.busy)
            return;
        if (root.connected) {
            DMSNetworkService.disconnectAllVpns();
            return;
        }
        const target = DMSNetworkService.lastConnectedVpnUuid || (root.profiles.length > 0 ? root.profiles[0].uuid : "");
        if (target)
            DMSNetworkService.connectVpn(target, root.singleActive);
        else
            ToastService.showWarning(I18n.trFor("vpnControl", "No VPN connections configured"));
    }

    pillRightClickAction: () => {
        if (root.rightClickMode === "toggle")
            root.quickToggle();
    }

    // Control Center tile
    ccWidgetIcon: root.statusIcon
    ccWidgetPrimaryText: I18n.trFor("vpnControl", "VPN")
    ccWidgetSecondaryText: root.statusText
    ccWidgetIsActive: root.connected
    onCcWidgetToggled: root.quickToggle()

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.statusIcon
                size: root.iconSize
                color: root.statusColor
                opacity: root.busy ? 0.5 : 1
                anchors.verticalCenter: parent.verticalCenter

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.shortDuration
                    }
                }
            }

            StyledText {
                visible: root.showLabel
                text: root.statusText
                color: root.connected ? Theme.surfaceText : Theme.surfaceVariantText
                font.pixelSize: Theme.fontSizeMedium
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXXS

            DankIcon {
                name: root.statusIcon
                size: root.iconSize
                color: root.statusColor
                opacity: root.busy ? 0.5 : 1
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                visible: root.showLabel && root.connected
                text: root.activeNames.length > 1 ? "+" + root.activeNames.length : ""
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout

            headerText: I18n.trFor("vpnControl", "VPN Connections")
            detailsText: root.connected ? I18n.trFor("vpnControl", "Connected: %1").arg(root.activeNames.join(", ")) : I18n.trFor("vpnControl", "Not connected")
            showCloseButton: true

            headerActions: Component {
                DankActionButton {
                    visible: root.connected
                    iconName: "link_off"
                    iconColor: Theme.error
                    tooltipText: I18n.trFor("vpnControl", "Disconnect all")
                    onClicked: DMSNetworkService.disconnectAllVpns()
                }
            }

            Item {
                width: parent.width
                implicitHeight: root.popoutHeight - popout.headerHeight - popout.detailsHeight - Theme.spacingXL * 2

                StyledText {
                    anchors.centerIn: parent
                    width: parent.width
                    visible: !root.available || root.profiles.length === 0
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    color: Theme.surfaceVariantText
                    font.pixelSize: Theme.fontSizeMedium
                    text: !root.available ? I18n.trFor("vpnControl", "The DMS network backend isn't available. Make sure NetworkManager and the dms server are running.") : I18n.trFor("vpnControl", "No VPN connections found. Add one in Settings → Network → VPN or with nmcli.")
                }

                DankFlickable {
                    anchors.fill: parent
                    visible: root.available && root.profiles.length > 0
                    clip: true
                    contentHeight: profileColumn.implicitHeight

                    Column {
                        id: profileColumn
                        width: parent.width
                        spacing: Theme.spacingS

                        Repeater {
                            model: root.profiles

                            VpnControlRow {
                                required property var modelData
                                width: profileColumn.width
                                profile: modelData
                                onToggleRequested: uuid => root.toggleProfile(uuid)
                            }
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 380
    popoutHeight: Math.min(480, 150 + Math.max(1, root.profiles.length) * 64)
}
