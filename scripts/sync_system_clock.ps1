param(
    [string]$AdbPath = "adb",
    [string]$DeviceIp = "192.168.137.204:5555"
)

Write-Host "Connecting to Jio STB ($DeviceIp)..."
& $AdbPath connect $DeviceIp

# Calculate current UTC epoch in milliseconds
$epochMs = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
Write-Host "Syncing hardware alarm clock to epoch ms: $epochMs..."

& $AdbPath shell "cmd alarm set-time $epochMs"
& $AdbPath shell "settings put global ntp_server time.google.com"
& $AdbPath shell "settings put global auto_time 1"
& $AdbPath shell "settings put global auto_time_zone 1"

$currentDate = & $AdbPath shell "date"
Write-Host "STB system time successfully synchronized: $currentDate"
