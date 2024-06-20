# keep-alive.ps1

# Define the keep-alive task action
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "Write-Output 'Keeping session alive at $(Get-Date)'"

# Define the trigger to run every 5 minutes
$trigger = New-ScheduledTaskTrigger -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration (New-TimeSpan -Days 1) -Once -At (Get-Date).Date

# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "KeepSessionAlive" -Description "Task to keep the session alive"

# Keep the script running
while ($true) {
    Start-Sleep -Seconds 300  # Sleep for 5 minutes
}
