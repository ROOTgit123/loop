# 1. Disk Cleanup
Write-Host "Running Disk Cleanup..." -ForegroundColor Green
Start-Process -FilePath Cleanmgr -ArgumentList '/sagerun:1' -Wait
