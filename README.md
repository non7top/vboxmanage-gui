[![PowerShell Quality Checks](https://github.com/non7top/vboxmanage-gui/actions/workflows/powershell-quality-checks.yml/badge.svg)](https://github.com/non7top/vboxmanage-gui/actions/workflows/powershell-quality-checks.yml)
# VirtualBox Disk Image Manager GUI

A Windows Forms GUI application for managing and converting VirtualBox disk images using PowerShell.

## Features

- **Convert Disk Images**: Convert between VDI, VMDK, VHD, and RAW formats
- **Manage Disk Images**: View, compact, and resize existing disk images
- **Create Disk Images**: Create new virtual disk images with specified size and format
- **Advanced Operations**: Encrypt disk images and view detailed disk information

## Requirements

- Windows OS
- VirtualBox installed (the application will check standard installation paths)
- PowerShell 3.0 or later

## Usage

1. Ensure VirtualBox is installed
2. Run the application using PowerShell:
   ```powershell
   .\VirtualBoxGUI.ps1
   ```

Or use the installation script:
   ```powershell
   .\Install-App.ps1
   ```

## Functionality

### Convert Images Tab
- Select source and destination disk image files with improved file dialogs
- Choose output format (VDI, VMDK, VHD, RAW)
- Option to compact image after conversion
- Auto-suggest destination filename based on source
- Real-time format change updates destination extension
- Convert disk images with progress indication

### Manage Images Tab
- View all registered disk images
- Compact disk images to reclaim space
- Resize existing disk images

### Create Image Tab
- Create new disk images with specified size and format
- Select location and format for new disk image

### Advanced Tab
- Encrypt disk images with AES-256-XTS or AES-128-XTS
- View detailed disk image information

## Architecture

The application is organized into modules:

- `VirtualBoxGUI.ps1`: Main application entry point
- `Modules/VBoxCommands.ps1`: VBoxManage command wrappers with automatic path detection (includes functions like Convert-VBoxDiskImage, New-VBoxDiskImage, Optimize-VBoxDiskImage, etc.)
- `Modules/GUIComponents.ps1`: Windows Forms GUI components
- `Modules/AdvancedFeatures.ps1`: Advanced disk management features
