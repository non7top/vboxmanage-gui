# Test-VBoxGUI.ps1
# Test script for VirtualBox Disk Image Manager GUI

Write-Host "Testing VirtualBox Disk Image Manager GUI" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Test 1: Check if required files exist
Write-Host "`nTest 1: Checking required files..." -ForegroundColor Cyan

$requiredFiles = @(
    "VirtualBoxGUI.ps1",
    "Modules\VBoxCommands.ps1",
    "Modules\GUIComponents.ps1",
    "Modules\AdvancedFeatures.ps1",
    "README.md",
    "Install-App.ps1"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        Write-Host "  ✓ $file exists" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $file missing" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if ($allFilesExist) {
    Write-Host "  All required files present" -ForegroundColor Green
} else {
    Write-Host "  Some files are missing!" -ForegroundColor Red
    return
}

# Test 2: Check if PowerShell modules can be imported without errors
Write-Host "`nTest 2: Testing module imports..." -ForegroundColor Cyan

try {
    . "$PSScriptRoot\Modules\VBoxCommands.ps1"
    Write-Host "  ✓ VBoxCommands module loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ VBoxCommands module failed to load: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    . "$PSScriptRoot\Modules\GUIComponents.ps1"
    Write-Host "  ✓ GUIComponents module loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ GUIComponents module failed to load: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    . "$PSScriptRoot\Modules\AdvancedFeatures.ps1"
    Write-Host "  ✓ AdvancedFeatures module loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "  ✗ AdvancedFeatures module failed to load: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Check if VBoxManage is available
Write-Host "`nTest 3: Checking VBoxManage availability..." -ForegroundColor Cyan

$vboxAvailable = Get-Command vboxmanage.exe -ErrorAction SilentlyContinue
if ($vboxAvailable) {
    Write-Host "  ✓ VBoxManage is available" -ForegroundColor Green
    $versionResult = & vboxmanage --version
    Write-Host "  VirtualBox version: $versionResult" -ForegroundColor Yellow
} else {
    Write-Host "  ⚠ VBoxManage not found (this is expected if VirtualBox is not installed)" -ForegroundColor Yellow
}

# Test 4: Check function definitions
Write-Host "`nTest 4: Checking function definitions..." -ForegroundColor Cyan

$expectedFunctions = @(
    "Invoke-VBoxCommand",
    "Get-VBoxDiskImages",
    "Convert-VBoxImage",
    "Resize-VBoxImage",
    "Create-VBoxImage",
    "Compact-VBoxImage",
    "Clone-VBoxImage",
    "Get-VBoxInfo",
    "Get-VBoxSupportedFormats",
    "Repair-VBoxImage",
    "Encrypt-VBoxImage",
    "Unlock-VBoxImage"
)

$missingFunctions = @()
foreach ($func in $expectedFunctions) {
    if (Get-Command $func -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ Function $func exists" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Function $func missing" -ForegroundColor Red
        $missingFunctions += $func
    }
}

if ($missingFunctions.Count -eq 0) {
    Write-Host "  All expected functions are defined" -ForegroundColor Green
} else {
    Write-Host "  Missing functions: $($missingFunctions -join ', ')" -ForegroundColor Red
}

# Test 5: Check GUI components
Write-Host "`nTest 5: Checking GUI components..." -ForegroundColor Cyan

$expectedGUICmdlets = @(
    "Initialize-MainForm",
    "Initialize-ConvertTab",
    "Initialize-ManageTab",
    "Initialize-CreateTab",
    "Initialize-AdvancedTab"
)

$missingGUIComponents = @()
foreach ($cmdlet in $expectedGUICmdlets) {
    if (Get-Command $cmdlet -ErrorAction SilentlyContinue) {
        Write-Host "  ✓ GUI component $cmdlet exists" -ForegroundColor Green
    } else {
        Write-Host "  ✗ GUI component $cmdlet missing" -ForegroundColor Red
        $missingGUIComponents += $cmdlet
    }
}

if ($missingGUIComponents.Count -eq 0) {
    Write-Host "  All expected GUI components are defined" -ForegroundColor Green
} else {
    Write-Host "  Missing GUI components: $($missingGUIComponents -join ', ')" -ForegroundColor Red
}

# Summary
Write-Host "`nTest Summary:" -ForegroundColor Cyan
Write-Host "=============" -ForegroundColor Cyan
Write-Host "Application structure: " -NoNewline

if ($allFilesExist -and $missingFunctions.Count -eq 0 -and $missingGUIComponents.Count -eq 0) {
    Write-Host "COMPLETE" -ForegroundColor Green -BackgroundColor Black
    Write-Host "All components are properly implemented!" -ForegroundColor Green
    Write-Host "`nTo run the application, execute: .\VirtualBoxGUI.ps1" -ForegroundColor Yellow
} else {
    Write-Host "INCOMPLETE" -ForegroundColor Red -BackgroundColor Black
    Write-Host "Some components need attention." -ForegroundColor Red
}

Write-Host "`nTesting completed." -ForegroundColor Green
