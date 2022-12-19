$i = 999
do {
    Write-Host $i
    Start-Sleep -Seconds 99
    $i--
} while ($i -gt 0)
