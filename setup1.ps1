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

Write-Verbose "Setup completed successfully."
