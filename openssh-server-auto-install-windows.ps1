[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Ssl3

$url = "https://github.com/PowerShell/Win32-OpenSSH/releases/download/v9.5.0.0p1-Beta/OpenSSH-Win64-v9.5.0.0.msi"
$downloadsPath = Join-Path $env:USERPROFILE "Downloads"
$tempFilePath = Join-Path $downloadsPath "OpenSSH-Win64-v9.5.0.0.msi"
$file_loc = "C:\Program Files\OpenSSH\"
$localFilePath = Join-Path $PSScriptRoot "OpenSSH-Win64-v9.5.0.0.msi"

$outputDownloaded = $false

try {
    Invoke-WebRequest -Uri $url -OutFile $tempFilePath -ErrorAction Stop
    Write-Host "File downloaded successfully: $tempFilePath"
    $outputDownloaded = $true
    $installerPath = $tempFilePath
}
catch {
    Write-Warning "Failed to download the file from URL! Trying local file."
    if (Test-Path $localFilePath) {
        Write-Host "Using local file directly: $localFilePath"
        $installerPath = $localFilePath
    }
    else {
        Write-Error "Local file not found: $localFilePath"
        exit 1
    }
}

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Please run this script as an Administrator."
    exit 1
}

# Install OpenSSH with waiting for completion
$process = Start-Process msiexec.exe -Wait -ArgumentList "/quiet /i `"$installerPath`"" -PassThru

if ($process.ExitCode -eq 0 -and (Test-Path "$file_loc\sshd.exe")) {
    Write-Host "OpenSSH installed successfully."
}
else {
    Write-Error "OpenSSH installation failed. Exit code: $($process.ExitCode)"
    exit 1
}

# Set proper permissions
PowerShell -ExecutionPolicy Bypass -File "$file_loc\FixHostFilePermissions.ps1"

# Allow port 22 in Firewall
New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

# Set SSH service to Automatic startup
Set-Service -Name sshd -StartupType Automatic

# Check if port 22 is listening
$portStatus = Get-NetTCPConnection -LocalPort 22 | Where-Object {$_.State -eq 'Listen'}
if ($portStatus) {
    Write-Host "Port 22 is open."
}
else {
    Write-Warning "Port 22 is not detected."
}

# Restart SSH service
Restart-Service sshd

# Check SSH service status
if ((Get-Service sshd).Status -eq "Running") {
    Write-Host "OpenSSH service is running."
}
else {
    Write-Error "OpenSSH service is not running!"
    exit 1
}

# Remove temporary downloaded file if it was downloaded
if ($outputDownloaded -and (Test-Path $tempFilePath)) {
    Remove-Item -Path $tempFilePath -Force
    Write-Host "Temporary file deleted: $tempFilePath"
}

Write-Host "Script completed successfully."

