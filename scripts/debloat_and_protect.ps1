param(
    [string]$AdbPath = "adb",
    [string]$DeviceIp = "192.168.137.204:5555"
)

Write-Host "Connecting to Jio STB ($DeviceIp)..."
& $AdbPath connect $DeviceIp

$packagesToDisable = @(
    "insight.tr069.client",
    "com.jio.tr069client",
    "com.rjil.jio.stb.commandreceiver",
    "com.iwedia.updateservice",
    "com.iwedia.httpupdate",
    "com.iwedia.updatercuotaservice",
    "com.iwedia.pvodupdateservice",
    "com.jio.appoptimizer",
    "com.jio.smartmemorymanager",
    "com.rjil.jiostblogservice",
    "com.jio.stb.remotediagnose",
    "com.jio.systemstats",
    "com.jio.jiobackgroundscheduler",
    "com.jio.stbadservice",
    "com.teamviewer.quicksupport.addon.jio_stb",
    "com.jiostb.fti",
    "com.jio.stb.bot",
    "com.jio.bioscopecontentservice"
)

Write-Host "Disabling telemetry, OTA, and task-killer packages..."
foreach ($pkg in $packagesToDisable) {
    & $AdbPath shell "pm disable-user --user 0 $pkg 2>/dev/null ; am force-stop $pkg 2>/dev/null"
    Write-Host "  [Disabled] $pkg"
}

Write-Host "Revoking SYSTEM_ALERT_WINDOW (display over apps) for lockouts and diagnostics..."
$overlayDeny = @(
    "com.jiostb.fti",
    "com.iwedia.updatercuotaservice",
    "com.jio.stb.remotediagnose",
    "com.rjl.mobileremote.receiver"
)
foreach ($pkg in $overlayDeny) {
    & $AdbPath shell "appops set $pkg SYSTEM_ALERT_WINDOW deny 2>/dev/null"
    Write-Host "  [Denied Overlay] $pkg"
}

Write-Host "Debloat and protection complete!"
