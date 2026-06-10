#!/usr/bin/env bash
set -euo pipefail

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CONFIG_FILE="$CODEX_HOME_DIR/config.toml"
SCRIPT_DIR="$CODEX_HOME_DIR/scripts"
SCRIPT_PATH="$SCRIPT_DIR/codex-turn-ended-notify.sh"
ORIGINAL_NOTIFY_FILE="$CODEX_HOME_DIR/bark-notify-original.json"
BACKUP_DIR="$CODEX_HOME_DIR/bark-notify-backups"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$SCRIPT_DIR" "$BACKUP_DIR"

if [[ ! -f "$CONFIG_FILE" ]]; then
  touch "$CONFIG_FILE"
fi

backup="$BACKUP_DIR/config.toml.$(date '+%Y%m%d-%H%M%S').bak"
cp "$CONFIG_FILE" "$backup"

if [[ -f "$SCRIPT_PATH" ]]; then
  cp "$SCRIPT_PATH" "$BACKUP_DIR/codex-turn-ended-notify.sh.$(date '+%Y%m%d-%H%M%S').bak"
fi

if [[ -f "$ORIGINAL_NOTIFY_FILE" ]]; then
  cp "$ORIGINAL_NOTIFY_FILE" "$BACKUP_DIR/bark-notify-original.json.$(date '+%Y%m%d-%H%M%S').bak"
fi

python3 - "$CONFIG_FILE" "$ORIGINAL_NOTIFY_FILE" "$SCRIPT_PATH" <<'PY'
import json
import re
import sys
from pathlib import Path

config_path = Path(sys.argv[1])
original_path = Path(sys.argv[2])
script_path = sys.argv[3]
text = config_path.read_text(encoding="utf-8")

try:
    import tomllib
    parsed = tomllib.loads(text)
    notify = parsed.get("notify")
except Exception:
    notify = None

if isinstance(notify, list) and notify and notify[0] != script_path:
    original_path.write_text(json.dumps(notify, ensure_ascii=False, indent=2), encoding="utf-8")

new_line = 'notify = ["{}"]'.format(script_path.replace("\\", "\\\\").replace('"', '\\"'))
if re.search(r"(?m)^notify\s*=", text):
    text = re.sub(r"(?m)^notify\s*=.*$", new_line, text, count=1)
else:
    if text and not text.endswith("\n"):
        text += "\n"
    text = new_line + "\n" + text

config_path.write_text(text, encoding="utf-8")
PY

cp "$REPO_DIR/codex-turn-ended-notify.sh" "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

if [[ ! -f "$CODEX_HOME_DIR/bark-notify.env" ]]; then
  cp "$REPO_DIR/bark-notify.env.example" "$CODEX_HOME_DIR/bark-notify.env"
fi

echo "Installed codex-bark-notify."
echo "Config backup: $backup"
echo "Edit Bark endpoint: $CODEX_HOME_DIR/bark-notify.env"
echo "Test: $SCRIPT_PATH '{\"thread_name\":\"Bark test\"}'"
