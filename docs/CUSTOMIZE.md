# Customise the launcher

The launcher reads `launcher/config.json` from the TV at start. Edit it, push it, restart the launcher — no reinstall:

```bash
adb -s TV push launcher/config.json /sdcard/Android/data/com.gathin.tvhome/files/config.json
adb -s TV shell am force-stop com.gathin.tvhome && adb -s TV shell input keyevent KEYCODE_HOME
adb -s TV shell settings put secure enabled_accessibility_services com.gathin.tvhome/.HomeKeyService  # a force-stop turns the helper off
```

## The settings used here

| Key | Value | Effect |
|---|---|---|
| `greeting_name` | `"YOUR_NAME"` | "Good evening, Name" above the clock (`show_greeting: false` hides it) |
| `columns`, `single_row`, `rows_below_dock` | `4`, `true`, `0` | Only the 4 dock apps on screen; press → for the rest |
| `cinematic_home`, `dock_title` | `true` | Large app name and position dots above the row |
| `cinematic_art`, `cinematic_scrim` | `0` | No artwork behind the name, so the colour glow shows |
| `ambient_glow` | `true` | Background glow in the selected app's colour |
| `background_color` | `#0E0F12` | Near-black (onyx theme) |
| `glass_style`, `focus_overshoot` | `rim`, `false` | Thin outline on the selected tile, no bounce |
| `icon_only_buttons` | `false` | Labelled Inputs / Wi-Fi / Settings buttons |
| `app_library`, `library_button` | `true` | App library button in the top bar |
| `hidden_apps` | Live TV, gallery, Mi screensaver, Screen share, Media player | Tiles hidden, apps still installed |
| `clock_wallpaper`, `clock_wallpaper_dim` | `true`, `15` | Screensaver can show `screensaver.jpg` (see below) |
| `power_on_home_always`, `key_filter` | `true`, `false` | Home at every power-on; held volume still repeats |
| `restore_key_services` | `true` | The launcher re-enables its helper after a force-stop |

Every other key is documented in the upstream
[themes README](https://github.com/Gathin23/cleanyourtv/blob/main/themes/README.md) — about 30 ready-made themes too.

## Dock apps

Built into the APK (YouTube, Netflix, Prime Video, JioHotstar). To change them without rebuilding, add to `config.json`:

```json
"dock_apps": ["com.google.android.youtube.tv", "com.netflix.ninja", "com.amazon.amazonvideo.livingroom", "in.startv.hotstar"]
```

Package names: `adb -s TV shell pm list packages -3`.

## A photo behind the screensaver clock

```bash
adb -s TV push photo.jpg /sdcard/Android/data/com.gathin.tvhome/files/screensaver.jpg   # 1920x1080 JPEG
```

Delete it to go back to the colour glow. It never appears on Home.

## Changes in this build (vs upstream cleanyourtv `launcher/`)

`launcher/changes.patch` on top of commit `launcher/BASE_COMMIT`:

| File | Change |
|---|---|
| `res/values/config.xml` | Dock order YouTube, Netflix, Prime Video, JioHotstar; remote Input key (130) opens Inputs |
| `res/layout/activity_main.xml` | Greeting in Outfit Light 26sp, normal case ("Elegant") |
| `res/layout/dream_clock.xml` | Screensaver clock shows `h:mm:ss` with fixed-width digits, centred text |
| `ClockScene.java` | Clock always centred (LCD, no burn-in drift); own `screensaver.jpg`; glow cycles the dock app colours |
| `AppAdapter.java` | Fixed glow colours: YouTube `#FF2A1A`, Netflix `#7A0A2E`, JioHotstar `#F2087F` |

## Rebuild from source

Needs JDK 17 and the Android SDK.

```bash
git clone https://github.com/Gathin23/cleanyourtv && cd cleanyourtv
git checkout "$(cat ../android-tv-debloat-guide/launcher/BASE_COMMIT)"
git apply ../android-tv-debloat-guide/launcher/changes.patch
cd launcher && ./gradlew assembleRelease
adb -s TV install -r app/build/outputs/apk/release/app-release.apk
```

Change colours in `AppAdapter.ambientColorAt` and `ClockScene.PALETTE`. The bundled APK is signed with a debug key, so
installing your own build over it may need `adb uninstall com.gathin.tvhome` first (re-push `config.json` afterwards).
