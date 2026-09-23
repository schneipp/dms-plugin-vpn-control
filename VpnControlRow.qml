import QtQuick
import qs.Common
import qs.Services
import qs.Widgets

StyledRect {
    id: row

    property var profile: null

    signal toggleRequested(string uuid)

    readonly property string uuid: profile?.uuid ?? ""
    readonly property bool isActive: DMSNetworkService.vpnStateForUuid(uuid) === "activated"
    readonly property bool isConnecting: DMSNetworkService.isVpnConnectingUuid(uuid)
    readonly property bool hasError: !isConnecting && DMSNetworkService.vpnError !== "" && DMSNetworkService.vpnErrorUuid === uuid
    readonly property bool locked: DMSNetworkService.vpnIsBusy && !isConnecting

    height: 56
    radius: Theme.cornerRadius
    color: isActive ? Theme.primaryHover : (rowArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh)
    opacity: locked ? 0.5 : 1

    DankIcon {
        id: typeIcon
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        name: profile?.type === "wireguard" ? "shield" : "vpn_key"
        size: Theme.iconSize - 4
        color: row.hasError ? Theme.error : (row.isActive ? Theme.primary : Theme.surfaceVariantText)
    }

    Column {
        anchors.left: typeIcon.right
        anchors.leftMargin: Theme.spacingM
        anchors.right: toggle.left
        anchors.rightMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacingXXS

        StyledText {
            width: parent.width
            text: row.profile?.name ?? ""
            elide: Text.ElideRight
            color: Theme.surfaceText
            font.pixelSize: Theme.fontSizeMedium
            font.weight: row.isActive ? Font.Medium : Font.Normal
        }

        StyledText {
            width: parent.width
            elide: Text.ElideRight
            color: row.hasError ? Theme.error : Theme.surfaceVariantText
            font.pixelSize: Theme.fontSizeSmall
            text: {
                if (row.isConnecting)
                    return I18n.trFor("vpnControl", "Connecting…");
                if (row.hasError)
                    return DMSNetworkService.vpnError;
                return VPNService.getVpnTypeFromProfile(row.profile);
            }
        }
    }

    MouseArea {
        id: rowArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !row.locked
        cursorShape: DMSNetworkService.vpnIsBusy ? Qt.BusyCursor : Qt.PointingHandCursor
        onClicked: row.toggleRequested(row.uuid)
    }

    DankToggle {
        id: toggle
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacingM
        anchors.verticalCenter: parent.verticalCenter
        checked: row.isActive
        toggling: row.isConnecting
        enabled: !row.locked
        onToggled: row.toggleRequested(row.uuid)
    }
}
