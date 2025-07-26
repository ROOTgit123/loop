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

# --- New Functions for Android Studio and Flutter ---

# Function to download and install Android Studio
function Install-AndroidStudio {
    $installPath = "C:\Program Files\Android\Android Studio" # Choose your desired installation path
    $installerUrl = "https://redirector.gvt1.com/edgedl/android/studio/install/2025.1.1.14/android-studio-2025.1.1.14-windows.exe" # This URL might change; verify it
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
    $flutterZipUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.32.6-stable.zip" # Verify the latest stable version URL
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
    # Decide if you want to exit or continue if Android Studio fails
    exit 1
}

# Setup Flutter
try {
    Setup-Flutter
} catch {
    Write-Error "Failed to setup Flutter: $_"
    # Decide if you want to exit or continue if Flutter fails
    exit 1
}

# Extensive Windows Optimization Script (placeholder)
# CAUTION: This script makes significant changes to your system. Use at your own risk.
# (Your original comment)


Write-Verbose "Setup completed successfully."
