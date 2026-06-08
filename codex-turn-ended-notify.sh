#!/usr/bin/env bash
set -u

CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CONFIG_FILE="${CODEX_BARK_CONFIG:-$CODEX_HOME_DIR/bark-notify.env}"
ORIGINAL_NOTIFY_FILE="$CODEX_HOME_DIR/bark-notify-original.json"
LOG_FILE="$CODEX_HOME_DIR/bark-notify.log"

call_original_notify() {
  [[ -f "$ORIGINAL_NOTIFY_FILE" ]] || return 0

  python3 - "$ORIGINAL_NOTIFY_FILE" "$@" <<'PY' >/dev/null 2>&1 &
import json
import subprocess
import sys
from pathlib import Path

path = Path(sys.argv[1])
extra_args = sys.argv[2:]
try:
    command = json.loads(path.read_text(encoding="utf-8"))
except Exception:
    raise SystemExit

if not isinstance(command, list) or not command:
    raise SystemExit
if any(not isinstance(part, str) or not part for part in command):
    raise SystemExit
if command[0].endswith("codex-turn-ended-notify.sh"):
    raise SystemExit

subprocess.Popen(command + extra_args)
PY
}

session_name_from_args() {
  local arg
  for arg in "$@"; do
    if [[ "$arg" == \{* ]]; then
      python3 -c '
import json, sys
try:
    data = json.loads(sys.argv[1])
except Exception:
    sys.exit(0)
for key in ("thread_name", "session_name", "conversation_name", "title", "name"):
    value = data.get(key)
    if isinstance(value, str) and value.strip():
        print(value.strip())
        break
' "$arg" 2>/dev/null && return 0
    fi

    case "$arg" in
      turn-ended|manual-test|test|test-run|"") ;;
      *) printf '%s\n' "$arg"; return 0 ;;
    esac
  done
}

latest_active_session_label() {
  python3 - "$CODEX_HOME_DIR" <<'PY' 2>/dev/null
import glob
import json
import os
import sys
import time
from pathlib import Path

codex_home = Path(sys.argv[1])
now = time.time()
session_files = sorted(
    glob.glob(str(codex_home / "sessions" / "**" / "*.jsonl"), recursive=True),
    key=lambda p: os.path.getmtime(p),
    reverse=True,
)

active_path = None
for candidate in session_files:
    if now - os.path.getmtime(candidate) <= 600:
        active_path = Path(candidate)
        break

if active_path is None:
    raise SystemExit

session_id = None
last_user_text = None
with active_path.open(encoding="utf-8") as fh:
    for line in fh:
        try:
            item = json.loads(line)
        except Exception:
            continue
        if item.get("type") == "session_meta":
            session_id = (item.get("payload") or {}).get("id")
        payload = item.get("payload") or {}
        if item.get("type") == "response_item" and payload.get("type") == "message" and payload.get("role") == "user":
            parts = []
            for content in payload.get("content") or []:
                text = content.get("text") or ""
                if not text or "<environment_context>" in text or "<turn_aborted>" in text:
                    continue
                parts.append(" ".join(text.split()))
            if parts:
                last_user_text = " ".join(parts)

index_path = codex_home / "session_index.jsonl"
if session_id and index_path.exists():
    with index_path.open(encoding="utf-8") as fh:
        for line in fh:
            try:
                item = json.loads(line)
            except Exception:
                continue
            if item.get("id") == session_id:
                name = (item.get("thread_name") or "").strip()
                if name:
                    print(name[:80])
                    raise SystemExit

if last_user_text:
    print(last_user_text[:80])
PY
}

call_original_notify "$@"

if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
fi

if [[ -z "${BARK_ENDPOINT:-}" || "$BARK_ENDPOINT" == *"your-bark-key"* || "$BARK_ENDPOINT" == *"替换成你的"* ]]; then
  exit 0
fi

SESSION_NAME="$(session_name_from_args "$@")"
if [[ -z "$SESSION_NAME" ]]; then
  SESSION_NAME="$(latest_active_session_label)"
fi
if [[ -z "$SESSION_NAME" ]]; then
  SESSION_NAME="当前 Codex 会话"
fi

TITLE_PREFIX="${BARK_TITLE_PREFIX:-Codex 完成思考}"
TITLE="${BARK_TITLE:-${TITLE_PREFIX}：${SESSION_NAME}}"
BODY="${BARK_BODY:-会话「${SESSION_NAME}」已结束，可以回来查看结果了。}"
GROUP="${BARK_GROUP:-Codex}"
SOUND="${BARK_SOUND:-bell}"

{
  printf '[%s] sending Bark notification for session: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$SESSION_NAME"
  curl -fsS --max-time 8 -G "$BARK_ENDPOINT" \
    --data-urlencode "title=$TITLE" \
    --data-urlencode "body=$BODY" \
    --data-urlencode "group=$GROUP" \
    --data-urlencode "sound=$SOUND" \
    >/dev/null
} >>"$LOG_FILE" 2>&1 || true

