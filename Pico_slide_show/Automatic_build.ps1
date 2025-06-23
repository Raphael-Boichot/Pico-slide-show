Set-ExecutionPolicy Bypass -Scope Process -Force

######################################Section 1: intalling Arduino CLI#########################################################

# Constants
$cliInstallDir = "$env:USERPROFILE\arduino-cli"
$cliExe = Join-Path $cliInstallDir "arduino-cli.exe"
$coreIdentifier = "rp2040:rp2040"
$coreURL = "https://github.com/earlephilhower/arduino-pico/releases/download/global/package_rp2040_index.json"

# Fetch latest Arduino CLI release info from GitHub
try {
    $releaseInfo = Invoke-RestMethod "https://api.github.com/repos/arduino/arduino-cli/releases/latest"
    $latestVersion = $releaseInfo.tag_name.TrimStart("v")
    $cliAsset = $releaseInfo.assets | Where-Object { $_.name -like "*Windows_64bit.zip" }
    $cliUrl = $cliAsset.browser_download_url
} catch {
    Write-Error "Failed to fetch latest Arduino CLI version info from GitHub."
    exit 1
}

# Check if CLI is installed and up to date
$cliExists = Test-Path $cliExe
$cliUpToDate = $false
$installedVersion = $null

if ($cliExists) {
    try {
        $versionRaw = & "$cliExe" version --format json 2>$null
        if (![string]::IsNullOrWhiteSpace($versionRaw)) {
            $parsed = $versionRaw | ConvertFrom-Json
            $installedVersion = $parsed.VersionString
            if ($installedVersion -eq $latestVersion) {
                $cliUpToDate = $true
                Write-Host "Arduino CLI is up to date (v$installedVersion)"
            } else {
                Write-Host "Updating Arduino CLI from v$installedVersion to v$latestVersion"
            }
        } else {
            Write-Host "Could not read installed version. Proceeding with reinstall."
        }
    } catch {
        Write-Host "Error reading Arduino CLI version. Proceeding with reinstall."
    }
}

# Download and install CLI if needed
if (-not $cliExists -or -not $cliUpToDate) {
    $cliZip = "$env:TEMP\arduino-cli.zip"
    if (-not (Test-Path $cliInstallDir)) {
        New-Item -ItemType Directory -Path $cliInstallDir | Out-Null
    }

    Write-Host "Downloading Arduino CLI v$latestVersion..."
    Invoke-WebRequest -Uri $cliUrl -OutFile $cliZip
    Expand-Archive -Path $cliZip -DestinationPath $cliInstallDir -Force
    Remove-Item $cliZip
    Write-Host "Arduino CLI v$latestVersion installed to $cliInstallDir"
}

# Add CLI to current session PATH
$env:Path += ";$cliInstallDir"

# Persist to user PATH if not already present
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $oldPath.Contains($cliInstallDir)) {
    [Environment]::SetEnvironmentVariable("Path", "$oldPath;$cliInstallDir", "User")
    Write-Host "Added Arduino CLI to user PATH"
}

# Ensure arduino-cli.yaml exists and includes RP2040 index URL
$configPath = "$env:USERPROFILE\.arduino15\arduino-cli.yaml"
if (-not (Test-Path $configPath)) {
    & "$cliExe" config init --additional-urls $coreURL
} else {
    if (-not (Select-String -Path $configPath -Pattern [regex]::Escape($coreURL) -Quiet)) {
        Add-Content -Path $configPath -Value "`nboard_manager:`n  additional_urls:`n    - $coreURL"
        Write-Host "Added RP2040 core URL to CLI config"
    }
}

# Check if RP2040 core is already installed
$coreList = & "$cliExe" core list --format json | ConvertFrom-Json
$coreInstalled = $coreList | Where-Object { $_.ID -eq $coreIdentifier }

if ($null -ne $coreInstalled) {
    Write-Host "RP2040 core is already installed (v$coreInstalled.Version)"
} else {
    & "$cliExe" core update-index
    & "$cliExe" core install $coreIdentifier
    Write-Host "RP2040 core installed successfully"
}

Write-Host ""
Write-Host "Setup complete. Arduino CLI v$latestVersion and RP2040 core are ready."

#######################################Section 2: intalling Octave CLI#########################################################

# Configuration
$octaveBaseDir = "C:\Program Files\GNU Octave"
$octaveVersion = "10.2.0"  # Change this if you want a fixed version, or detect dynamically
$octaveInstallDir = Join-Path $octaveBaseDir "Octave-$octaveVersion"
$octaveBinPath = Join-Path $octaveInstallDir "mingw64\bin"
$octaveExe = Join-Path $octaveBinPath "octave-cli.exe"
$octaveBaseUrl = "https://ftp.gnu.org/gnu/octave/windows"
$tempDownload = "$env:TEMP\octave-installer.exe"

# Helper: Get latest version from GNU Octave FTP (optional)
function Get-LatestOctaveVersion {
    try {
        $html = Invoke-RestMethod -Uri $octaveBaseUrl
        $matches = ($html -split "`n") -match 'octave-[0-9]+\.[0-9]+\.[0-9]+-w64-installer\.exe'
        $versions = $matches | ForEach-Object {
            if ($_ -match "octave-([0-9]+\.[0-9]+\.[0-9]+)-w64-installer\.exe") {
                [Version]$Matches[1]
            }
        }
        return $versions | Sort-Object -Descending | Select-Object -First 1
    } catch {
        Write-Error "Failed to fetch latest Octave version info."
        return $null
    }
}

# Helper: Get installed version by reading the version from octave-cli.exe
function Get-InstalledOctaveVersion {
    if (-not (Test-Path $octaveExe)) {
        return $null
    }
    try {
        $output = & "$octaveExe" --version 2>$null
        if ($output -match "GNU Octave, version ([0-9]+\.[0-9]+\.[0-9]+)") {
            return [Version]$Matches[1]
        }
    } catch {
        return $null
    }
}

# Optionally override fixed version with latest
$latestVersion = Get-LatestOctaveVersion
if ($latestVersion) {
    if ([Version]$octaveVersion -lt $latestVersion) {
        Write-Host "Newer Octave version available: $latestVersion. Updating installer version."
        $octaveVersion = $latestVersion.ToString()
        $octaveInstallDir = Join-Path $octaveBaseDir "Octave-$octaveVersion"
        $octaveBinPath = Join-Path $octaveInstallDir "mingw64\bin"
        $octaveExe = Join-Path $octaveBinPath "octave-cli.exe"
    }
} else {
    Write-Warning "Could not determine latest Octave version; proceeding with fixed version $octaveVersion"
}

$installedVersion = Get-InstalledOctaveVersion

if ($installedVersion -and $installedVersion -eq [Version]$octaveVersion) {
    Write-Host "Octave is already installed and up to date (v$installedVersion)"
} else {
    if ($installedVersion) {
        Write-Host "Updating Octave from v$installedVersion to v$octaveVersion"
    } else {
        Write-Host "Installing Octave v$octaveVersion"
    }

    $installerName = "octave-$octaveVersion-w64-installer.exe"
    $installerUrl = "$octaveBaseUrl/$installerName"

    Write-Host "Downloading $installerUrl ..."
    Invoke-WebRequest -Uri $installerUrl -OutFile $tempDownload

    # Silent install system-wide (requires admin) - will install to default location
    # /S = silent, /D= install directory (no quotes)
    # Installer defaults to C:\Program Files\GNU Octave\Octave-x.y.z anyway,
    # so we don't strictly need /D here unless changing version manually.
    Write-Host "Running silent installer (requires admin)..."
    Start-Process -FilePath $tempDownload -ArgumentList "/S /D=C:\Program Files\GNU Octave\Octave-$octaveVersion" -Wait -Verb RunAs

    Remove-Item $tempDownload -Force

    Write-Host "Octave v$octaveVersion installed to $octaveInstallDir"
}

# Add Octave bin to user PATH if not already present
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $oldPath.Contains($octaveBinPath)) {
    [Environment]::SetEnvironmentVariable("Path", "$oldPath;$octaveBinPath", "User")
    Write-Host "Added Octave mingw64\bin to user PATH"
} else {
    Write-Host "Octave mingw64\bin path already present in user PATH"
}

Write-Host ""
Write-Host "Setup complete. You can now run 'octave-cli' from PowerShell or CMD."
Write-Host "Example usage:"
Write-Host "  & octave-cli --quiet --eval \"run('Make_header_from_saves.m')\""

#######################################Section 3: Compiling the project########################################################

# Set strict error handling
$ErrorActionPreference = "Stop"

# Path to Octave CLI binary
$octavePath = "C:\Program Files\GNU Octave\Octave-10.2.0\mingw64\bin"
$env:Path += ";$octavePath"

# Paths
$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$inoFile = "$projectDir\Pico_slide_show.ino"
$octaveScript = "$projectDir\Make_header_from_saves.m"
$outFolder = "$projectDir\build"

# Run the Octave preprocessing script
Write-Host "Running Octave script: Make_header_from_saves.m"
& octave-cli --quiet --eval "run('$octaveScript')"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Octave script failed. Aborting build."
    exit 1
}

# Correct FQBN for Raspberry Pi Pico with 50 MHz clock
$boardFqbn = "rp2040:rp2040:rpipico:freq=50"

# Compile
Write-Host "Compiling Arduino sketch with 50 MHz clock..."
$compileResult = & arduino-cli compile `
    --fqbn $boardFqbn `
    --build-path $outFolder `
    "$inoFile" 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Error "Compilation failed. Arduino CLI said:`n$compileResult"
    exit 1
}

# Check for UF2
$uf2File = Get-ChildItem -Path "$outFolder" -Filter *.uf2 -Recurse | Select-Object -First 1

if ($uf2File) {
    Write-Host "^_^ Build successful! UF2 file generated:"
    Write-Host $uf2File.FullName
} else {
    Write-Warning "Build succeeded but no UF2 file found."
}

# Look for the RPI-RP2 drive (volume label used by Pico in bootloader mode)
$picoDrive = Get-Volume | Where-Object { $_.FileSystemLabel -eq "RPI-RP2" }

if ($picoDrive) {
    $destination = "$($picoDrive.DriveLetter):\$(Split-Path -Leaf $uf2File.FullName)"
    Write-Host "Uploading UF2 file to $($picoDrive.DriveLetter): drive..."
    Copy-Item -Path $uf2File.FullName -Destination $destination -Force
    Write-Host "^_^ Upload complete."
} else {
    Write-Warning "Pico not found in BOOTSEL mode (RPI-RP2). Please press BOOTSEL and reconnect the board."
}
