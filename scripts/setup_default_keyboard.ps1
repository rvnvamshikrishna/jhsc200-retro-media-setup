param(
    [string]$AdbPath = "adb",
    [string]$StbIp = ""
)

if (-not $StbIp) {
    $StbIp = Read-Host "Enter Jio STB IP address (e.g. <STB_IP> or <STB_IP>:5555)"
}
if ($StbIp -notmatch ':\d+$') {
    $StbIp = "$StbIp:5555"
}

Write-Host "Connecting to Jio STB ($StbIp)..."
& $AdbPath connect $StbIp

$imeComponent = "org.liskovsoft.androidtv.rukeyboard/com.liskovsoft.leankeyboard.ime.LeanbackImeService"

Write-Host "Enabling LeanKeyboard IME..."
& $AdbPath shell "ime enable $imeComponent"

Write-Host "Setting LeanKeyboard as active default IME..."
& $AdbPath shell "ime set $imeComponent"

$currentIme = & $AdbPath shell "settings get secure default_input_method"
Write-Host "Active default IME: $currentIme"
