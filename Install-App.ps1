# Install-App.ps1
# Script to install and run the VirtualBox Disk Image Manager

Write-Host "VirtualBox Disk Image Manager Setup" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green

# Check if running on Windows
if ($env:OS -ne "Windows_NT") {
    Write-Host "This application is designed to run on Windows only." -ForegroundColor Red
    return
}

# Check if VirtualBox is installed
$vboxInstalled = Get-Command vboxmanage.exe -ErrorAction SilentlyContinue
if (-not $vboxInstalled) {
    Write-Host "VirtualBox is not installed or VBoxManage.exe is not in PATH." -ForegroundColor Red
    Write-Host "Please install VirtualBox from https://www.virtualbox.org/" -ForegroundColor Yellow
    return
}

Write-Host "VirtualBox installation detected." -ForegroundColor Green

# Run the application
Write-Host "Starting VirtualBox Disk Image Manager..." -ForegroundColor Green
Start-Process powershell.exe -ArgumentList "-ExecutionPolicy", "Bypass", "-File", "$PSScriptRoot\VirtualBoxGUI.ps1"
