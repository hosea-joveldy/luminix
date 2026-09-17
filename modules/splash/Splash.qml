import QtQuick 2.5

Rectangle {
    id: root
    color: "#101314"

    property int stage
    onStageChanged: {
        if (stage == 1) introAnimation.running = true
    }

    Image {
        id: logo
        anchors.centerIn: parent
        source: "images/nix-snowflake.svg"
        sourceSize.width: 128
        sourceSize.height: 128
        opacity: 0
        NumberAnimation on opacity {
            id: introAnimation
            running: false
            from: 0
            to: 1
            duration: 800
        }
    }

    BusyIndicator {
        anchors.top: logo.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        running: true
    }
}
