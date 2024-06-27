# Continuous Disk Cleanup Script
# CAUTION: This script runs continuously. Use with extreme care.

$cleanupInterval = 3600  # Time in seconds between cleanups (default: 1 hour)
$maxRuntime = 86400      # Maximum runtime in seconds (default: 24 hours)
$startTime = Get-Date

Write-Host "Starting continuous Disk Cleanup process..." -ForegroundColor Cyan
Write-Host "This script will run for a maximum of $($maxRuntime / 3600) hours." -ForegroundColor Yellow
Write-Host "Press Ctrl+C to stop the script at any time." -ForegroundColor Yellow

$attemptCount = 0

while ($true) {
    $attemptCount++
    $currentTime = Get-Date
    $elapsedTime = ($currentTime - $startTime).TotalSeconds

    if ($elapsedTime -ge $maxRuntime) {
        Write-Host "Maximum runtime reached. Stopping script." -ForegroundColor Red
        break
    }

    $freeSpaceBefore = (Get-PSDrive C).Free / 1GB
    Write-Host "Attempt $attemptCount - Free space before cleanup: $($freeSpaceBefore.ToString("N2")) GB" -ForegroundColor Green

    # Run Disk Cleanup
    Write-Host "Running Disk Cleanup..." -ForegroundColor Green
    Start-Process -FilePath Cleanmgr -ArgumentList '/sagerun:1' -Wait

    $freeSpaceAfter = (Get-PSDrive C).Free / 1GB
    $spaceCleared = $freeSpaceAfter - $freeSpaceBefore

    Write-Host "Free space after cleanup: $($freeSpaceAfter.ToString("N2")) GB" -ForegroundColor Green
    Write-Host "Space cleared: $($spaceCleared.ToString("N2")) GB" -ForegroundColor Yellow

    if ($spaceCleared -le 0) {
        Write-Host "No additional space cleared. Waiting for next cycle." -ForegroundColor Yellow
    }

    $nextCleanupTime = $currentTime.AddSeconds($cleanupInterval)
    Write-Host "Next cleanup scheduled at: $nextCleanupTime" -ForegroundColor Cyan

    # Wait for the specified interval before next cleanup
    Start-Sleep -Seconds $cleanupInterval
}

Write-Host "Continuous Disk Cleanup process ended." -ForegroundColor Cyan
