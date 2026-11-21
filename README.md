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
3. Ensure ADB is authorized on the box (`192.168.137.204:5555` or your STB's IP).

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

---

## 🕹️ Emulation Performance Capabilities

| Console Tier | Tested Titles | Performance |
|---|---|---|
| **PlayStation 1 (PSX)** | Tekken 3, Resident Evil 1/2/3, Mortal Kombat Trilogy, SFA3 | **Locked 60 FPS** (PCSX-ReARMed) |
| **Game Boy Advance (GBA)**| Pokémon Emerald, Pokémon FireRed | **Locked 60 FPS** (mGBA) |
| **SNES / Genesis / Arcade**| 31-in-1 Multicart, Super Mario World, Sonic | **Locked 60 FPS** (Snes9x / Genesis Plus) |
| **Nintendo 64 / DS** | Super Mario 64, Pokémon HeartGold | Playable (30–60 FPS) |

*(Note: PlayStation 2 emulation like God of War 1 is not supported due to the 32-bit OS userland architecture and CPU single-core limitations).*

---

## 🛡️ License & Disclaimers
* All third-party APKs, ROMs, and BIOS files are property of their respective copyright holders.
* Scripts and configuration guides are released under the MIT License for educational and local device customization purposes.
