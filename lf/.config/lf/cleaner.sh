#!/usr/bin/env bash
# cleaner.sh — called by lf to clear the preview pane between files
# Required when using sixel image previews in st to prevent ghosting

# Send DEC screen erase to clear sixel artifacts left by chafa
# This is the proper way to clear sixels in a terminal
printf '\033[2J' 2>/dev/null || true
