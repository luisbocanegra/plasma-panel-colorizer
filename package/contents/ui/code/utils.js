function getRandomColor() {
  const h = Math.random()
  const s = Math.max(Math.random(), 0.3)
  const l = 0.4
  const a = 1.0
  return Qt.hsla(h, s, l, a)
}

function isBgManaged(item) {
  let managed = false
  if (item?.children) {
    for (let i in item.children) {
      const child = item.children[i];
      if (!child?.luisbocanegraPanelColorizerBgManaged) continue
      managed = true
    }
  }
  // console.error(item, "managed:", managed);
  return managed
}

function findTrayGridView(item) {
  if (!item?.children) return null
  if (item instanceof GridView) {
    return item;
  }
  for (let i = 0; i < item.children.length; i++) {
    let result = findTrayGridView(item.children[i]);
    if (result) {
      return result;
    }
  }
  return null;
}


function findTrayExpandArrow(item) {
  if (item instanceof GridLayout) {
    for (let i in item.children) {
      const child = item.children[i]
      if (!(child instanceof GridView)) {
        return child
      }
    }
  }
  return null
}


function panelOpacity(panelElement, enabled, panelRealBgOpacity) {
  for (let i in panelElement.children) {
    const current = panelElement.children[i]

    if (current.imagePath && current.imagePath.toString().includes("panel-background")) {
      current.opacity = enabled ? panelRealBgOpacity : 1
    }
  }
}

function dumpProps(obj) {
  console.error("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
  console.error(obj);
  for (var k of Object.keys(obj)) {
    const val = obj[k]
    if (typeof val === 'function') continue
    if (k === 'metaData') continue
    console.log(k + "=" + val + "\n")
  }
}

function toggleTransparency(containmentItem, enabled) {
  containmentItem.Plasmoid.backgroundHints = enabled
    ? PlasmaCore.Types.NoBackground
    : PlasmaCore.Types.DefaultBackground
}
