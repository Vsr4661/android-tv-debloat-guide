# The AI prompt

Paste this into **Claude Code** (or another AI coding agent that can run shell commands) on a computer on the same Wi-Fi
as your TV. It works on most Android TV / Google TV sets (Xiaomi, TCL, Hisense, Sony, OnePlus, Realme…), not on Samsung
Tizen, LG webOS or Roku.

Before you start, on the TV: Settings → Device Preferences → About → press OK on **Build** 7 times → back →
**Developer options** → turn on **USB debugging** (and Network debugging if it is listed). Keep the TV on.

---

```text
I want to speed up my Android TV and clean up its home screen. My computer and TV are on the same
Wi-Fi, and USB debugging is already on. Work on the real device, step by step, and ask me before
anything that depends on my preferences. Use https://github.com/Vsr4661/android-tv-debloat-guide
as the reference for what worked on a Xiaomi Mi TV.

1. Setup: check if adb is installed. If not, install it (Homebrew on Mac, winget on Windows, apt on Linux).

2. Find my TV: use mDNS (dns-sd / adb mdns services) and a scan of my local network for port 5555.
   If you find more than one TV, ask me which one. Run adb connect and tell me to press "Allow" on
   the TV when the prompt appears.

3. Audit (change nothing yet): note free memory (MemAvailable from /proc/meminfo) as a baseline.
   List every installed package and sort them into:
   - REQUIRED: system, launcher, Play Store, keyboard, TV inputs/HDMI/tuner, remote and Bluetooth
     pairing, anything the TV needs to boot or work
   - MINE: apps I actually use (ask me if unsure)
   - SAFE TO DISABLE: preinstalled bloatware, telemetry, ad/recommendation services, unused apps
   Show this as a table with a plain-English description of each app. Check unclear vendor
   packages with `dumpsys package` and never launch factory/test menus to find out what they do.

4. Ask before changing: let me approve or remove items from SAFE TO DISABLE, and ask whether to
   turn off voice search, Chromecast, screen mirroring, the screensaver and the USB player, and
   whether to set animation scales for snappier menus.

5. Apply: disable apps only with `pm disable-user --user 0`, one package per command, in small
   batches. Never uninstall anything. Save every change to a log file on my computer, with one
   command that undoes all of them.

6. Launcher: install the open-source cleanyourtv launcher (https://github.com/Gathin23/cleanyourtv),
   build it from source if needed, set it as Home with `cmd package set-home-activity`, and only
   then disable the stock launcher. Confirm with `dumpsys activity activities` that Home really
   opens it — on Android TV the stock launcher has a higher priority and `set-home-activity` alone
   is ignored. Ask me which apps go in the dock and in what order.

7. Look and feel (show me screenshots from the TV with `screencap` for each option and let me pick):
   a greeting with my name, a big app name over a glow in each app's colour, and a screensaver with
   a centred digital clock that shows running seconds.

8. Extras (ask first): Home at every power-on, ad-blocking Private DNS (dns.adguard-dns.com),
   hiding leftover system tiles.

9. Results: reboot the TV, check free memory again and show me before vs after. Then remind me to
   turn off debugging.
```

---

### Tips from doing this for real

- Expect 3–4 questions: which apps you use, the dock order, voice search / Chromecast / mirroring, and the look.
- The TV may ask "Allow USB debugging?" again mid-session — tick **Always allow**.
- Putting the TV to sleep drops the network connection; the agent cannot wake it, you have to press Power.
- See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for the other things that came up.
