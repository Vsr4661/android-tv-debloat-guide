#!/usr/bin/env bash
# Debloat a Xiaomi Mi TV (MiTV-MOOQ0, Android TV 10) and install the clean launcher + clock screensaver.
# Nothing is uninstalled: apps are disabled for user 0 and every change is logged with an undo.
#
# Usage:  scripts/install.sh <tv-ip> [your-name]
#   e.g.  scripts/install.sh 192.168.1.50 Alex
# Env:    FORCE=1     run on a model other than MiTV-MOOQ0 (review scripts/disabled-apps.txt first!)
#         NO_DNS=1    skip the ad-blocking Private DNS
set -uo pipefail
cd "$(dirname "$0")/.."

IP="${1:-}"; NAME="${2:-}"
[ -n "$IP" ] || { echo "usage: scripts/install.sh <tv-ip> [your-name]"; exit 2; }
command -v adb >/dev/null || { echo "adb not found. macOS: brew install --cask android-platform-tools"; exit 1; }
TV="$IP:5555"
A(){ adb -s "$TV" "$@"; }
LOG="install-$(date +%Y%m%d-%H%M%S).log"
log(){ echo "$*" | tee -a "$LOG"; }

# --- connect -------------------------------------------------------------------------------------
adb connect "$TV" >/dev/null
echo ">> Look at the TV: if 'Allow USB debugging?' appears, tick 'Always allow' and press Allow."
for _ in $(seq 1 40); do [ "$(A get-state 2>/dev/null)" = device ] && break; sleep 3; done
[ "$(A get-state 2>/dev/null)" = device ] || { echo "TV did not authorise this computer. Nothing changed."; exit 1; }

MODEL=$(A shell getprop ro.product.model | tr -d '\r')
SDK=$(A shell getprop ro.build.version.sdk | tr -d '\r')
log "TV: $MODEL (SDK $SDK)"
if [ "$MODEL" != "MiTV_MOOQ0" ] && [ "${FORCE:-0}" != 1 ]; then
  echo "This app list was made for MiTV_MOOQ0. Review scripts/disabled-apps.txt for your TV, then rerun with FORCE=1."
  exit 1
fi
[ "$SDK" -ge 26 ] || { echo "The launcher needs Android 8.0+ (SDK 26)."; exit 1; }

before=$(A shell "grep MemAvailable /proc/meminfo" | tr -d '\r')
log "Before: $before"

read -r -p "Disable $(grep -cv '^#' scripts/disabled-apps.txt) apps, install the launcher and change settings? [y/N] " ok
[ "$ok" = y ] || [ "$ok" = Y ] || { echo "Cancelled. Nothing changed."; exit 0; }

# --- 1. launcher first, so the TV is never left without a Home ----------------------------------
A install -r launcher/tvhome-custom.apk | tee -a "$LOG" | grep -q Success || { log "Launcher install failed. Nothing else changed."; exit 1; }
A shell am start -W -a android.intent.action.MAIN -c android.intent.category.HOME -n com.gathin.tvhome/.MainActivity >/dev/null
A shell pm grant com.gathin.tvhome android.permission.ACCESS_FINE_LOCATION 2>/dev/null
A shell cmd package compile -m speed -f com.gathin.tvhome >/dev/null

# --- 2. launcher look (theme file read by the launcher at start) --------------------------------
D=/sdcard/Android/data/com.gathin.tvhome/files
A shell mkdir -p $D
TMP=$(mktemp)
if [ -n "$NAME" ]; then sed "s/\"YOUR_NAME\"/\"$NAME\"/" launcher/config.json > "$TMP"
else sed 's/"YOUR_NAME"/""/' launcher/config.json > "$TMP"; fi
A push "$TMP" $D/config.json >/dev/null && rm -f "$TMP"
log "THEME pushed (greeting name: ${NAME:-none})"

# --- 3. disable bloat; the stock Google home last, once ours is Home ----------------------------
A shell cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity >/dev/null
while read -r p; do
  case "$p" in ''|\#*|com.google.android.tvlauncher) continue ;; esac
  log "DISABLE $p -> $(A shell pm disable-user --user 0 "$p" 2>&1 | tr -d '\r')"
done < scripts/disabled-apps.txt
log "DISABLE com.google.android.tvlauncher -> $(A shell pm disable-user --user 0 com.google.android.tvlauncher | tr -d '\r')"
A shell cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity >/dev/null

# --- 4. settings ---------------------------------------------------------------------------------
A shell settings put global window_animation_scale 0
A shell settings put global transition_animation_scale 0
A shell settings put global animator_duration_scale 0.5
A shell settings put secure screensaver_components com.gathin.tvhome/.ClockDream
log "SETTINGS animations 0/0/0.5, screensaver = centred clock"
if [ "${NO_DNS:-0}" != 1 ]; then
  A shell settings put global private_dns_specifier dns.adguard-dns.com
  A shell settings put global private_dns_mode hostname
  log "SETTINGS Private DNS = dns.adguard-dns.com"
fi

# --- 5. Home at every power-on (accessibility helper, key filtering off) -------------------------
A shell pm grant com.gathin.tvhome android.permission.WRITE_SECURE_SETTINGS
A shell settings put secure enabled_accessibility_services com.gathin.tvhome/.HomeKeyService
A shell settings put secure accessibility_enabled 1
log "HELPER HomeKeyService on"

# --- done: let Android write package state, then reboot ------------------------------------------
A shell sync; sleep 15
log "Rebooting the TV…"
A reboot
sleep 25
for _ in $(seq 1 40); do adb connect "$TV" >/dev/null 2>&1; [ "$(A shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ] && break; sleep 4; done
sleep 60
after=$(A shell "grep MemAvailable /proc/meminfo" | tr -d '\r')
log "After:  $after"
log "Disabled now: $(A shell pm list packages -d | wc -l | tr -d ' ') apps"
log "Home:   $(A shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME | tail -1 | tr -d '\r')"
echo
echo "Done. Log: $LOG   Undo everything: scripts/undo.sh $IP"
echo "When finished, turn OFF debugging on the TV: Settings > Device Preferences > Developer options."
