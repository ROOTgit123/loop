$VerbosePreference = "Continue"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# --- 1. INSTALL CHROME & CRD ---
function Install-BaseTools {
    $crd = Join-Path $env:TEMP "crd.msi"
    Invoke-WebRequest 'https://dl.google.com/edgedl/chrome-remote-desktop/chromeremotedesktophost.msi' -OutFile $crd
    Start-Process msiexec.exe -ArgumentList "/i `"$crd`" /qn /norestart" -Wait
    
    $chrome = Join-Path $env:TEMP "chrome.exe"
    Invoke-WebRequest 'https://dl.google.com/chrome/install/latest/chrome_installer.exe' -OutFile $chrome
    Start-Process $chrome -ArgumentList "/silent /install" -Wait
}

# --- 2. INSTALL UNITY HUB & EDITOR ---
function Install-Unity {
    $hub = Join-Path $env:TEMP "UnityHubSetup.exe"
    Write-Verbose "Downloading Unity Hub..."
    Invoke-WebRequest 'https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup.exe' -OutFile $hub
    Start-Process $hub -ArgumentList "/S" -Wait

    # Wait for Hub to register in system
    Start-Sleep -Seconds 10
    $hubCli = "C:\Program Files\Unity Hub\Unity Hub.exe"

    Write-Verbose "Installing Unity Editor 2022.3 (LTS)..."
    # Note: This version is stable and fits runner constraints
    Start-Process $hubCli -ArgumentList "-- --headless install --version 2022.3.10f1" -Wait
}

# --- 3. INSTALL VISUAL STUDIO (For Coding) ---
function Install-VSCommunity {
    Write-Verbose "Downloading VS Community Installer..."
    $vs = Join-Path $env:TEMP "vs_community.exe"
    Invoke-WebRequest 'https://aka.ms/vs/17/release/vs_community.exe' -OutFile $vs
    
    # Installs the basic C# and Unity workload
    Write-Verbose "Installing VS with Unity Workload..."
    Start-Process $vs -ArgumentList "--add Microsoft.VisualStudio.Workload.ManagedGame --quiet --norestart --wait" -Wait
}

# Execute all
Install-BaseTools
Install-Unity
Install-VSCommunity

Write-Verbose "All tools installed! Ready to build."
