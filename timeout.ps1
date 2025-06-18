# Revised timeout.ps1 to perform more 'active' tasks.
Write-Host "Starting advanced keep-alive script."
$counter = 0

try {
    while ($true) {
        # Wait for 60 seconds
        Start-Sleep -Seconds 60
        
        $counter++
        Write-Host "--- Keep-Alive Cycle #$($counter) at $(Get-Date -Format g) ---"
        
        # Task 1: Check network configuration
        Write-Host "Checking network status..."
        ipconfig /all | Select-String "IPv4 Address"
        
        # Task 2: List running Chrome processes (if any)
        Write-Host "Checking for Chrome processes..."
        Get-Process -Name "chrome" -ErrorAction SilentlyContinue | Select-Object -First 5 -Property ProcessName, ID, WorkingSet
        
        # Task 3: Check current directory contents
        Write-Host "Listing current directory..."
        Get-ChildItem -Path . | Select-Object -First 5 -Property Name, Length
        
        Write-Host "--- Cycle End ---"
    }
}
finally {
    Write-Host "Keep-alive script ending."
}
