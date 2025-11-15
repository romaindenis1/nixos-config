<#
Simplified WSL NixOS flake applier.

Behavior:
- Uses a builder WSL distro (Debian) to build the flake located at the repo root (to bypass windows admin)
- By default the builder distro will be unregistered after import (so Ubuntu is removed) to leave only the 'nixos' distro.

This script is intentionally single-purpose and has no CLI parameters. 
#>

Set-StrictMode -Version Latest

# --- Configuration (single-purpose) ---
$BuilderDistro = 'Debian'
$ResultDistroName = 'nixos'
$InstallDir = Join-Path $env:USERPROFILE "wsl\distros\$ResultDistroName"
$WinDownloads = Join-Path $env:USERPROFILE 'Downloads'
$WinTar = Join-Path $WinDownloads "$ResultDistroName.tar.gz"
$RemoveBuilder = $true
$ForceUseRootBuilder = $true

function Write-Info($m) { Write-Host $m }
function Log-Error($m) {
    # Write to console and log file
    Write-Error $m
    try {
        if (-not (Test-Path -Path $ErrorLog -PathType Leaf)) { New-Item -Path $ErrorLog -ItemType File -Force | Out-Null }
        $time = Get-Date -Format o
        "$time ERROR: $m" | Out-File -FilePath $ErrorLog -Append -Encoding UTF8
    } catch {
    }
}


function Test-IsAdmin {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

function Convert-WinPathToWsl($winPath) {
    $full = [System.IO.Path]::GetFullPath($winPath)
    # Normalize separators
    $full = $full -replace '\\','/'
    $drive = $full.Substring(0,1).ToLower()
    $rest = $full.Substring(2)
    if ($rest.StartsWith('/')) { $rest = $rest.Substring(1) }
    return "/mnt/$drive/$rest"
}

# Remove invisible/control characters and trim
function Clean-Name($n) {
    if ($null -eq $n) { return $null }
    try {
        $chars = $n.ToCharArray()
        $filtered = $chars | Where-Object { [int][char]$_ -ge 32 }
        $s = ($filtered -join '')
        return $s.Trim()
    } catch {
        return $n.Trim()
    }
}

# Resolve repository path (assume this script lives in repo/scripts)
try {
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $RepoWinPath = (Resolve-Path (Join-Path $ScriptDir '..')).ProviderPath
} catch {
    $RepoWinPath = $PWD.Path
}

$RepoWslPath = Convert-WinPathToWsl($RepoWinPath)

Write-Info "Repo (Windows): $RepoWinPath"
Write-Info "Repo (WSL): $RepoWslPath"

# Logs directory inside the repo (overwritten each run)
$LogDir = Join-Path $RepoWinPath 'logs'
if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Force -Path $LogDir | Out-Null }
$BuildLog = Join-Path $LogDir "$ResultDistroName-build.log"
$ErrorLog = Join-Path $LogDir "$ResultDistroName-errors.log"
if (Test-Path $BuildLog) { Remove-Item $BuildLog -Force -ErrorAction SilentlyContinue }
if (Test-Path $ErrorLog) { Remove-Item $ErrorLog -Force -ErrorAction SilentlyContinue }

$isAdmin = Test-IsAdmin
Write-Info "Running as admin: $isAdmin"

if ($isAdmin) {
    Write-Info 'Enabling WSL and VirtualMachinePlatform features (may require restart)...'
    try {
        Start-Process -FilePath dism.exe -ArgumentList '/online','/enable-feature','/featurename:Microsoft-Windows-Subsystem-Linux','/all','/norestart' -Wait -NoNewWindow
        Start-Process -FilePath dism.exe -ArgumentList '/online','/enable-feature','/featurename:VirtualMachinePlatform','/all','/norestart' -Wait -NoNewWindow
    } catch { Write-Warning "Failed to enable features: $_" }
}

if ($ForceUseRootBuilder) {
    Write-Info "Force-root-builder mode enabled; will use 'ubuntu-builder' as the builder distro."
    $BuilderDistro = 'ubuntu-builder'
    # Check if it's installed; if not, attempt to import the fallback tarball
    $installed = @()
    try { $installed = (& wsl.exe --list --quiet) -split "`n" | ForEach-Object { Clean-Name $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } } catch {}
    if (-not ($installed -contains $BuilderDistro)) {
        Write-Info "Builder distro '$BuilderDistro' not found; attempting non-admin import fallback."
        try {
            $autoName = $BuilderDistro
            $builderTar = Join-Path $WinDownloads "wsl-${autoName}-rootfs.tar.gz"
            if (-not (Test-Path -Path $builderTar)) {
                Write-Info "Downloading rootfs to $builderTar (this may be ~50-200MB)..."
                $candidates = @(
                    'https://cloud-images.ubuntu.com/releases/jammy/release/jammy-server-cloudimg-amd64-root.tar.gz',
                    'https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64-root.tar.gz',
                    'https://partner-images.canonical.com/core/jammy/current/ubuntu-jammy-core-cloudimg-amd64-root.tar.gz'
                )
                $downloaded = $false
                foreach ($u in $candidates) {
                    try { Invoke-WebRequest -Uri $u -OutFile $builderTar -UseBasicParsing -ErrorAction Stop -TimeoutSec 300; $downloaded = $true; break } catch { ("Failed to download $u -> $_") | Out-File -FilePath $BuildLog -Encoding utf8 -Append; Remove-Item -Path $builderTar -ErrorAction SilentlyContinue }
                }
                if (-not $downloaded) { throw "All candidate downloads failed. See $BuildLog for details." }
            } else { Write-Info "Found existing rootfs tarball at $builderTar, reusing it." }
            $builderInstallDir = Join-Path $env:USERPROFILE "wsl\distros\$autoName"
            if (-not (Test-Path -Path $builderInstallDir)) { New-Item -ItemType Directory -Force -Path $builderInstallDir | Out-Null }
            Write-Info "Importing downloaded rootfs as WSL distro '$autoName' (install dir: $builderInstallDir)"
            & wsl.exe --import $autoName $builderInstallDir $builderTar --version 2 2>> $BuildLog
            if ($LASTEXITCODE -ne 0) { throw "wsl --import failed with exit code $LASTEXITCODE" }
            $installed = (& wsl.exe --list --quiet) -split "`n" | ForEach-Object { Clean-Name $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
            Write-Info "Imported builder distro: $BuilderDistro"
        } catch { Log-Error "Could not create non-admin builder distro: $_"; exit 1 }
    } else {
        Write-Info "Using existing builder distro: $BuilderDistro"
    }
} else {
    Write-Info 'Checking installed WSL distributions...'
    $installed = @()
    try {
        $raw = & wsl.exe --list --quiet 2>$null
        if ($raw) { $installed = $raw -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } }
    } catch {}
    if (-not $installed -or (@($installed).Count -eq 0)) {
        try {
            $raw2 = & wsl.exe -l -v 2>$null
            if ($raw2) {
                $installed = @()
                foreach ($line in ($raw2 -split "`n")) {
                    $ln = $line.Trim()
                    if ($ln -match '^NAME\s+STATE') { continue }
                    if ($ln -eq '') { continue }
                    $m = $ln -match '^([^\s]+)\s+' ; if ($m) { $installed += $matches[1] }
                }
            }
        } catch {}
    }
    $installed = @($installed) | ForEach-Object { Clean-Name $_ } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and ($_ -notin @('docker-desktop','docker-desktop-data')) }
    try {
        "--- wsl --list --quiet raw output ---" | Out-File -FilePath $BuildLog -Encoding utf8 -Append
        if ($raw) { $raw | Out-File -FilePath $BuildLog -Encoding utf8 -Append } else { "<empty>" | Out-File -FilePath $BuildLog -Encoding utf8 -Append }
        "--- wsl -l -v raw output ---" | Out-File -FilePath $BuildLog -Encoding utf8 -Append
        if ($raw2) { $raw2 | Out-File -FilePath $BuildLog -Encoding utf8 -Append } else { "<empty>" | Out-File -FilePath $BuildLog -Encoding utf8 -Append }
        "Discovered WSL distros: [" + ($installed -join ',') + "]" | Out-File -FilePath $BuildLog -Encoding utf8 -Append
        for ($i = 0; $i -lt $installed.Count; $i++) { $entry = $installed[$i]; $len = 0; if ($entry) { $len = $entry.Length }; ("{0}: '[{1}]' (len={2})" -f $i, $entry, $len) | Out-File -FilePath $BuildLog -Encoding utf8 -Append }
    } catch {}
    if (-not $installed -or ($installed -notcontains $BuilderDistro)) {
        if ($isAdmin) {
            Write-Info "Installing builder distro '$BuilderDistro'..."
            try { wsl.exe --install -d $BuilderDistro --no-launch 2>$null; $installed = (& wsl.exe --list --quiet) -split "`n" | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } } catch { Write-Warning "Could not auto-install builder: $_" }
        } else {
            $preferred = @('Debian','Ubuntu','Arch','alpine','Fedora','opensuse-leap')
            $found = $null
            foreach ($p in $preferred) { if ($installed -contains $p) { $found = $p; break } }
            if ($found) { $old = $BuilderDistro; $BuilderDistro = $found; Write-Warning "Builder distro '$old' not found; using preferred existing distro '$BuilderDistro' as the builder." }
            elseif ($installed -and (@($installed).Count -gt 0)) { $old = $BuilderDistro; $BuilderDistro = $installed[0]; Write-Warning "Builder distro '$old' not found; using existing distro '$BuilderDistro' as the builder." } else { Log-Error "Builder distro '$BuilderDistro' not found and no other suitable WSL distributions are installed. Please install one (e.g. Ubuntu) or run this script as Administrator. Exiting."; exit 1 }
        }
    }
}

# Prepare install directory
if (-not (Test-Path -Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }
if (-not (Test-Path -Path $WinDownloads)) { New-Item -ItemType Directory -Force -Path $WinDownloads | Out-Null }

$WslTarPath = Convert-WinPathToWsl($WinTar)

Write-Info "Build tarball will be written to: $WinTar (WSL path: $WslTarPath)"
# Windows username for use inside WSL 
$winUser = $env:USERNAME

# Create the build script for the builder (bash).
$buildScript = @'
#!/usr/bin/env bash
# Be conservative: enable errexit and nounset; avoid shell options that minimal /bin/sh may not support
set -eu
echo "Installing build deps..."
# Assume we're running as root inside the imported rootfs, sudo may not exist
apt-get update -y || true
apt-get install -y curl xz-utils tar gzip || true
if ! command -v nix >/dev/null 2>&1; then
    echo "Installing Nix for build..."
    if [ "$(id -u)" -eq 0 ]; then
        if ! id builder >/dev/null 2>&1; then
            if command -v useradd >/dev/null 2>&1; then
                useradd -m builder || true
            elif command -v adduser >/dev/null 2>&1; then
                adduser --disabled-password --gecos "" builder || true
            fi
        fi
            chown -R builder:builder /home/builder 2>/dev/null || true
            # Ensure /nix exists and is writable
            if [ ! -d /nix ]; then
                mkdir -m 0755 /nix 2>/dev/null || true
            fi
            chown builder:builder /nix 2>/dev/null || true
            echo "Running Nix installer as 'builder' user..."
            su - builder -c 'curl -L https://nixos.org/nix/install | sh' || { echo "Nix installer failed as builder"; exit 1; }
        else
            curl -L https://nixos.org/nix/install | sh
            if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
                . "$HOME/.nix-profile/etc/profile.d/nix.sh"
            fi
        fi
    fi
echo "Using repo at: <<REPO_WSL_PATH>>"
ORIG_REPO="<<REPO_WSL_PATH>>"
BUILD_REPO="$ORIG_REPO"
# If we're root, copy the repo into a location owned by the builder user to avoid Git ownership issues
if [ "$(id -u)" -eq 0 ]; then
    BUILD_REPO="/home/builder/repo"
    rm -rf "$BUILD_REPO" || true
    mkdir -p "$BUILD_REPO"
    # Copy repo contents (may be on a mounted filesystem); fall back to a simple tar|tar copy if cp -a isn't available
    if command -v rsync >/dev/null 2>&1; then
        rsync -a "$ORIG_REPO/" "$BUILD_REPO/" || true
    else
        cp -a "$ORIG_REPO/." "$BUILD_REPO/" 2>/dev/null || ( tar -C "$ORIG_REPO" -cf - . | tar -C "$BUILD_REPO" -xf - )
    fi
    chown -R builder:builder "$BUILD_REPO" 2>/dev/null || true
    # Ensure the copied tree is a usable git repository 
    if command -v git >/dev/null 2>&1; then
        # initialize git if missing, configure a local user, ect
        su - builder -c "git -C \"$BUILD_REPO\" config user.email 'builder@example.local' || true"
        su - builder -c "git -C \"$BUILD_REPO\" config user.name 'builder' || true"
        if [ ! -d "$BUILD_REPO/.git" ]; then
            su - builder -c "git -C \"$BUILD_REPO\" init" || true
        fi
        su - builder -c "git -C \"$BUILD_REPO\" add -A" || true
        su - builder -c "git -C \"$BUILD_REPO\" commit -m 'local copy for build' || true" || true
    fi
fi

# Normalize copied repo and fix file:// inputs that point to the original /mnt path
if [ -d "$BUILD_REPO" ]; then
    cd "$BUILD_REPO" || { echo "Repo path not found inside builder: $BUILD_REPO"; exit 1; }
    # Remove CR characters from all files to avoid newline problemes
    find . -type f -exec sed -i 's/\r$//' {} + 2>/dev/null || true
    if [ -n "$ORIG_REPO" -a "$ORIG_REPO" != "$BUILD_REPO" ]; then
        for f in flake.nix flake.lock default.nix; do
            if [ -f "$f" ]; then
                sed -i 's|"$ORIG_REPO"|"$BUILD_REPO"|g' "$f" 2>/dev/null || true
                sed -i 's|$ORIG_REPO|$BUILD_REPO|g' "$f" 2>/dev/null || true
            fi
        done
    fi
else
    cd "$BUILD_REPO" || { echo "Repo path not found inside builder: $BUILD_REPO"; exit 1; }
fi
echo "Inspecting flake outputs..."
set +e
if [ "$(id -u)" -eq 0 ]; then
    su - builder -c ". \$HOME/.nix-profile/etc/profile.d/nix.sh; cd \"$BUILD_REPO\"; nix --extra-experimental-features 'nix-command flakes' build .#nixosConfigurations.wsl.config.system.build.tarball -o /tmp/result"
    if [ $? -ne 0 ]; then
        su - builder -c ". \$HOME/.nix-profile/etc/profile.d/nix.sh; cd \"$BUILD_REPO\"; nix --extra-experimental-features 'nix-command flakes' build .#nixosConfigurations.wsl.config.system.build.rootfs -o /tmp/result"
    fi
    if [ $? -ne 0 ]; then
        su - builder -c ". \$HOME/.nix-profile/etc/profile.d/nix.sh; cd \"$BUILD_REPO\"; nix --extra-experimental-features 'nix-command flakes' build .#nixosConfigurations.wsl.config.system.build.toplevel -o /tmp/result"
    fi
else
    nix --extra-experimental-features 'nix-command flakes' build .#nixosConfigurations.wsl.config.system.build.tarball -o /tmp/result
    if [ $? -ne 0 ]; then
        nix --extra-experimental-features 'nix-command flakes' build .#nixosConfigurations.wsl.config.system.build.rootfs -o /tmp/result
    fi
    if [ $? -ne 0 ]; then
        nix --extra-experimental-features 'nix-command flakes' build .#nixosConfigurations.wsl.config.system.build.toplevel -o /tmp/result
    fi
fi
set -e
if [ -d /tmp/result ]; then
    echo "DEBUG: /tmp listing before packing:"; ls -la /tmp || true
    echo "DEBUG: /tmp/result listing:"; ls -la /tmp/result || true
    echo "Packing build result into tarball..."
    # Ensure destination directory exists (target is a /mnt/c/... path)
    destdir=$(dirname "<<WslTar>>") || true
    if [ -n "$destdir" ]; then
        mkdir -p "$destdir" 2>/dev/null || true
    fi
    tar -C /tmp/result -cpf "<<WslTar>>" . 2>/dev/null || TAR_RC=$?
    if [ "${TAR_RC:-0}" != "0" ]; then TAR_RC=1; fi
    echo "tar exit code: $TAR_RC"
    if [ $TAR_RC -ne 0 ]; then
        echo "tar failed, attempting to create tar in /tmp and then move it"
        tar -C /tmp/result -czf /tmp/result.tar.gz . || true
        mv /tmp/result.tar.gz "<<WslTar>>" 2>/dev/null || cp /tmp/result.tar.gz "<<WslTar>>" 2>/dev/null || true
    fi
elif [ -f /tmp/result.tar.gz ]; then
    echo "Found /tmp/result.tar.gz, copying to target"
    cp /tmp/result.tar.gz "<<WslTar>>"
elif ls /tmp/result* 1>/dev/null 2>&1; then
    echo "Found /tmp/result* files, copying to target"
    cp /tmp/result* "<<WslTar>>" || true
fi

# Verify the tarball exists and print its details for debug
if [ -f "<<WslTar>>" ]; then
    echo "Tarball present at <<WslTar>>:"; ls -la "<<WslTar>>" || true
    echo "File type and summary:"; file "<<WslTar>>" || true
else
    echo "Tarball NOT present at <<WslTar>> after attempted packaging"
fi
echo "Build finished, tarball placed at <<WslTar>>"
'@

$buildScript = $buildScript -replace '<<REPO_WSL_PATH>>', [Regex]::Escape($RepoWslPath)
$buildScript = $buildScript -replace '<<WslTar>>', $WslTarPath

# Write build script to temp file (Windows path) and execute it inside the builder
$tmpScript = Join-Path $env:TEMP "nixos-flake-build.sh"
Set-Content -Path $tmpScript -Value $buildScript -Encoding UTF8

Write-Info "Streaming build script into builder and running..."
try {
    # Ensure builder name != null
    if ([string]::IsNullOrWhiteSpace($BuilderDistro)) { Log-Error "Builder distro name is empty; cannot invoke wsl."; exit 1 }

    if (-not ($installed -contains $BuilderDistro)) {
        if ($installed -and (@($installed).Count -gt 0)) {
            $old = $BuilderDistro
            $BuilderDistro = $installed | Select-Object -First 1
            Write-Warning "Selected builder '$old' was not found in discovered distros; falling back to '$BuilderDistro'."
        } else {
            Log-Error "No available WSL distribution to use as builder. Discovered list: [" + ($installed -join ',') + "]"
            exit 1
        }
    }

    # When creating the script inside WSL, sanitize CRs on the WSL side before execution to avoid $'\r' problemes
    $args = @('--distribution', $BuilderDistro, '--', 'bash', '-lc', "cat > /tmp/nixos-flake-build.sh && chmod +x /tmp/nixos-flake-build.sh && sed -i 's/\r$//' /tmp/nixos-flake-build.sh 2>/dev/null || true && bash /tmp/nixos-flake-build.sh")

    # Log the exact arguments to the build log for debugging
    ("wsl.exe " + ($args -join ' ')) | Out-File -FilePath $BuildLog -Encoding utf8 -Append

    $scriptContent = Get-Content -Raw -Encoding UTF8 $tmpScript
    # Remove any BOM and normalize line endings to LF to avoid /bin/sh parsing issues inside minimal rootfs
    $scriptContent = $scriptContent.TrimStart([char]0xFEFF)
    $scriptContent = $scriptContent -replace "`r",""

    # Pipe the script into wsl.exe; capture stdout/stderr merged
    $output = $scriptContent | & wsl.exe @args 2>&1
    $exit = $LASTEXITCODE

    # Normalize line endings to CRLF for Windows readability and write as UTF8
    if ($output -is [System.Array]) { $outStr = $output -join "`n" } else { $outStr = [string]$output }
    $outStr = $outStr -replace "`r?`n", "`r`n"
    $outStr | Out-File -FilePath $BuildLog -Encoding utf8 -Append

    if ($exit -ne 0) {
        Get-Content -Path $BuildLog -Tail 200 | ForEach-Object { Write-Host $_ }
        exit 1
    }

} catch {
    Log-Error "Build script invocation failed: $_"
    exit 1
}

try {
    $wslCmd = "ls -l '$WslTarPath' || echo MISSING; echo '--- /tmp listing ---'; ls -la /tmp || true; echo '--- /mnt/c/Downloads listing ---'; ls -la /mnt/c/Users/$winUser/Downloads || true"
    $args = @('--distribution', $BuilderDistro, '--', 'sh', '-c', $wslCmd)
    ("WSL-side tarball check args: " + ($args -join ' ')) | Out-File -FilePath $BuildLog -Encoding utf8 -Append
    $wslOut = & wsl.exe @args 2>&1
    if ($wslOut -is [System.Array]) { $wslOutStr = $wslOut -join "`n" } else { $wslOutStr = [string]$wslOut }
    $wslOutStr = $wslOutStr -replace "`r?`n", "`r`n"
    $wslOutStr | Out-File -FilePath $BuildLog -Encoding utf8 -Append
} catch {
    ("Failed to run WSL-side tarball check: $_") | Out-File -FilePath $BuildLog -Encoding utf8 -Append
}

$found = $false
for ($i = 0; $i -lt 20; $i++) {
    if (Test-Path -Path $WinTar) { $found = $true; break }
    Start-Sleep -Seconds 1
}
if (-not $found) {
    Log-Error "Expected tarball at $WinTar but it was not created. See $BuildLog for WSL-side diagnostics."
    # Dump the last lines for logs
    try { Get-Content -Path $BuildLog -Tail 200 | ForEach-Object { Write-Host $_ } } catch {}
    exit 1
}

Write-Info "Importing tarball into WSL as distro '$ResultDistroName' (install dir: $InstallDir)"
try {
    wsl.exe --import $ResultDistroName $InstallDir $WinTar --version 2
    Write-Info "Imported distro '$ResultDistroName'."
} catch {
    Log-Error "Failed to import distro: $_"
    exit 1
}

if ($RemoveBuilder) {
    Write-Info "Unregistering builder distro '$BuilderDistro'..."
    try { wsl.exe --unregister $BuilderDistro } catch { Write-Warning "Failed to unregister builder: $_" }
}

Write-Info "Done. You can enter the new distro with: wsl -d $ResultDistroName"
