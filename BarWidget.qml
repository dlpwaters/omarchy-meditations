import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "dlpwaters.meditations"

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function open() { if (panelLoader.item) panelLoader.item.open() }
  function close() { if (panelLoader.item) panelLoader.item.close() }
  function next() { if (panelLoader.item) panelLoader.item.nextPage() }
  function showEdition(name) {
    if (!panelLoader.item) return
    panelLoader.item.edition = name
    if (!panelLoader.item.opened) panelLoader.item.open()
  }
  function toggle() {
    if (!panelLoader.item) return
    if (panelLoader.item.opened) panelLoader.item.nextPage()
    else panelLoader.item.open()
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  IpcHandler {
    target: "dlpwaters.meditations"
    function open() { root.open() }
    function close() { root.close() }
    function show() { root.open() }
    function hide() { root.close() }
    function next() { root.next() }
    function familiar() { root.showEdition("familiar") }
    function abbreviated() { root.showEdition("abbreviated") }
    function original() { root.showEdition("original") }
    function toggle() { root.toggle() }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰂺"
    tooltipText: "Meditations"
    onPressed: function(mouseButton) {
      if (mouseButton !== Qt.RightButton) root.toggle()
    }
  }
}
