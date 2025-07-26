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

# --- Functions for Android Studio and Flutter ---

# Function to download and install Android Studio
function Install-AndroidStudio {
    $installPath = "C:\Program Files\Android\Android Studio" # Choose your desired installation path
    $installerUrl = "https://redirector.gvt1.com/edgedl/android/studio/install/2025.1.1.14/android-studio-2025.1.1.14-windows.exe" # User-specified URL
    $installerFile = Join-Path $env:TEMP "android-studio-installer.exe"

    Write-Verbose "Downloading Android Studio from $installerUrl..."
    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerFile -Verbose -ErrorAction Stop
    } catch {
        Write-Error "Failed to download Android Studio: $_"
        exit 1
    }

    Write-Verbose "Installing Android Studio silently to $installPath..."
    # Silent installation arguments for NSIS installer
    # /S for silent, /D=path for installation directory
    try {
        Start-Process -FilePath $installerFile -ArgumentList "/S", "/D=$installPath" -Wait -ErrorAction Stop
    } catch {
        Write-Error "Failed to install Android Studio: $_"
        exit 1
    }

    Write-Verbose "Android Studio installed to $installPath."
    Remove-Item $installerFile -Force -ErrorAction SilentlyContinue
}

# Function to download and set up Flutter
function Setup-Flutter {
    $flutterSdkPath = "C:\flutter" # Choose your desired Flutter SDK path
    $flutterZipUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.32.6-stable.zip" # User-specified URL
    $zipFile = Join-Path $env:TEMP "flutter.zip"

    # Create the Flutter SDK directory if it doesn't exist
    if (-not (Test-Path $flutterSdkPath)) {
        New-Item -ItemType Directory -Path $flutterSdkPath -Force
        Write-Verbose "Created Flutter SDK directory: $flutterSdkPath"
    }

    Write-Verbose "Downloading Flutter SDK from $flutterZipUrl..."
    try {
        Invoke-WebRequest -Uri $flutterZipUrl -OutFile $zipFile -Verbose -ErrorAction Stop
    } catch {
        Write-Error "Failed to download Flutter SDK: $_"
        exit 1
    }

    Write-Verbose "Extracting Flutter SDK to $flutterSdkPath..."
    try {
        Expand-Archive -Path $zipFile -DestinationPath $flutterSdkPath -Force
    } catch {
        Write-Error "Failed to extract Flutter SDK: $_"
        exit 1
    }

    Write-Verbose "Setting up Flutter environment variables..."
    # Add Flutter bin directory to the System PATH
    $flutterBinPath = Join-Path $flutterSdkPath "flutter\bin"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    if ($currentPath -notlike "*$flutterBinPath*") {
        [Environment]::SetEnvironmentVariable("Path", "$currentPath;$flutterBinPath", "Machine")
        Write-Verbose "Added $flutterBinPath to System PATH."
    } else {
        Write-Verbose "$flutterBinPath already in System PATH."
    }

    Write-Verbose "Removing Flutter zip file..."
    Remove-Item $zipFile -Force -ErrorAction SilentlyContinue

    Write-Verbose "Running 'flutter doctor' to verify installation..."
    # This might require an elevated prompt if it tries to install Android SDK components
    try {
        & "$flutterBinPath\flutter.bat" doctor --verbose
    } catch {
        Write-Warning "Failed to run 'flutter doctor'. You may need to run it manually after the script completes."
    }
}

# --- End New Functions ---

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

# --- Execute New Installations ---
# Install Android Studio
try {
    Install-AndroidStudio
} catch {
    Write-Error "Failed to install Android Studio: $_"
    exit 1
}

# Setup Flutter
try {
    Setup-Flutter
} catch {
    Write-Error "Failed to setup Flutter: $_"
    exit 1
}

# Extensive Windows Optimization Script
# CAUTION: This script makes significant changes to your system. Use at your own risk.

Write-Host "Starting extensive Windows optimization process..." -ForegroundColor Yellow

# --- 1. Power Settings Optimization ---
Write-Host "Applying High Performance Power Plan..." -ForegroundColor Cyan
try {
    # Get the GUID for the High Performance power plan
    $highPerformanceGuid = (powercfg /list | Select-String "High performance").ToString().Trim()
    if ($highPerformanceGuid) {
        # Extract the GUID from the string
        $highPerformanceGuid = $highPerformanceGuid.Split(' ')[-1]
        powercfg /setactive $highPerformanceGuid
        Write-Host "Successfully set power plan to High Performance." -ForegroundColor Green
    } else {
        Write-Warning "High Performance power plan not found. Skipping power plan optimization."
    }
} catch {
    Write-Warning "Failed to set power plan: $_"
}

# --- 2. Disable Visual Effects for Performance ---
Write-Host "Adjusting visual effects for best performance..." -ForegroundColor Cyan
try {
    # This requires modifying the registry.
    # Disables animations, fades, shadows, etc.
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -Force -ErrorAction Stop
    # Also apply to system wide settings if possible (might require reboot or specific user context)
    # This part is more complex to apply system-wide silently without specific APIs.
    Write-Host "Visual effects set to 'Adjust for best performance'." -ForegroundColor Green
} catch {
    Write-Warning "Failed to adjust visual effects: $_"
}

# --- 3. Disable Unnecessary Services ---
Write-Host "Disabling unnecessary services..." -ForegroundColor Cyan
$servicesToDisable = @(
    "DiagTrack",              # Connected User Experiences and Telemetry
    "dmwappushservice",       # WAP Push Message Routing Service (if not using push messages)
    "SysMain",                # Superfetch/ReadyBoost - Can cause high disk usage on SSDs, debated on HDDs
    "MapsBroker",             # Downloaded Maps Manager
    "InstallService",         # Microsoft Store Install Service (if not using MS Store)
    "XboxGipSvc",             # Xbox Accessory Management Service
    "XblGameSave",            # Xbox Live Game Save
    "DoSvc",                  # Delivery Optimization (P2P updates)
    "CDPUserSvc_",            # Connected Devices Platform User Service (each user has one)
    "OneSyncSvc_",            # Sync Host (each user has one)
    "WSearch",                # Windows Search (if you prefer not to index)
    "NetTcpPortSharing",      # Net.Tcp Port Sharing Service
    "RemoteRegistry",         # Remote Registry (security risk, rarely needed)
    "Fax",                    # Fax service (if not using fax)
    "PeerDistSvc",            # BranchCache
    "P2PIMSVC",               # Peer Name Resolution Protocol
    "PNRPAutoReg"             # Peer Networking Grouping
)

foreach ($service in $servicesToDisable) {
    try {
        $currentService = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($currentService) {
            if ($currentService.Status -ne "Stopped") {
                Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                Write-Host "Stopped service: $service" -ForegroundColor DarkYellow
            }
            Set-Service -Name $service -StartupType Disabled -ErrorAction Stop
            Write-Host "Disabled service: $service" -ForegroundColor Green
        } else {
            Write-Host "Service $service not found. Skipping." -ForegroundColor DarkGray
        }
    } catch {
        Write-Warning "Failed to disable service $service: $_"
    }
}

# --- 4. Disable Startup Programs (Task Manager Startup tab equivalent) ---
Write-Host "Disabling unnecessary startup programs..." -ForegroundColor Cyan
# This is complex to do universally as programs use various startup methods.
# A common approach is to target specific registry run keys or Scheduled Tasks.
# For simplicity, we'll give an example of a common area.
$startupRegistryPaths = @(
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
)
# Note: Disabling via registry might not be sufficient for all programs (e.g., Scheduled Tasks)
# A more robust solution often involves third-party tools or deeper analysis.
Write-Host "Manual review of startup programs via Task Manager is recommended for comprehensive control." -ForegroundColor Yellow

# --- 5. Disk Cleanup (beyond what clean.ps1 does for temp files) ---
Write-Host "Performing additional disk cleanup (beyond continuous cleanup)..." -ForegroundColor Cyan
try {
    # Clean SoftwareDistribution (Windows Update Cache)
    Write-Host "Cleaning Windows Update cache..." -ForegroundColor DarkYellow
    Stop-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Write-Host "Windows Update cache cleaned." -ForegroundColor Green

    # Clean Prefetch files
    Write-Host "Cleaning Prefetch files..." -ForegroundColor DarkYellow
    Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Prefetch files cleaned." -ForegroundColor Green

    # Empty Recycle Bin
    Write-Host "Emptying Recycle Bin..." -ForegroundColor DarkYellow
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    Write-Host "Recycle Bin emptied." -ForegroundColor Green

} catch {
    Write-Warning "Failed to perform additional disk cleanup: $_"
}

# --- 6. Disable Notifications and Focus Assist ---
Write-Host "Disabling notifications and enabling Focus Assist (Alarms only)..." -ForegroundColor Cyan
try {
    # Disable Action Center notifications (requires registry modification)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_ENABLED" -Value 0 -Force -ErrorAction SilentlyContinue

    # Enable Focus Assist and set to Alarms only
    # Note: Focus Assist settings are complex and might vary by Windows version.
    # This might require a restart or user logoff to take full effect.
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_FOCUSAUTOTOGGLE" -Value 1 -Force -ErrorAction SilentlyContinue # Enable focus assist
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings" -Name "NOC_GLOBAL_SETTING_FOCUSAUTOTOGGLE_STATE" -Value 1 -Force -ErrorAction SilentlyContinue # Alarms only
    Write-Host "Notifications reduced and Focus Assist set to Alarms only." -ForegroundColor Green
} catch {
    Write-Warning "Failed to adjust notification settings: $_"
}

# --- 7. Disable Windows Telemetry/Data Collection ---
Write-Host "Disabling Windows Telemetry and Data Collection..." -ForegroundColor Cyan
try {
    # Set Telemetry level to Security (minimum)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue

    # Disable Customer Experience Improvement Program (CEIP)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\SQMClient\Windows" -Name "CEIPEnable" -Value 0 -Force -ErrorAction SilentlyContinue

    Write-Host "Windows Telemetry and CEIP disabled." -ForegroundColor Green
} catch {
    Write-Warning "Failed to disable telemetry: $_"
}

# --- 8. Disable Game Bar and Game DVR ---
Write-Host "Disabling Xbox Game Bar and Game DVR..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force -ErrorAction SilentlyContinue
    Write-Host "Xbox Game Bar and Game DVR disabled." -ForegroundColor Green
} catch {
    Write-Warning "Failed to disable Game Bar/DVR: $_"
}

# --- 9. Disable Tips, Tricks, and Suggestions ---
Write-Host "Disabling tips, tricks, and suggestions..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -Force -ErrorAction SilentlyContinue # Tips & Suggestions
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -Force -ErrorAction SilentlyContinue # Spotlight Ads
    Write-Host "Tips, tricks, and suggestions disabled." -ForegroundColor Green
} catch {
    Write-Warning "Failed to disable tips/suggestions: $_"
}

# --- 10. Disable Background Apps ---
Write-Host "Attempting to disable background apps (requires registry modification)..." -ForegroundColor Cyan
try {
    # This setting is typically found in Settings -> Privacy -> Background apps.
    # Disabling it globally requires modifying a specific registry key.
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force -ErrorAction SilentlyContinue
    Write-Host "Background apps global access disabled." -ForegroundColor Green
} catch {
    Write-Warning "Failed to disable background apps: $_"
}

Write-Host "Windows optimization script completed. Some changes may require a restart to take full effect." -ForegroundColor Yellow
Write-Host "Remember to review settings manually if any issues arise." -ForegroundColor Yellow


Write-Verbose "Setup completed successfully."
