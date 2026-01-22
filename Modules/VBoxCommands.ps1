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

        # Log the command and results for debugging
        Write-Verbose "VBoxManage Command: $vboxManagePath $Arguments"
        if ($errorOutput) {
            Write-Verbose "VBoxManage Error: $errorOutput"
        }
        if ($output -and $process.ExitCode -eq 0) {
            Write-Verbose "VBoxManage Output: $output"
        }

        return @{
            ExitCode = $process.ExitCode
            Output = $output
            Error = $errorOutput
        }
    } catch {
        $errorMessage = $_.Exception.Message
        Write-Verbose "VBoxManage Exception: $errorMessage"
        return @{
            ExitCode = -1
            Output = ""
            Error = $errorMessage
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

    # Check if destination file exists
    $destinationExists = Test-Path $Destination

    if ($destinationExists) {
        # Try to find and unregister the existing disk from VirtualBox
        $allDisksResult = Invoke-VBoxCommand "list hdds"
        if ($allDisksResult.ExitCode -eq 0) {
            # Look for our destination file in the list of registered disks
            $lines = $allDisksResult.Output -split "`n"
            $currentDisk = @{}
            $targetDiskUUID = $null

            foreach ($line in $lines) {
                if ($line -match "^UUID:") {
                    if ($currentDisk.Path -and $currentDisk.Path -eq $Destination) {
                        $targetDiskUUID = $currentDisk.UUID
                        break
                    }
                    $currentDisk = @{}
                    $currentDisk.UUID = ($line -split ":")[1].Trim()
                } elseif ($line -match "^Location:") {
                    $currentDisk.Path = ($line -split ":")[1].Trim()
                }
            }

            # Check if the last disk in the list matches our destination
            if (-not $targetDiskUUID -and $currentDisk.Path -and $currentDisk.Path -eq $Destination) {
                $targetDiskUUID = $currentDisk.UUID
            }

            # If we found the UUID, unregister the disk from VirtualBox
            if ($targetDiskUUID) {
                $unregisterResult = Invoke-VBoxCommand "closemedium disk `"$targetDiskUUID`" --delete"
            }
        }

        # Remove the file anyway
        try {
            Remove-Item -Path $Destination -Force
        } catch {
            return @{
                ExitCode = 1
                Output = ""
                Error = "Could not remove existing file: $($_.Exception.Message)"
            }
        }
    }

    # Use a temporary file name to avoid UUID conflicts
    $tempDestination = $Destination
    if ($destinationExists) {
        $destDir = Split-Path $Destination -Parent
        $destName = [System.IO.Path]::GetFileNameWithoutExtension($Destination)
        $destExt = [System.IO.Path]::GetExtension($Destination)
        $tempDestination = Join-Path $destDir "$destName-temp$destExt"
    }

    # Perform the clone operation to the temporary file
    $arguments = "clonemedium `"$Source`" `"$tempDestination`" --format $Format"
    $result = Invoke-VBoxCommand $arguments

    # If we used a temporary file, move it to the final destination
    if ($result.ExitCode -eq 0 -and $destinationExists) {
        # Unregister the temporary disk if it got registered
        $tempDisksResult = Invoke-VBoxCommand "list hdds"
        if ($tempDisksResult.ExitCode -eq 0) {
            $lines = $tempDisksResult.Output -split "`n"
            $currentDisk = @{}
            $tempDiskUUID = $null

            foreach ($line in $lines) {
                if ($line -match "^UUID:") {
                    if ($currentDisk.Path -and $currentDisk.Path -eq $tempDestination) {
                        $tempDiskUUID = $currentDisk.UUID
                        break
                    }
                    $currentDisk = @{}
                    $currentDisk.UUID = ($line -split ":")[1].Trim()
                } elseif ($line -match "^Location:") {
                    $currentDisk.Path = ($line -split ":")[1].Trim()
                }
            }

            # Check if the last disk in the list matches our temp destination
            if (-not $tempDiskUUID -and $currentDisk.Path -and $currentDisk.Path -eq $tempDestination) {
                $tempDiskUUID = $currentDisk.UUID
            }

            # If we found the temp disk UUID, unregister it
            if ($tempDiskUUID) {
                Invoke-VBoxCommand "closemedium disk `"$tempDiskUUID`" --delete" | Out-Null
            }
        }

        # Remove the original destination if it exists (shouldn't anymore, but just in case)
        if (Test-Path $Destination) {
            Remove-Item -Path $Destination -Force
        }

        # Move the temp file to the final destination
        Move-Item -Path $tempDestination -Force -Destination $Destination
    }

    return $result
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
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$Path,
        [string]$Format,
        [int]$SizeMB
    )

    # Check if destination file exists
    if (Test-Path $Path) {
        if ($PSCmdlet.ShouldProcess("Existing disk image at $Path", "Overwrite")) {
            # Remove the existing file first
            Remove-Item -Path $Path -Force
            $arguments = "createhd --filename `"$Path`" --format $Format --size $SizeMB"
            return Invoke-VBoxCommand $arguments
        } else {
            # Return an error indicating the file exists
            return @{
                ExitCode = 1
                Output = ""
                Error = "File already exists: $Path"
            }
        }
    } else {
        $arguments = "createhd --filename `"$Path`" --format $Format --size $SizeMB"

        if ($PSCmdlet.ShouldProcess("Disk image at $Path", "Create")) {
            return Invoke-VBoxCommand $arguments
        }
    }
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
