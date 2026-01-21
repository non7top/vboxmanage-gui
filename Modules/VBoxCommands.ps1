# VBoxCommands.ps1
# Module for handling VBoxManage commands

# Find VBoxManage executable in standard paths
function Get-VBoxManagePath {
    # Standard installation paths for VirtualBox
    $standardPaths = @(
        "${env:ProgramFiles}\Oracle\VirtualBox\vboxmanage.exe",
        "${env:ProgramFiles(x86)}\Oracle\VirtualBox\vboxmanage.exe",
        "${env:ProgramW6432}\Oracle\VirtualBox\vboxmanage.exe",
        "${env:USERPROFILE}\AppData\Local\Programs\Oracle\VirtualBox\vboxmanage.exe",
        "C:\Program Files\Oracle\VirtualBox\vboxmanage.exe",
        "C:\Program Files (x86)\Oracle\VirtualBox\vboxmanage.exe"
    )

    # First, check if it's in PATH
    $inPath = Get-Command vboxmanage.exe -ErrorAction SilentlyContinue
    if ($inPath) {
        return $inPath.Path
    }

    # Then check standard installation paths
    foreach ($path in $standardPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

$vboxManagePath = Get-VBoxManagePath

if (-not $vboxManagePath) {
    throw "VirtualBox installation not found. Please install VirtualBox from https://www.virtualbox.org/"
}

function Invoke-VBoxCommand {
    param(
        [string]$Arguments
    )

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $vboxManagePath
        $psi.Arguments = $Arguments
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $process = [System.Diagnostics.Process]::Start($psi)
        $output = $process.StandardOutput.ReadToEnd()
        $errorOutput = $process.StandardError.ReadToEnd()
        $process.WaitForExit()

        return @{
            ExitCode = $process.ExitCode
            Output = $output
            Error = $errorOutput
        }
    } catch {
        return @{
            ExitCode = -1
            Output = ""
            Error = $_.Exception.Message
        }
    }
}

function Get-VBoxDiskImage {
    # List all registered VMs and their attached disks
    $result = Invoke-VBoxCommand "list hdds"
    if ($result.ExitCode -eq 0) {
        $disks = @()
        $currentDisk = @{}

        foreach ($line in $result.Output -split "`n") {
            if ($line -match "^UUID:") {
                if ($currentDisk.Count -gt 0) {
                    $disks += $currentDisk
                }
                $currentDisk = @{}
                $currentDisk.UUID = ($line -split ":")[1].Trim()
            } elseif ($line -match "^Parent UUID:") {
                $currentDisk.ParentUUID = ($line -split ":")[1].Trim()
            } elseif ($line -match "^State:") {
                $currentDisk.State = ($line -split ":")[1].Trim()
            } elseif ($line -match "^Location:") {
                $currentDisk.Location = ($line -split ":")[1].Trim()
            } elseif ($line -match "^Format:") {
                $currentDisk.Format = ($line -split ":")[1].Trim()
            } elseif ($line -match "^Capacity:") {
                $currentDisk.Capacity = ($line -split ":")[1].Trim()
            } elseif ($line -match "^Type:") {
                $currentDisk.Type = ($line -split ":")[1].Trim()
            }
        }

        if ($currentDisk.Count -gt 0) {
            $disks += $currentDisk
        }

        return $disks
    } else {
        Write-Verbose "Error getting disk images: $($result.Error)"
        return @()
    }
}

function Convert-VBoxDiskImage {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Format
    )

    $arguments = "clonehd `"$Source`" `"$Destination`" --format $Format"
    return Invoke-VBoxCommand $arguments
}

function Resize-VBoxDiskImage {
    param(
        [string]$ImagePath,
        [int]$SizeMB
    )

    $arguments = "modifyhd `"$ImagePath`" --resize $SizeMB"
    return Invoke-VBoxCommand $arguments
}

function New-VBoxDiskImage {
    param(
        [string]$Path,
        [string]$Format,
        [int]$SizeMB
    )

    $arguments = "createhd --filename `"$Path`" --format $Format --size $SizeMB"
    return Invoke-VBoxCommand $arguments
}

function Optimize-VBoxDiskImage {
    param(
        [string]$ImagePath
    )

    $arguments = "modifyhd `"$ImagePath`" --compact"
    return Invoke-VBoxCommand $arguments
}

function Copy-VBoxDiskImage {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Format = "VDI"
    )

    $arguments = "clonehd `"$Source`" `"$Destination`" --format $Format"
    return Invoke-VBoxCommand $arguments
}

function Get-VBoxInfo {
    param(
        [string]$ImagePath
    )

    $arguments = "showhdinfo `"$ImagePath`""
    return Invoke-VBoxCommand $arguments
}

function Get-VBoxSupportedFormat {
    # Get information about supported disk formats
    $result = Invoke-VBoxCommand "list systeminfo"
    if ($result.ExitCode -eq 0) {
        # Extract supported formats from system info
        $supportedFormats = @()
        $inFormatsSection = $false

        foreach ($line in $result.Output -split "`n") {
            if ($line -match "Supported.*formats") {
                $inFormatsSection = $true
            } elseif ($inFormatsSection -and $line -match "^\s+") {
                # Parse format information
                $formatLine = $line.Trim()
                if ($formatLine -match "^[A-Z]+") {
                    $supportedFormats += $formatLine.Split()[0]
                }
            } elseif ($inFormatsSection -and $line -match "^[^A-Z]") {
                # End of formats section
                break
            }
        }

        return $supportedFormats
    }
    return @()
}

function Repair-VBoxImage {
    param(
        [string]$ImagePath
    )

    $arguments = "modifyhd `"$ImagePath`" --resize 0"  # This triggers a repair operation
    return Invoke-VBoxCommand $arguments
}

function Protect-VBoxDiskImage {
    param(
        [string]$ImagePath,
        [SecureString]$Password,
        [string]$Cipher = "AES-256-XTS"
    )

    # Convert SecureString to plain text for VBoxManage (this is a limitation of VBoxManage)
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    try {
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        $arguments = "encryptmedium `"$ImagePath`" --password $plainPassword --cipher $Cipher"
        return Invoke-VBoxCommand $arguments
    } finally {
        [Runtime.InteropServices.Marshal]::FreeBSTR($bstr)
    }
}

function Unlock-VBoxDiskImage {
    param(
        [string]$ImagePath,
        [SecureString]$Password
    )

    # Convert SecureString to plain text for VBoxManage (this is a limitation of VBoxManage)
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    try {
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        $arguments = "closemedium disk `"$ImagePath`" --password $plainPassword"
        return Invoke-VBoxCommand $arguments
    } finally {
        [Runtime.InteropServices.Marshal]::FreeBSTR($bstr)
    }
}
