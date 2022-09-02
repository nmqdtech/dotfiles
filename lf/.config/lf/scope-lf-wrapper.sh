#!/bin/sh
# scope-lf-wrapper.sh
# Thin shim kept for LESSOPEN compatibility.
# lf itself calls scope.sh directly (set previewer in lfrc).
# This shim is used by: LESSOPEN='|~/.config/lf/scope-lf-wrapper.sh %s' less -R

exec "$HOME/.config/lf/scope.sh" "$1" "${COLUMNS:-80}" "${LINES:-40}" 0 0
