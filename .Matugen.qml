pragma Singleton

import Quickshell
import QtQuick
Singleton{
<* for name, value in colors *>
  readonly property color {{ name }}: "{{ value.default.hex }}"
  readonly property color {{ name }}_a: "#{{custom.alpha_hex}}{{ value.default.hex_stripped }}"
<* endfor *>
}
