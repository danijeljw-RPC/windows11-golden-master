# PowerShell 5.x (Windows PowerShell 5.1)
# Download + silent install Microsoft Visual C++ Redistributable (x64) + no restart

$Url  = 'https://aka.ms/vc14/vc_redist.x64.exe'
$Dir  = 'C:\install'
$File = Join-Path $Dir 'vc_redist.x64.exe'

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
# VC++ redist supports /install /quiet /norestart
$Args = "/install /quiet /norestart"
$p = Start-Process -FilePath $File -ArgumentList $Args -Wait -PassThru

if ($p.ExitCode -ne 0) {
    throw "VC++ Redistributable install failed. Exit code: $($p.ExitCode)"
}

"Installed OK: $File"
