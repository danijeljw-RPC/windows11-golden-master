# PowerShell 5.x (Windows PowerShell 5.1)
# Download + silent install .NET Windows Desktop Runtime 10.0.1 (x64)

$Url  = 'https://builds.dotnet.microsoft.com/dotnet/WindowsDesktop/10.0.1/windowsdesktop-runtime-10.0.1-win-x64.exe'
$Dir  = 'C:\install'
$File = Join-Path $Dir 'windowsdesktop-runtime-10.0.1-win-x64.exe'

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

if (-not (Test-Path $File)) { throw "Installer not found after download: $File" }

# Silent install + no restart + wait + capture exit code
# For .NET runtime EXE installers, /install + /quiet + /norestart is the standard pattern
$Args = "/install /quiet /norestart"
$p = Start-Process -FilePath $File -ArgumentList $Args -Wait -PassThru

if ($p.ExitCode -ne 0) {
    throw ".NET Windows Desktop Runtime install failed. Exit code: $($p.ExitCode)"
}

"Installed OK: $File"
