# =============================================================
#  ~/.config/tg/conf.py — tg user configuration
#
#  This file contains ONLY overrides — no imports of runpy,
#  no CONFIG_FILE loading block. tg's own conf.py handles that.
#
#  Keybinding reference:
#    CHATS:  j/k move  l open  dd delete  m mute  p pin
#            u unread  / search  ng new group  ns secret
#    MSGS:   j/k move  l open file (mailcap)  D download
#            i/a insert  dd delete  y yank  p forward
#            r reply  o open url (URL_VIEW)  S file picker
#            sv/sa/sp/sd send video/audio/pic/doc
#            v voice msg  ! custom cmd  space select
# =============================================================

import os
import shutil

# ── Credentials ───────────────────────────────────────────────
# PHONE is set on first run and saved back here automatically.
# Register your own API at https://my.telegram.org/apps
API_ID   = 30340125
API_HASH = "4efe19c6c69b34a529dfee6858c3648f"
PHONE = "+212665951596"

# ── Paths ─────────────────────────────────────────────────────
FILES_DIR = os.path.join(
    os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "tg"
)
LOG_PATH = os.path.join(
    os.environ.get("XDG_STATE_HOME", os.path.expanduser("~/.local/state")), "tg"
)
DOWNLOAD_DIR = os.path.join(
    os.environ.get("XDG_DOWNLOAD_DIR", os.path.expanduser("~/Downloads")), ""
)

# ── Logging ───────────────────────────────────────────────────
LOG_LEVEL = "ERROR"   # set to DEBUG when troubleshooting

# ── TDLib ─────────────────────────────────────────────────────
TDLIB_VERBOSITY = 0
# TDLIB_PATH = "/usr/lib/libtdjson.so"  # uncomment if auto-detect fails

# ── Mailcap ───────────────────────────────────────────────────
# Used by 'l' key to open downloaded files by MIME type.
# This is the right tool for files — linkman handles URLs ('o' key).
MAILCAP_FILE = os.path.expanduser("~/.config/mailcap")

# ── File picker ───────────────────────────────────────────────
# Used by 'S' key to pick a file to send.
# tg-filepicker wraps lf using lfpicker config.
FILE_PICKER_CMD = "tg-filepicker {file_path}"

# ── URL handler ───────────────────────────────────────────────
# Used by 'o' key on messages containing URLs.
# When multiple URLs are present tg pipes them to URL_VIEW stdin.
# linkman reads one URL and routes it (mpv/nsxiv/browser).
URL_VIEW = "linkman"

# ── Editor / viewer ───────────────────────────────────────────
EDITOR = os.environ.get("EDITOR", "nvim")
VIEW_TEXT_CMD = "bat --style=plain --paging=always"
LONG_MSG_CMD = "nvim + -c 'startinsert' {file_path}"

# ── Open files (fallback when no mailcap match) ───────────────
DEFAULT_OPEN = "xdg-open {file_path}"

# ── Notifications ─────────────────────────────────────────────
# notify-send via dunst.
# Wrapping in sh -c because {title}/{subtitle}/{msg} may contain
# special characters that need to be passed safely.
NOTIFY_CMD = (
    "notify-send"
    " --app-name=tg"
    " --icon={icon_path}"
    " {title}"
    " {msg}"
)

# ── Clipboard ─────────────────────────────────────────────────
COPY_CMD = "xclip -selection clipboard"

# ── Voice recording ───────────────────────────────────────────
# PipeWire exposes PulseAudio interface — 'default' picks the
# default PipeWire source. opus/ogg required by Telegram spec.
# tg-record wraps ffmpeg to handle PipeWire cleanly and avoid
# issues with spaces in the {file_path} tg generates.
VOICE_RECORD_CMD = "tg-record {file_path}"

# ── Downloads ─────────────────────────────────────────────────
MAX_DOWNLOAD_SIZE = "50MB"
KEEP_MEDIA = 7

# ── FZF ───────────────────────────────────────────────────────
FZF = "fzf"

# ── Chat flags ────────────────────────────────────────────────
CHAT_FLAGS = {
    "online":  "●",
    "pinned":  "",
    "muted":   "",
    "unread":  "",
    "unseen":  "✓",
    "secret":  "",
    "seen":    "✓✓",
}

# ── Message flags ─────────────────────────────────────────────
MSG_FLAGS = {
    "selected":  "*",
    "forwarded": "",
    "new":       "N",
    "unseen":    "U",
    "edited":    "",
    "pending":   "…",
    "failed":    "✗",
    "seen":      "✓✓",
}

# ── User colors ───────────────────────────────────────────────
# Uses your terminal's base-16 color palette (set by themer/xrdb)
USERS_COLORS = tuple(range(2, 16))
