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
