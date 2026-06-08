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

安装脚本会：

- 备份 `~/.codex/config.toml`
- 保存你原来的 `notify` 命令到 `~/.codex/bark-notify-original.json`
- 安装通知脚本到 `~/.codex/scripts/codex-turn-ended-notify.sh`
- 把 Codex 的 `notify` 指向这个通知脚本
- 如果还没有配置文件，就创建 `~/.codex/bark-notify.env`

你的 Bark key 只保存在本机，不会提交到这个仓库。

## 卸载

```bash
bash uninstall.sh
```

卸载时会尽量恢复安装前的 Codex `notify` 配置。
