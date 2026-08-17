import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "dlpwaters.meditations"
  ipcTarget: "dlpwaters.meditations"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root
  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string helperPath: Qt.resolvedUrl("next-page").toString().replace(/^file:\/\//, "")
  readonly property int desiredWidth: Style.space(620)
  readonly property int maximumHeight: Style.space(680)

  property bool loading: false
  property bool hasPage: false
  property string edition: "familiar"
  property string errorMessage: ""
  property string copiedText: ""
  property var page: ({})

  function open() {
    root.controller.show()
    root.nextPage()
    Qt.callLater(function() { keyCatcher.forceActiveFocus() })
  }

  function close() { root.controller.hide() }

  function nextPage() {
    if (pageProc.running) return
    root.loading = true
    root.errorMessage = ""
    pageProc.command = [root.helperPath]
    pageProc.running = true
  }

  function cycleEdition() {
    if (root.edition === "familiar") root.edition = "abbreviated"
    else if (root.edition === "abbreviated") root.edition = "original"
    else root.edition = "familiar"
  }

  function editionLabel() {
    if (root.edition === "abbreviated") return "Abbreviated"
    if (root.edition === "original") return "Original"
    return "Familiar"
  }

  function visibleText() {
    if (!root.hasPage) return ""
    if (root.edition === "abbreviated")
      return String(root.page.abbreviated || root.page.familiar || root.page.original || "")
    if (root.edition === "original") return String(root.page.original || "")
    return String(root.page.familiar || root.page.original || "")
  }

  function copyPage() {
    var passage = visibleText()
    if (!passage) return
    Quickshell.execDetached(["wl-copy", passage + "\n\n— Marcus Aurelius, " + String(root.page.label || "Meditations")])
    root.copiedText = "Copied"
    copiedTimer.restart()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  Process {
    id: pageProc
    stdout: StdioCollector { id: pageOutput; waitForEnd: true }
    stderr: StdioCollector { id: pageError; waitForEnd: true }
    onExited: function(exitCode) {
      root.loading = false
      if (exitCode !== 0) {
        root.hasPage = false
        root.errorMessage = String(pageError.text || "Could not load a passage.").trim()
        return
      }
      try {
        root.page = JSON.parse(pageOutput.text)
        root.hasPage = true
      } catch (error) {
        root.hasPage = false
        root.errorMessage = "The Meditations collection could not be read."
      }
      Qt.callLater(function() { keyCatcher.forceActiveFocus() })
    }
  }

  Timer {
    id: copiedTimer
    interval: 1400
    onTriggered: root.copiedText = ""
  }

  KeyboardPanel {
    id: meditationPanel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    centerOnBar: true
    focusTarget: keyCatcher
    contentWidth: meditationPanel.fittedContentWidth(root.desiredWidth)
    contentHeight: meditationPanel.fittedContentHeight(contentColumn.implicitHeight, root.maximumHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter
            || event.key === Qt.Key_N || event.key === Qt.Key_R) {
          root.nextPage()
          event.accepted = true
        } else if (event.key === Qt.Key_E) {
          root.cycleEdition()
          event.accepted = true
        } else if (event.key === Qt.Key_C) {
          root.copyPage()
          event.accepted = true
        }
      }

      Column {
        id: contentColumn
        width: parent.width
        spacing: Style.space(14)

        Row {
          width: parent.width
          spacing: Style.space(12)

          Text {
            text: "󰂺"
            color: Color.accent
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.display
          }

          Column {
            width: parent.width - Style.space(60)
            anchors.verticalCenter: parent.verticalCenter
            spacing: Style.space(2)

            Text {
              width: parent.width
              text: "Meditations"
              color: root.contentForeground
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.title
              font.bold: true
            }

            Text {
              width: parent.width
              text: root.loading ? "TURNING THE PAGE…" : String(root.page.label || "MARCUS AURELIUS").toUpperCase()
              color: Qt.darker(root.contentForeground, 1.4)
              font.family: root.contentFontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1.1
            }
          }
        }

        PanelSeparator { foreground: root.contentForeground }

        Text {
          visible: root.errorMessage === "" && root.hasPage
          width: parent.width
          text: root.visibleText()
          color: root.contentForeground
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.subtitle
          lineHeight: 1.18
          wrapMode: Text.WordWrap
        }

        Text {
          visible: root.errorMessage !== ""
          width: parent.width
          text: root.errorMessage
          color: Color.urgent
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }

        PanelSeparator { foreground: root.contentForeground }

        Row {
          width: parent.width
          spacing: Style.space(8)

          Button {
            text: root.loading ? "Loading…" : "Another page"
            foreground: root.contentForeground
            enabled: !root.loading
            onClicked: root.nextPage()
          }

          Button {
            text: root.copiedText === "" ? "Copy" : root.copiedText
            foreground: root.contentForeground
            enabled: !root.loading && root.hasPage
            onClicked: root.copyPage()
          }
        }

        Row {
          width: parent.width
          spacing: Style.space(8)

          Text {
            text: "Edition:"
            color: root.contentForeground
            font.family: root.contentFontFamily
            font.pixelSize: Style.font.body
            anchors.verticalCenter: parent.verticalCenter
          }

          Button {
            text: "Familiar"
            foreground: root.edition === "familiar" ? Color.accent : root.contentForeground
            enabled: root.hasPage
            onClicked: root.edition = "familiar"
          }

          Button {
            text: "Abbreviated"
            foreground: root.edition === "abbreviated" ? Color.accent : root.contentForeground
            enabled: root.hasPage
            onClicked: root.edition = "abbreviated"
          }

          Button {
            text: "Original"
            foreground: root.edition === "original" ? Color.accent : root.contentForeground
            enabled: root.hasPage
            onClicked: root.edition = "original"
          }
        }

        Text {
          width: parent.width
          text: root.page.total ? String(root.page.remaining_in_cycle) + " / " + String(root.page.total) + " unseen" : ""
          color: Qt.darker(root.contentForeground, 1.55)
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.caption
          horizontalAlignment: Text.AlignRight
        }

        Text {
          width: parent.width
          text: "space next · e edition · c copy · esc close"
          color: Qt.darker(root.contentForeground, 1.7)
          font.family: root.contentFontFamily
          font.pixelSize: Style.font.caption
          horizontalAlignment: Text.AlignRight
        }
      }
    }
  }
}
