$StartTime = Get-Date
$MaxMinutes = 330 
$CurrentIter = [int]$env:ITERATION
$NextIter = $CurrentIter + 1
$TargetHost = "rdp-$NextIter"

while ($true) {
    $Elapsed = (Get-Date) - $StartTime
    
    if ($Elapsed.TotalMinutes -ge $MaxMinutes) {
        Write-Host "Triggering Next RDP..."
        $env:GH_TOKEN = $env:GH_PAT
        gh workflow run Windows-Direct-Transfer.yml -f iteration="$NextIter"

        Write-Host "Waiting for $TargetHost to come online..."
        # Wait for the new RDP to appear on Tailscale
        while (!(Test-Connection -ComputerName $TargetHost -Count 1 -Quiet)) {
            Start-Sleep -Seconds 10
        }

        Write-Host "Directly Transferring Files to $TargetHost..."
        # Mapping the New RDP's shared folder as a drive
        $dest = "\\$TargetHost\Data"
        net use T: $dest /user:runneradmin YourPassword123!
        
        # Copy everything from current work dir to the new machine
        Copy-Item -Path "C:\Users\runneradmin\Desktop\*" -Destination "T:\" -Recurce -Force
        
        Write-Host "Transfer Complete. You can now switch to $TargetHost"
        Start-Sleep -Seconds 300
        exit
    }
    Start-Sleep -Seconds 60
}
