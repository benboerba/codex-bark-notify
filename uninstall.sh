#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CONFIG_FILE="$CODEX_HOME_DIR/config.toml"
SCRIPT_PATH="$CODEX_HOME_DIR/scripts/codex-turn-ended-notify.sh"
ORIGINAL_NOTIFY_FILE="$CODEX_HOME_DIR/bark-notify-original.json"

if [[ -f "$CONFIG_FILE" && -f "$ORIGINAL_NOTIFY_FILE" ]]; then
  python3 - "$CONFIG_FILE" "$ORIGINAL_NOTIFY_FILE" <<'PY'
import json
import re
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
original_path = Path(sys.argv[2])
text = config_path.read_text(encoding="utf-8")
notify = json.loads(original_path.read_text(encoding="utf-8"))
line = "notify = " + json.dumps(notify, ensure_ascii=False)

if re.search(r"(?m)^notify\s*=", text):
    text = re.sub(r"(?m)^notify\s*=.*$", line, text, count=1)
else:
    text = line + "\n" + text

config_path.write_text(text, encoding="utf-8")
PY
fi

rm -f "$SCRIPT_PATH"
echo "Uninstalled codex-bark-notify. Bark env and backups were left in ~/.codex."

