# Manual setup guide

Everything `scripts/install.sh` does, step by step, so you can do it by hand or adapt it to another TV.
Replace `TV` with your TV's address, e.g. `192.168.1.50:5555`.

## 1. Prepare the TV

1. Settings → Device Preferences → About → select **Build** 7 times ("You are now a developer").
2. Back → **Developer options** → **USB debugging: On** (and **Network debugging** if listed).
3. Note the IP address: Settings → Network & Internet → your Wi-Fi.

## 2. Install adb on your computer

| OS | Command |
|---|---|
| macOS | `brew install --cask android-platform-tools` |
| Windows | `winget install Google.PlatformTools` |
| Linux (Debian/Ubuntu) | `sudo apt install adb` |

## 3. Find and connect to the TV

```bash
adb mdns services                          # TVs advertising adb over mDNS
dns-sd -B _androidtvremote2._tcp local.    # macOS: Android TVs on the network (Ctrl+C to stop)
adb connect TV
```

Press **Allow** on the TV (tick *Always allow from this computer*). `adb devices` should show `device`, not `unauthorized`.

## 4. Audit first (changes nothing)

```bash
adb -s TV shell "grep MemAvailable /proc/meminfo"   # baseline free memory
adb -s TV shell pm list packages -s                 # system apps
adb -s TV shell pm list packages -3                 # apps you installed
adb -s TV shell cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME
```

Compare the list with [APPS.md](APPS.md). Unsure what a vendor package does? `adb -s TV shell dumpsys package <name>`
shows its activities and services without starting it. **Never open factory/test packages** to find out.

## 5. Install the launcher before touching the stock one

```bash
adb -s TV install -r launcher/tvhome-custom.apk
adb -s TV shell am start -W -a android.intent.action.MAIN -c android.intent.category.HOME -n com.gathin.tvhome/.MainActivity
adb -s TV shell cmd package compile -m speed -f com.gathin.tvhome
adb -s TV shell pm grant com.gathin.tvhome android.permission.ACCESS_FINE_LOCATION   # shows the Wi-Fi name
```

Push its look (edit `greeting_name` first):

```bash
adb -s TV shell mkdir -p /sdcard/Android/data/com.gathin.tvhome/files
adb -s TV push launcher/config.json /sdcard/Android/data/com.gathin.tvhome/files/config.json
```

## 6. Disable the bloat

One package per command (chained commands can stop silently after the first):

```bash
grep -v '^#' scripts/disabled-apps.txt | grep -v tvlauncher | while read p; do
  adb -s TV shell pm disable-user --user 0 "$p"
done
```

Then hand Home over. The stock Google home has a higher priority than any other launcher, so `set-home-activity`
alone is ignored — disable the stock home **after** the new launcher is installed and set:

```bash
adb -s TV shell cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity
adb -s TV shell pm disable-user --user 0 com.google.android.tvlauncher
adb -s TV shell input keyevent KEYCODE_HOME
adb -s TV shell "dumpsys activity activities | grep -m1 mResumedActivity"   # must say com.gathin.tvhome
```

## 7. Settings

```bash
# snappier menus
adb -s TV shell settings put global window_animation_scale 0
adb -s TV shell settings put global transition_animation_scale 0
adb -s TV shell settings put global animator_duration_scale 0.5
# clock screensaver
adb -s TV shell settings put secure screensaver_components com.gathin.tvhome/.ClockDream
# ad-blocking DNS (skip if your router already runs Pi-hole / AdGuard Home)
adb -s TV shell settings put global private_dns_specifier dns.adguard-dns.com
adb -s TV shell settings put global private_dns_mode hostname
# Home at every power-on (needs "power_on_home_always": true in config.json)
adb -s TV shell pm grant com.gathin.tvhome android.permission.WRITE_SECURE_SETTINGS
adb -s TV shell settings put secure enabled_accessibility_services com.gathin.tvhome/.HomeKeyService
adb -s TV shell settings put secure accessibility_enabled 1
```

## 8. Reboot and compare

```bash
adb -s TV shell sync && sleep 15     # Android writes package state ~10 s after a change
adb -s TV reboot
# after it boots:
adb connect TV
adb -s TV shell "grep MemAvailable /proc/meminfo"
adb -s TV shell pm list packages -d | wc -l     # should be 33
```

## 9. Lock it down

Developer options → turn **USB debugging** (and Network debugging) **off**.

## Undo

`scripts/undo.sh <tv-ip>` — or by hand: `pm enable --user 0 <package>` for each line of `scripts/disabled-apps.txt`,
then `cmd package set-home-activity --user 0 com.google.android.tvlauncher/.MainActivity`.
