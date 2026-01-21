# Install-App.ps1
# Script to install and run the VirtualBox Disk Image Manager

Write-Output "VirtualBox Disk Image Manager Setup"
Write-Output "==================================="

# Check if running on Windows
if ($env:OS -ne "Windows_NT") {
    Write-Warning "This application is designed to run on Windows only."
    return
}

# Check if VirtualBox is installed
$vboxInstalled = Get-Command vboxmanage.exe -ErrorAction SilentlyContinue
if (-not $vboxInstalled) {
    Write-Warning "VirtualBox is not installed or VBoxManage.exe is not in PATH."
    Write-Output "Please install VirtualBox from https://www.virtualbox.org/"
    return
}

Write-Output "VirtualBox installation detected."

# Run the application
Write-Output "Starting VirtualBox Disk Image Manager..."
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "$PSScriptRoot\VirtualBoxGUI.ps1"
