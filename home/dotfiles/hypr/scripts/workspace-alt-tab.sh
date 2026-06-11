#!/usr/bin/env bash

set -euo pipefail

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}/hypr-workspace-alt-tab"
STATE_FILE="$STATE_DIR/state"
LOCK_FILE="$STATE_DIR/lock"
SEQUENCE_TIMEOUT_MS="${SEQUENCE_TIMEOUT_MS:-900}"

mkdir -p "$STATE_DIR"

now_ms() {
    date +%s%3N
}

active_workspace() {
    hyprctl activeworkspace -j 2>/dev/null |
        sed -n 's/.*"id"[[:space:]]*:[[:space:]]*\([-0-9][0-9]*\).*/\1/p' |
        head -n 1
}

connected_outputs() {
    for status_file in /sys/class/drm/card*-*/status; do
        [ -e "$status_file" ] || continue

        IFS= read -r status < "$status_file" || continue
        [ "$status" = "connected" ] || continue

        output="${status_file%/status}"
        output="${output##*/}"
        output="${output#card*-}"
        printf '%s\n' "$output"
    done
}

nonempty_workspaces() {
    hyprctl workspaces -j 2>/dev/null |
        tr '{' '\n' |
        while IFS= read -r object; do
            id="$(printf '%s\n' "$object" |
                sed -n 's/.*"id"[[:space:]]*:[[:space:]]*\([-0-9][0-9]*\).*/\1/p')"
            windows="$(printf '%s\n' "$object" |
                sed -n 's/.*"windows"[[:space:]]*:[[:space:]]*\([0-9][0-9]*\).*/\1/p')"

            [ -n "$id" ] || continue
            [ "${windows:-0}" -gt 0 ] || continue
            [ "$id" -gt 0 ] || continue

            printf '%s\n' "$id"
        done
}

allowed_workspaces() {
    {
        seq 1 5

        if connected_outputs | grep -qx 'HDMI-A-1'; then
            seq 6 10
        else
            nonempty_workspaces | awk '$1 >= 6 && $1 <= 10 { print $1 }'
        fi
    } | sort -n -u
}

next_workspace_after() {
    current="$1"
    workspaces="$(allowed_workspaces)"

    next="$(
        printf '%s\n' "$workspaces" |
            awk -v current="$current" '$1 > current { print $1; exit }'
    )"

    if [ -n "$next" ]; then
        printf '%s\n' "$next"
        return 0
    fi

    printf '%s\n' "$workspaces" | head -n 1
}

exec 9>"$LOCK_FILE"
flock 9

now="$(now_ms)"
last_ms=0
last_target=""

if [ -f "$STATE_FILE" ]; then
    # shellcheck disable=SC1090
    . "$STATE_FILE"
fi

if [ "$((now - ${last_ms:-0}))" -gt "$SEQUENCE_TIMEOUT_MS" ]; then
    hyprctl dispatch workspace previous >/dev/null 2>&1 || true
    sleep 0.05
    target="$(active_workspace)"
else
    base="${last_target:-$(active_workspace)}"
    target="$(next_workspace_after "$base")"
    hyprctl dispatch workspace "$target" >/dev/null 2>&1 || true
fi

{
    printf 'last_ms=%s\n' "$now"
    printf 'last_target=%s\n' "${target:-}"
} > "$STATE_FILE"
