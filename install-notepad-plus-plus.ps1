# PowerShell 5.x (Windows PowerShell 5.1)
# Download + silent install Notepad++ 8.8.9 (x64 MSI)

$Url  = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.8.9/npp.8.8.9.Installer.x64.msi'
$Dir  = 'C:\install'
$File = Join-Path $Dir 'npp.8.8.9.Installer.x64.msi'
$MsiPath = $File

# Ensure TLS 1.2 for .NET-based downloaders (Invoke-WebRequest/WebClient)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Create folder
New-Item -Path $Dir -ItemType Directory -Force | Out-Null

# Download (BITS is usually the most reliable on Windows)
try {
    Start-BitsTransfer -Source $Url -Destination $File -ErrorAction Stop
}
catch {
    # Fallback if BITS is unavailable / blocked
    Invoke-WebRequest -Uri $Url -OutFile $File -UseBasicParsing -ErrorAction Stop
}

if (-not (Test-Path $MsiPath)) { throw "MSI not found after download: $MsiPath" }

# Silent install + wait + capture exit code
$Args = "/i `"$MsiPath`" /qn /norestart"
$p = Start-Process -FilePath "$env:WINDIR\System32\msiexec.exe" -ArgumentList $Args -Wait -PassThru

if ($p.ExitCode -ne 0) {
    throw "Notepad++ MSI install failed. msiexec exit code: $($p.ExitCode)"
}

"Installed OK: $MsiPath"
