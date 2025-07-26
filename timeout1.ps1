# Revised timeout.ps1 to read a filename from a trigger file.
Write-Host "Starting advanced keep-alive script."
Write-Host "To trigger the project upload, run: echo 'your_file.zip' > C:\upload_now.txt" -ForegroundColor Yellow

$counter = 0
$triggerFile = "C:\upload_now.txt"

try {
    while ($true) {
        # Check if the trigger file exists
        if (Test-Path $triggerFile) {
            # Read the filename from the trigger file
            $fileNameToUpload = Get-Content $triggerFile | Select-Object -First 1
            
            if (-not [string]::IsNullOrWhiteSpace($fileNameToUpload)) {
                Write-Host "Upload trigger detected for file: $fileNameToUpload" -ForegroundColor Green
                
                # Set the filename as an output for the next job to use
                echo "zip_filename=$fileNameToUpload" >> $env:GITHUB_OUTPUT

                Remove-Item $triggerFile -Force # Clean up the trigger file
                break # Exit the while loop
            }
        }
        
        # Wait for 60 seconds
        Start-Sleep -Seconds 60
        
        $counter++
        Write-Host "--- Keep-Alive Cycle #$($counter) at $(Get-Date -Format g) ---"
        # ... your other keep-alive tasks remain here ...
        Write-Host "--- Cycle End ---"
    }
}
finally {
    Write-Host "Keep-alive script ending."
}
