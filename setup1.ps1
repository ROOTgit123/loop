# Enable verbose logging
$VerbosePreference = "Continue"

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Function to download and install Chrome Remote Desktop Host
function Install-CRDHost {
    $P = $env:TEMP + '\chromeremotedesktophost.msi'
    Write-Verbose "Downloading Chrome Remote Desktop Host..."
    Invoke-WebRequest 'https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi' -OutFile $P -Verbose
    Write-Verbose "Installing Chrome Remote Desktop Host..."
    Start-Process $P -Wait -ErrorAction Stop
    Write-Verbose "Removing installer file..."
    Remove-Item $P -Verbose
}

# Function to download and install Chrome
function Install-Chrome {
    $P = $env:TEMP + '\chrome_installer.exe'
    Write-Verbose "Downloading Google Chrome..."
    Invoke-WebRequest 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile $P -Verbose
    Write-Verbose "Installing Google Chrome..."
    $args = "/install", "--silent", "--disable-infobars", "--no-first-run"
    try {
        Start-Process -FilePath $P -ArgumentList $args -Verb RunAs -Wait -ErrorAction Stop
    } catch {
        Write-Error "Failed to install Google Chrome: $_"
        exit 1
    }
    Write-Verbose "Removing installer file..."
    Remove-Item $P -Verbose
}

# Disable firewall profiles
Write-Verbose "Disabling firewall profiles..."
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -Verbose

# Install Chrome Remote Desktop Host
try {
    Install-CRDHost
} catch {
    Write-Error "Failed to install Chrome Remote Desktop Host: $_"
    exit 1
}

# Install Google Chrome
try {
    Install-Chrome
} catch {
    Write-Error "Failed to install Google Chrome: $_"
    exit 1
}


# Extensive Windows Optimization Script
# CAUTION: This script makes significant changes to your system. Use at your own risk.

# Ensure running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run this script as an Administrator." -ForegroundColor Red
    Exit
}

# Create a restore point
Write-Host "Creating a system restore point..." -ForegroundColor Cyan
Checkpoint-Computer -Description "Before Extensive Optimization" -RestorePointType "MODIFY_SETTINGS"

# 1. Disk Cleanup
Write-Host "Running Disk Cleanup..." -ForegroundColor Green
Start-Process -FilePath Cleanmgr -ArgumentList '/sagerun:1' -Wait

# 2. Disable unnecessary startup programs
Write-Host "Disabling unnecessary startup programs..." -ForegroundColor Green
Get-CimInstance Win32_StartupCommand | Where-Object {$_.Location -eq "HKU"} | Disable-ScheduledTask

# 3. Adjust visual effects for performance
Write-Host "Adjusting visual effects for performance..." -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2

# 4. Uninstall bloatware (excluding Chrome Remote Desktop Host and Google Chrome)
Write-Host "Uninstalling bloatware..." -ForegroundColor Green
$bloatware = @(
    "Microsoft.3DBuilder", "Microsoft.AppConnector", "Microsoft.BingFinance", "Microsoft.BingNews",
    "Microsoft.BingSports", "Microsoft.BingTranslator", "Microsoft.BingWeather", "Microsoft.CommsPhone",
    "Microsoft.ConnectivityStore", "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer", "Microsoft.MicrosoftOfficeHub", "Microsoft.MicrosoftPowerBIForWindows",
    "Microsoft.MicrosoftSolitaireCollection", "Microsoft.NetworkSpeedTest", "Microsoft.Office.Sway",
    "Microsoft.OneConnect", "Microsoft.People", "Microsoft.Print3D", "Microsoft.SkypeApp",
    "Microsoft.Wallet", "Microsoft.WindowsAlarms", "Microsoft.WindowsCamera",
    "microsoft.windowscommunicationsapps", "Microsoft.WindowsFeedbackHub", "Microsoft.WindowsMaps",
    "Microsoft.WindowsPhone", "Microsoft.WindowsSoundRecorder", "Microsoft.Xbox.TCUI",
    "Microsoft.XboxApp", "Microsoft.XboxGameOverlay", "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.ZuneMusic", "Microsoft.ZuneVideo"
)
foreach ($app in $bloatware) {
    Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
}

# 5. Optimize drives
Write-Host "Optimizing drives..." -ForegroundColor Green
Get-Volume | Where-Object {$_.DriveLetter -ne $null} | Optimize-Volume

# 6. Disable unnecessary services
Write-Host "Disabling unnecessary services..." -ForegroundColor Green
$services = @(
    "DiagTrack", "dmwappushservice", "HomeGroupListener", "HomeGroupProvider", "lfsvc",
    "MapsBroker", "NetTcpPortSharing", "RemoteAccess", "RemoteRegistry", "SharedAccess",
    "TrkWks", "WbioSrvc", "WMPNetworkSvc", "XblAuthManager", "XblGameSave", "XboxNetApiSvc"
)
foreach ($service in $services) {
    Set-Service -Name $service -StartupType Disabled
}

# 7. Disable Windows features
Write-Host "Disabling unnecessary Windows features..." -ForegroundColor Green
$features = @(
    "Internet-Explorer-Optional-amd64", "MediaPlayback", "WindowsMediaPlayer",
    "WorkFolders-Client", "Printing-XPSServices-Features", "FaxServicesClientPackage"
)
foreach ($feature in $features) {
    Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart
}

# 8. Configure power settings for high performance
Write-Host "Configuring power settings for high performance..." -ForegroundColor Green
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# 9. Clear temporary files
Write-Host "Clearing temporary files..." -ForegroundColor Green
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# 10. Disable Windows tips and suggestions
Write-Host "Disabling Windows tips and suggestions..." -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Type DWord -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0

# 11. Disable Cortana
Write-Host "Disabling Cortana..." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0

# 12. Disable telemetry
Write-Host "Disabling telemetry..." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0

# 13. Disable Windows Store automatic app updates
Write-Host "Disabling Windows Store automatic app updates..." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" -Name "AutoDownload" -Type DWord -Value 2

# 14. Disable Windows Consumer Features
Write-Host "Disabling Windows Consumer Features..." -ForegroundColor Green
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1

# 15. Disable OneDrive
Write-Host "Disabling OneDrive..." -ForegroundColor Green
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

# 16. Disable Windows Search indexing
Write-Host "Disabling Windows Search indexing..." -ForegroundColor Green
Stop-Service "WSearch" -Force
Set-Service "WSearch" -StartupType Disabled

# 17. Disable Superfetch
Write-Host "Disabling Superfetch..." -ForegroundColor Green
Stop-Service "SysMain" -Force
Set-Service "SysMain" -StartupType Disabled

# 18. Disable hibernation
Write-Host "Disabling hibernation..." -ForegroundColor Green
powercfg /hibernate off

# 19. Set DNS to Google's DNS
Write-Host "Setting DNS to Google's DNS..." -ForegroundColor Green
Set-DnsClientServerAddress -InterfaceAlias "Ethernet*" -ServerAddresses ("8.8.8.8", "8.8.4.4")
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi*" -ServerAddresses ("8.8.8.8", "8.8.4.4")

# 20. Update Windows
Write-Host "Checking for Windows updates..." -ForegroundColor Green
Install-Module PSWindowsUpdate -Force
Get-WindowsUpdate -Install -AcceptAll

Write-Host "Optimization complete. Please restart your computer for changes to take effect." -ForegroundColor Yellow
Write-Host "CAUTION: Some changes may affect system functionality. Review all changes carefully." -ForegroundColor Red

Write-Verbose "Setup completed successfully."
