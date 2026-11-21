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

# Calculate current UTC epoch in milliseconds
$epochMs = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
Write-Host "Syncing hardware alarm clock to epoch ms: $epochMs..."

& $AdbPath shell "cmd alarm set-time $epochMs"
& $AdbPath shell "settings put global ntp_server time.google.com"
& $AdbPath shell "settings put global auto_time 1"
& $AdbPath shell "settings put global auto_time_zone 1"

$currentDate = & $AdbPath shell "date"
Write-Host "STB system time successfully synchronized: $currentDate"
