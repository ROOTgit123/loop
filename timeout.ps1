$timer = New-Object Timers.Timer
$timer.Interval = 60000 # 60 seconds
$timer.AutoReset = $true
$timer.add_Elapsed({ Write-Host "Keeping the session alive..." })

$timer.Start()
Write-Host "Timer started. Press Ctrl+C to stop."
try {
    while ($true) {
        Start-Sleep -Seconds 60000
    }
} finally {
    $timer.Stop()
    $timer.Dispose()
}
