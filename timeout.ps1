$i = 99999
do {
    Write-Host $i
    Start-Sleep -Seconds 99999
    $i--
} while ($i -gt 0)
