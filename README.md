# codex-bark-notify

Send a Bark push notification to your phone when a Codex turn finishes.

It uses Codex's existing `notify` config, keeps the original desktop notification command, and adds a Bark push with the current session name when available.

## Install

```bash
git clone https://github.com/benboerba/codex-bark-notify.git
cd codex-bark-notify
bash install.sh
```

Then edit:

```bash
open ~/.codex/bark-notify.env
```

Set your Bark endpoint:

```bash
BARK_ENDPOINT="https://api.day.app/your-bark-key"
```

## Test

```bash
~/.codex/scripts/codex-turn-ended-notify.sh '{"thread_name":"Bark test"}'
```

You should receive a push similar to:

```text
Codex 完成思考：Bark test
会话「Bark test」已结束，可以回来查看结果了。
```

## What It Changes

The installer:

- backs up `~/.codex/config.toml`
- saves the previous `notify` command to `~/.codex/bark-notify-original.json`
- installs `~/.codex/scripts/codex-turn-ended-notify.sh`
- writes `notify = ["~/.codex/scripts/codex-turn-ended-notify.sh"]` with the absolute path
- creates `~/.codex/bark-notify.env` if it does not already exist

Your Bark key stays local and is not committed to this repository.

## Uninstall

```bash
bash uninstall.sh
```

This restores the previous `notify` command when it was saved during install.

