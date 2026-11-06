.pragma library

// Ctrl + vim keys for the cloned Omarchy shell menus (see install-omarchy-menu-vim-keys.sh).
// A key matches by Qt key (Latin layout, synthetic input) or by xkb keycode = evdev code + 8
// (physical key, any layout).
var H = { key: Qt.Key_H, scan: 43 }
var J = { key: Qt.Key_J, scan: 44 }
var K = { key: Qt.Key_K, scan: 45 }
var L = { key: Qt.Key_L, scan: 46 }
var N = { key: Qt.Key_N, scan: 57 }
var P = { key: Qt.Key_P, scan: 33 }

function ctrl(event, k) {
  return event.modifiers === Qt.ControlModifier && (event.key === k.key || event.nativeScanCode === k.scan)
}

function up(event) { return ctrl(event, K) || ctrl(event, P) }
function down(event) { return ctrl(event, J) || ctrl(event, N) }
function left(event) { return ctrl(event, H) }
function right(event) { return ctrl(event, L) }

// One-dimensional pickers (image carousel): every vim direction moves along it.
function prev(event) { return left(event) || up(event) }
function next(event) { return right(event) || down(event) }
