# Jio Set-Top Box (JHSC200 v3) — Post-Unlock Retro Gaming & Media Setup

A complete post-unlock transformation suite for the **Jio Set-Top Box (SDMC DV8545 / JHSC200 v3)**, turning a locked telecom device into a private, high-performance Android TV retro gaming console and ad-free 4K media center.

---

## 🎮 Hardware Profile

| Specification | Details |
|---|---|
| **SoC** | Amlogic S905X2 (12nm FinFET) |
| **CPU** | Quad-core ARM Cortex-A53 @ 1.80 GHz |
| **GPU** | ARM Mali-G31 MP2 (OpenGL ES 3.2, Vulkan 1.1) |
| **RAM** | 2.0 GB DDR4 |
| **Storage** | 25 GB eMMC Flash (~22 GB available post-debloat) |
| **OS** | Android 11 (32-bit `armeabi-v7a` userland on 64-bit Linux kernel 4.9.269) |
| **Remote** | Official Jio Bluetooth Remote (BLE) & USB Gamepad support |

---

## 📁 Repository Structure

```text
jhsc200-retro-media-setup/
├── apks/               # Curated 32-bit Android TV applications
│   ├── LeanKeyboard_v6.1.31.apk          # Remote-friendly TV on-screen keyboard
│   ├── lemuroid-app-free-release.apk     # Multi-system retro emulator (PS1, GBA, NES)
│   ├── monet-launcher.apk                # Clean, ad-free Android TV launcher
│   ├── RetroArch_ra32.apk                # 32-bit libretro frontend
│   ├── shevery-release.apk               # Shizuku-compatible privileged API manager
│   ├── SmartTube_stable_32.71.apk        # Ad-free 4K YouTube client (SponsorBlock)
│   ├── tvbro-3.0.5-geckoIncluded.apk     # Full Gecko-engine TV web browser
│   └── tv_file_picker.apk                # DocumentsUI replacement for Android TV
│
├── ROMs/               # Game library & BIOS storage
│   ├── GBA/            # Game Boy Advance titles (Pokémon FireRed, Emerald)
│   ├── NES/            # 8-bit arcade multicarts
│   ├── PS1/            # PS1 disc images (.chd) & official scph5501.bin BIOS
│   └── cores/          # Libretro emulator cores (mGBA, PCSX-ReARMed, Snes9x, FCEUmm)
│
├── wallpapers/         # 104 curated 4K gaming wallpapers for Monet Launcher
│
├── scripts/            # Automated deployment & optimization scripts
│   ├── debloat_and_protect.ps1   # Disables 18 Jio telemetry & OTA services
│   ├── sync_system_clock.ps1     # Real-time epoch clock sync (bypasses root lock)
│   ├── setup_default_keyboard.ps1# Configures LeanKeyboard as default IME
│   ├── push_wallpapers.ps1       # Pushes 4K wallpapers & triggers media scan
│   └── ...                       # Input remapping & diagnostic helpers
│
└── screenshots/        # Verified on-device capture logs
```

---

## ⚡ Setup & Deployment Guide

### Prerequisites
1. Complete the Stage 1 network unlock using `sideload-jiostb`.
2. Connect your STB to your PC via Windows Mobile Hotspot or LAN.
3. Ensure ADB is authorized on the box (`<STB_IP>:5555`).

### Step 1: System Debloat & Protection
Run the debloat script to permanently disable all 18 Jio telemetry services, OTA auto-updaters, and background task killers:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\debloat_and_protect.ps1 -AdbPath "..\sideload-jiostb\adb.exe"
```
* **Protects against:** Remote TR-069 lockouts, forced Reliance firmware updates, and background memory managers force-stopping emulators (`appoptimizer`).
* **Preserves:** Hardware Bluetooth remote pairing services (`com.iwedia.bluetoothconnectionservice`, `com.jio.remote.btserver`) and gamepad profiles.

### Step 2: System Clock Synchronization
If the STB loses battery power or reboots without internet, its clock resets to an old date (causing SSL certificates in SmartTube and browsers to fail). Sync it instantly:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync_system_clock.ps1 -AdbPath "..\sideload-jiostb\adb.exe"
```

### Step 3: Install Applications
Install the core media and gaming suite from `apks/`:
```powershell
..\sideload-jiostb\adb.exe install -r apks\SmartTube_stable_32.71_armeabi-v7a.apk
..\sideload-jiostb\adb.exe install -r apks\tvbro-3.0.5-generic-geckoIncluded-armeabi-v7a.apk
..\sideload-jiostb\adb.exe install -r apks\LeanKeyboard_v6.1.31_playstore_r.apk
..\sideload-jiostb\adb.exe install -r apks\tv_file_picker.apk
..\sideload-jiostb\adb.exe install -r apks\lemuroid-app-free-dynamic-release.apk
```

### Step 4: Configure LeanKeyboard as Default Input Method
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\setup_default_keyboard.ps1 -AdbPath "..\sideload-jiostb\adb.exe"
```

### Step 5: Transfer Wallpapers & ROMs
Push the 4K gaming wallpapers to `/sdcard/Pictures/4k game wallpapers/`:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\push_wallpapers.ps1 -AdbPath "..\sideload-jiostb\adb.exe"
```
Push the PS1 BIOS and ROMs:
```powershell
..\sideload-jiostb\adb.exe shell "mkdir -p /sdcard/ROMs/PSX"
..\sideload-jiostb\adb.exe push "ROMs\PS1\scph5501.bin" /sdcard/ROMs/PSX/
..\sideload-jiostb\adb.exe push "ROMs\PS1\*.chd" /sdcard/ROMs/PSX/
```

### Step 6: Revoke Intrusive Background Overlays ("Display Over Other Apps")
Several persistent Jio system services hold the `SYSTEM_ALERT_WINDOW` permission by default (`FTI`, `iWedia MW`, `Jio BLE Automatic Pair`, `Jio Update Rcu Ota`, `JioRemoteDiagnose`, `JioSTBMRServer`). If not revoked, these background services can draw invisible overlay layers or intercept remote inputs over Monet Launcher.

Revoke overlay access across all background packages in one command:
```powershell
$services = @(
    "com.jio.media.stb.remotediagnose",
    "com.jio.media.stbmrserver",
    "com.iwedia.bleautomaticpairservicelw",
    "com.iwedia.jio.rcuota",
    "com.jio.media.jioaccount",
    "com.jio.media.stb.adservice"
)
foreach ($pkg in $services) {
    ..\sideload-jiostb\adb.exe shell "cmd appops set $pkg SYSTEM_ALERT_WINDOW ignore 2>/dev/null"
}
```

---

## 🕹️ Emulation Performance & Benchmark Matrix

The **Amlogic S905X2** SoC (Quad-Core Cortex-A53 @ 1.80 GHz + Mali-G31 MP2) provides excellent 8-bit to 32-bit retro performance under Android 11:

| Platform | Core / Standalone App | Resolution | Frame Rate | Tested & Verified Titles |
|---|---|---|---|---|
| **Sony PlayStation 1 (PSX)** | PCSX-ReARMed / Lemuroid | Native (240p/480i) | **Locked 60 FPS** | *Tekken 3*, *Resident Evil 1/2/3*, *Crash Bandicoot 1-3*, *Mortal Kombat Trilogy*, *Silent Hill*, *Street Fighter Alpha 3* |
| **Game Boy Advance (GBA)** | mGBA / gpSP | 1x / 2x Scale | **Locked 60 FPS** | *Pokémon FireRed*, *Pokémon Emerald*, *Castlevania: Aria of Sorrow*, *The Legend of Zelda: The Minish Cap* |
| **SNES / NES / Genesis** | Snes9x / FCEUmm / Genesis Plus GX | Native | **Locked 60 FPS** | *Super Mario World*, *Chrono Trigger*, *Contra*, *Sonic the Hedgehog 2*, *Streets of Rage 2* |
| **Nintendo 64 (N64)** | Mupen64Plus-Next | Native (320x240) | **45–60 FPS** | *Super Mario 64*, *The Legend of Zelda: Ocarina of Time*, *Mario Kart 64* |
| **Sony PSP** | PPSSPP (32-bit ARM) | 1x Native | **25–30 FPS (Light 2D/3D)** | *Patapon 1/2*, *Lumines*, *Persona 3 Portable* (Heavy 3D like *God of War: Ghost of Sparta* runs ~10–15 FPS; not recommended) |
| **PlayStation 2 (PS2) / GameCube** | AetherSX2 / Dolphin | N/A | **Unsupported** | Hardware limitation (requires 64-bit `arm64-v8a` userland and high single-core IPC) |

---

## 🎮 Gamepad & Controller Setup

The JHSC200 v3 supports both USB and Bluetooth game controllers without needing any root remapping:

* **USB Gamepads (Zero Configuration):**
  * Plug any standard USB controller into either of the two side USB ports (USB 2.0 / 3.0).
  * Compatible with Xbox 360 / Xbox One wired controllers, DualShock 4 / DualSense (wired), and 2.4 GHz wireless controllers using a USB dongle (e.g., Logitech F710, 8BitDo Ultimate 2.4G).
* **Bluetooth Gamepads:**
  * Open the Android TV Bluetooth Pairing menu directly via ADB:
    ```powershell
    ..\sideload-jiostb\adb.exe shell "am start -a android.settings.BLUETOOTH_SETTINGS"
    ```
  * Put your controller into pairing mode (e.g., hold `Share + PS` on PlayStation controllers or hold the pair button on Xbox controllers) and select it on the TV screen.
* **Input Latency Tip:** Keep the official Jio Bluetooth remote paired for power/volume controls, and use a 2.4 GHz USB gamepad or wired controller for zero input lag in fighting and platforming games.

---

## 🧰 Quick Troubleshooting Cheat Sheet

| Symptom | Root Cause | Solution |
|---|---|---|
| **SmartTube throws `SSLHandshakeException` or `Chain validation failed`** | STB system clock reset back to an old date after losing power or rebooting. | Run `powershell .\scripts\sync_system_clock.ps1` to sync the clock in real-time or configure NTP via `adb shell settings put global ntp_server time.google.com`. |
| **On-screen keyboard doesn't appear when clicking search bars** | Stock Jio IME is disabled or hidden. | Run `powershell .\scripts\setup_default_keyboard.ps1` to enable and set LeanKeyboard as the active IME. |
| **Monet Launcher doesn't show pushed wallpapers** | Android media scanner hasn't indexed the `/sdcard/Pictures/` folder. | Run `adb shell "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d file:///sdcard/Pictures/4k\ game\ wallpapers/"`. |
| **Audio crackling or stuttering in emulators** | Incompatible audio latency buffer in RetroArch / Lemuroid. | Go into emulator Settings → Audio → Set Audio Driver to `OpenSL ES` or `AudioTrack` and set Audio Latency to `64ms`. |
| **ADB connection drops over Wi-Fi** | Android power saving or router IP lease renewal. | Use a fixed DHCP reservation on your Wi-Fi router for the STB and reconnect with `adb connect <STB_IP>:5555`. |

---

## 🛡️ License & Disclaimers
* All third-party APKs, ROMs, and BIOS files are property of their respective copyright holders.
* Scripts and configuration guides are released under the MIT License for educational and local device customization purposes.

