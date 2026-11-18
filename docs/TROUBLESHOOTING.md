# Troubleshooting

Things that actually came up on a MiTV-MOOQ0, and the fix.

| Problem | Cause | Fix |
|---|---|---|
| `adb devices` shows **unauthorized** | The TV forgot this computer or the prompt wasn't accepted | `adb disconnect TV && adb connect TV`, press **Allow** on the TV and tick *Always allow* |
| Port 5555 not found in the scan | Debugging off, or the TV only offers *Wireless debugging* | Turn USB debugging on; for Wireless debugging use `adb pair` with the code shown on the TV |
| Home button still opens the Google home | Its HOME priority (2) beats every other launcher; `set-home-activity` prints Success but is ignored | Disable `com.google.android.tvlauncher` **after** the new launcher is installed and set |
| Home opens the factory test app | `com.duokan.factorytest` also claims Home | It's in the disable list; disable it before handing Home over |
| TV went to sleep and adb shows **offline** | Standby drops Wi-Fi | Press Power on the remote; adb reconnects in ~20 s |
| Power-on doesn't land on Home | The accessibility helper got switched off (a force-stop or reinstall does this) | Re-run the 3 helper commands in [SETUP.md](SETUP.md#7-settings); `restore_key_services: true` makes the launcher do it itself |
| Holding volume no longer repeats | A key-filtering helper is on | Keep `"key_filter": false` in `config.json` |
| The **Mi / PatchWall** button does nothing | PatchWall is disabled | Remapping it needs `key_filter: true`, which costs volume repeat on this model — your choice |
| Screenshots of Live TV / Netflix are black | DRM-protected surfaces | Normal; check `dumpsys activity activities` instead |
| An app stopped loading after the DNS change | AdGuard blocked a domain it needs | `adb -s TV shell settings put global private_dns_mode opportunistic` |
| The screensaver clock is not centred / has no seconds | Upstream build | Use `launcher/tvhome-custom.apk` from this repo |
| Something else broke | — | `scripts/undo.sh <tv-ip>` restores everything; a factory reset always works too |
