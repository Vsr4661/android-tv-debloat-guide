# Apps: what's disabled, what's kept, and why

Model: Xiaomi Mi TV **MiTV-MOOQ0** (Android TV 10). 127 packages were installed; 33 are disabled.
Everything is disabled for user 0, not uninstalled — `pm enable --user 0 <package>` brings any one back.

## Disabled (33)

| Package | What it is |
|---|---|
| **Xiaomi telemetry** | |
| com.miui.tv.analytics | Xiaomi usage analytics |
| com.xiaomi.statistic | Xiaomi statistics uploader |
| **Ads, promos, recommendations** | |
| com.xm.webcontent | Xiaomi promo web content |
| com.mitv.tvhome.atv | PatchWall home layer (content and ads) |
| com.mitv.tvhome.michannel | Xiaomi recommendation channels |
| com.mitv.tvhome.mitvplus | Mi TV+ free ad-supported channels |
| com.xiaomi.floatingframe | Floating promo overlay / pop-ups |
| android.autoinstalls.config.xiaomi.amelie | Auto-installs partner apps |
| com.google.android.tvrecommendations | Google "suggested for you" rows |
| com.google.android.leanbacklauncher | Old Android TV home (unused) |
| com.google.android.leanbacklauncher.recommendations | Its recommendation service |
| com.google.android.tvlauncher | Stock Google home — replaced by the new launcher |
| **Background services not needed** | |
| com.xiaomi.mitv.tvmanager | "TV Manager" cleaner/booster (ran in the background) |
| com.xiaomi.amazon.alexa | Alexa bridge |
| com.google.android.feedback | Crash feedback upload |
| com.google.android.tv.bugreportsender | Bug report upload |
| com.google.android.syncadapters.calendar | Google Calendar sync |
| com.google.android.syncadapters.contacts | Google Contacts sync |
| com.android.printspooler | Printing |
| **Factory, demo and preloaded apps** | |
| com.duokan.factorytest | Factory test (also claims Home — disable before switching launcher) |
| mediatek.factorymenu.ui | Factory service menu |
| fusion.android.tv.demo | Store demo mode |
| com.xiaomi.mitv.handbook | On-screen manual |
| com.xiaomo.tv.milegal | Legal/terms screens |
| com.mstar.android.tv.disclaimercustomization | Boot disclaimer screen |
| com.mediatek.wwtv.webview | Vendor web view shell |
| com.mitv.tvlock | TV lock / parental password (keep it if you use it) |
| com.mitv.gallery | Mi Gallery |
| com.xiaomi.mimusic2 | Mi Music |
| com.android.deskclock | Clock/alarm app |
| com.google.android.play.games | Play Games |
| com.google.android.videos | Google TV / Play Movies store |
| com.google.android.marvin.talkback | TalkBack screen reader (keep it if you need accessibility) |

## Kept on purpose

| Package | Why |
|---|---|
| com.mediatek.tvinput, com.mediatek.tvinputservice.arbitratorservice | HDMI 1-3, AV, tuner |
| com.mediatek.wwtv.tvcenter | Live TV — also the HDMI/AV window, cannot be disabled (hidden from Home instead) |
| com.mediatek.hotkey.dispatcher | Remote hotkeys, including Input/Source |
| com.xiaomi.android.tvsetup.partnercustomizer | Bluetooth remote pairing |
| com.mediatek.tv.agent, mitv.service, com.xiaomi.mitv.res | Core TV services |
| com.mstar.netflixobserver | Netflix button on the remote |
| com.google.android.inputmethod.latin | Keyboard |
| com.android.vending, com.google.android.gms, com.google.android.gsf | Play Store and Play Services |
| com.google.android.webview | Web rendering for apps |
| com.google.android.tv.remote.service | Phone-as-remote |
| com.google.android.katniss, com.google.android.tv.assistant | Voice search (optional — ~100 MB if you don't use it) |
| com.google.android.apps.mediashell | Chromecast (optional) |
| com.mitv.milinkservice, com.xiaomi.mitv.smartshare, com.xiaomi.wfdsinkhelperservice | Mi Cast / Miracast (optional) |
| com.mitv.videoplayer, com.xiaomi.mitv.mediaexplorer | USB media player (optional) |
| com.xiaomi.mitv.updateservice | Firmware updates (security fixes) |
| com.google.android.backdrop, com.mitv.dream, com.android.dreams.basic | Screensavers (not running once the clock is set) |
| All `android`, `com.android.*` system, providers, networking, Bluetooth, setup wizard packages | Android needs them |

## Never disable

Disabling these can stop the TV from booting: `android`, `com.android.systemui`, `com.android.shell`,
`com.android.providers.*`, `com.android.tv.settings`, permission controller, package installer, ext services/shared,
module metadata, and the TV middleware (`com.mediatek.tv.service`, `com.mediatek.tv.agent`).
