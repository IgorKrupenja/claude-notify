# Claude Notify

A Claude Code plugin for macOS: a banner when a session in the Claude desktop app finishes.

The app puts finished tasks in Notification Centre without a banner, so they are easy to miss.
This plugin shows one, with the session title and the first line of Claude's reply. Clicking it
opens that session in the app.

- It stays quiet while Claude is the frontmost app.
- It skips turns that end with a question, since the app shows its own banner for those.
- Sessions in the terminal or an IDE get no banner.

Not affiliated with Anthropic.

## Requirements

- macOS and the [Claude desktop app](https://claude.com/download)
- Xcode Command Line Tools (`xcode-select --install`), to build the small helper app that posts
  the banners

## Install

```bash
claude plugin marketplace add IgorKrupenja/claude-notify
claude plugin install session-banners@session-banners
```

Or run `/plugin marketplace add IgorKrupenja/claude-notify` and then
`/plugin install session-banners@session-banners` in a Claude Code session.

The next session builds the helper app, which takes about 15 seconds once. The first banner asks
you to allow notifications from Claude Notify. To keep banners on screen until you dismiss them,
set Claude Notify to Persistent in System Settings > Notifications.

## How it works

- A `SessionStart` hook builds `Claude Notify.app` from [`helper/`](plugins/session-banners/helper)
  into the plugin's data folder, `~/.claude/plugins/data/session-banners-session-banners/`, and
  rebuilds it when its sources change.
- A `Stop` hook, [`stop-hook.py`](plugins/session-banners/scripts/stop-hook.py), launches the
  helper with the banner text and the session's `claude://` link.

## Uninstall

```bash
claude plugin uninstall session-banners@session-banners
```
