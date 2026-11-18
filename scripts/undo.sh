#!/usr/bin/env bash
# Puts the TV back the way it was: re-enables every app from disabled-apps.txt, restores the Google home,
# animations, screensaver, DNS and accessibility settings. The custom launcher stays installed unless
# you pass --remove-launcher.
#
# Usage:  scripts/undo.sh <tv-ip> [--remove-launcher]
set -uo pipefail
cd "$(dirname "$0")/.."
IP="${1:-}"; [ -n "$IP" ] || { echo "usage: scripts/undo.sh <tv-ip> [--remove-launcher]"; exit 2; }
TV="$IP:5555"; A(){ adb -s "$TV" "$@"; }

adb connect "$TV" >/dev/null
for _ in $(seq 1 40); do [ "$(A get-state 2>/dev/null)" = device ] && break; sleep 3; done
[ "$(A get-state 2>/dev/null)" = device ] || { echo "TV not authorised (press Allow on the TV)."; exit 1; }

while read -r p; do
  case "$p" in ''|\#*) continue ;; esac
  A shell pm enable --user 0 "$p" >/dev/null && echo "enabled $p"
done < scripts/disabled-apps.txt

A shell settings put global window_animation_scale 1.0
A shell settings put global transition_animation_scale 1.0
A shell settings delete global animator_duration_scale
A shell settings put secure screensaver_components com.mitv.dream/com.mitv.dream.MiDream
A shell settings delete global private_dns_mode
A shell settings delete global private_dns_specifier
A shell settings delete secure enabled_accessibility_services
A shell settings put secure accessibility_enabled 0
A shell pm revoke com.gathin.tvhome android.permission.WRITE_SECURE_SETTINGS 2>/dev/null
A shell cmd package set-home-activity --user 0 com.google.android.tvlauncher/.MainActivity

[ "${2:-}" = --remove-launcher ] && A uninstall com.gathin.tvhome
A shell sync; sleep 15; A reboot
echo "Undo complete; the TV is rebooting into the stock Google home screen."
