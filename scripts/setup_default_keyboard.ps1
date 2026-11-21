param(
    [string]$AdbPath = "adb",
    [string]$DeviceIp = "192.168.137.204:5555"
)

Write-Host "Connecting to Jio STB ($DeviceIp)..."
& $AdbPath connect $DeviceIp

$imeComponent = "org.liskovsoft.androidtv.rukeyboard/com.liskovsoft.leankeyboard.ime.LeanbackImeService"

Write-Host "Enabling LeanKeyboard IME..."
& $AdbPath shell "ime enable $imeComponent"

Write-Host "Setting LeanKeyboard as active default IME..."
& $AdbPath shell "ime set $imeComponent"

$currentIme = & $AdbPath shell "settings get secure default_input_method"
Write-Host "Active default IME: $currentIme"
