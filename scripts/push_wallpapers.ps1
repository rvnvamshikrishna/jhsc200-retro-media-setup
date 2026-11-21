param(
    [string]$AdbPath = "adb",
    [string]$DeviceIp = "192.168.137.204:5555",
    [string]$WallpaperDir = "..\wallpapers"
)

Write-Host "Connecting to Jio STB ($DeviceIp)..."
& $AdbPath connect $DeviceIp

Write-Host "Creating /sdcard/Pictures/4k game wallpapers/..."
& $AdbPath shell "mkdir -p '/sdcard/Pictures/4k game wallpapers'"

Write-Host "Pushing wallpapers..."
& $AdbPath push "$WallpaperDir/." "/sdcard/Pictures/4k game wallpapers/"

Write-Host "Broadcasting media scan intent..."
& $AdbPath shell "am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d 'file:///sdcard/Pictures/4k%20game%20wallpapers' ; content call --uri content://media/ --method scan_volume --arg external_primary"

$count = & $AdbPath shell "ls -1 '/sdcard/Pictures/4k game wallpapers/' | wc -l"
Write-Host "Successfully indexed $count wallpapers on STB."
