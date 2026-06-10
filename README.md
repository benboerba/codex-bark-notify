# codex-bark-notify

Send a Bark push notification to your phone when a Codex turn finishes.

It uses Codex's existing `notify` config, keeps the original desktop notification command, and adds a Bark push with the current session name when available.

## Prerequisites

Install the Bark app on your iPhone first:

- App Store: search for `Bark`
- Open Bark and copy your push URL, usually like `https://api.day.app/your-bark-key`

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

The installer changes files under your local Codex config folder only. It does not change your projects.

Files it may modify or create:

- `~/.codex/config.toml`: updates the Codex `notify` command
- `~/.codex/scripts/codex-turn-ended-notify.sh`: installs or updates the Bark notification script
- `~/.codex/bark-notify-original.json`: stores your previous `notify` command so uninstall can restore it
- `~/.codex/bark-notify.env`: creates the Bark config file only if it does not already exist
- `~/.codex/bark-notify.log`: appends notification logs while the script runs
- `~/.codex/bark-notify-last.json`: stores the last sent session for duplicate-notification skipping
- `~/.codex/bark-notify-backups/`: stores automatic backups made by the installer

Before changing anything important, `install.sh` automatically backs up:

- `~/.codex/config.toml`
- existing `~/.codex/scripts/codex-turn-ended-notify.sh`, if present
- existing `~/.codex/bark-notify-original.json`, if present

Backups are saved in:

```bash
~/.codex/bark-notify-backups/
```

If you want an extra safety copy, manually back up your Codex config first:

```bash
cp ~/.codex/config.toml ~/.codex/config.toml.manual-bak
```

Your Bark key stays local and is not committed to this repository.

Duplicate notifications for the same session are skipped for 120 seconds by default. You can change this in `~/.codex/bark-notify.env`:

```bash
BARK_DEDUP_SECONDS="120"
```

## Uninstall

```bash
bash uninstall.sh
```

This restores the previous `notify` command when it was saved during install.

---

# 中文说明

这个小工具可以在 **Codex 当前回合完成思考 / 执行结束** 时，通过 Bark 给手机发一条通知。

它会尽量带上当前会话名，例如：

```text
Codex 完成思考：Bark test
会话「Bark test」已结束，可以回来查看结果了。
```

## 准备工作

先在 iPhone 上安装 Bark：

1. 打开 App Store，搜索并安装 `Bark`。
2. 打开 Bark，复制你的推送地址。
3. 地址通常长这样：

```bash
https://api.day.app/你的BarkKey
```

## 安装

```bash
git clone https://github.com/benboerba/codex-bark-notify.git
cd codex-bark-notify
bash install.sh
```

安装后打开配置文件：

```bash
open ~/.codex/bark-notify.env
```

把这一行：

```bash
BARK_ENDPOINT="https://api.day.app/your-bark-key"
```

改成你自己的 Bark 地址：

```bash
BARK_ENDPOINT="https://api.day.app/你的BarkKey"
```

## 测试

```bash
~/.codex/scripts/codex-turn-ended-notify.sh '{"thread_name":"Bark 测试"}'
```

如果手机收到通知，就说明配置成功。

## 它改了什么

安装脚本只会改你本机的 Codex 配置目录，不会改你的项目代码。

它可能会修改或创建这些文件：

- `~/.codex/config.toml`：修改 Codex 的 `notify` 配置
- `~/.codex/scripts/codex-turn-ended-notify.sh`：安装或更新 Bark 通知脚本
- `~/.codex/bark-notify-original.json`：保存你原来的 `notify` 命令，方便卸载时恢复
- `~/.codex/bark-notify.env`：只在不存在时创建，用来填写 Bark 地址
- `~/.codex/bark-notify.log`：脚本运行时追加通知日志
- `~/.codex/bark-notify-last.json`：记录上次通知，用来跳过重复通知
- `~/.codex/bark-notify-backups/`：安装脚本自动保存的备份目录

在修改重要文件前，`install.sh` 会自动备份：

- `~/.codex/config.toml`
- 如果已存在，备份 `~/.codex/scripts/codex-turn-ended-notify.sh`
- 如果已存在，备份 `~/.codex/bark-notify-original.json`

备份会放在：

```bash
~/.codex/bark-notify-backups/
```

如果你想更稳一点，也可以安装前自己手动备份一份：

```bash
cp ~/.codex/config.toml ~/.codex/config.toml.manual-bak
```

你的 Bark key 只保存在本机，不会提交到这个仓库。

默认会在 120 秒内跳过同一会话名的重复通知。你可以在 `~/.codex/bark-notify.env` 里调整：

```bash
BARK_DEDUP_SECONDS="120"
```

## 卸载

```bash
bash uninstall.sh
```

卸载时会尽量恢复安装前的 Codex `notify` 配置。
