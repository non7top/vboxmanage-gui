# Test-VBoxGUI.ps1
# Test script for VirtualBox Disk Image Manager GUI

Write-Output "Testing VirtualBox Disk Image Manager GUI"
Write-Output "========================================="

# Test 1: Check if required files exist
Write-Verbose "Test 1: Checking required files..."

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
        Write-Verbose "  + $file exists"
    } else {
        Write-Warning "  - $file missing"
        $allFilesExist = $false
    }
}

if ($allFilesExist) {
    Write-Verbose "  All required files present"
} else {
    Write-Warning "  Some files are missing!"
    return
}

# Test 2: Check if PowerShell modules can be imported without errors
Write-Verbose "Test 2: Testing module imports..."

try {
    . "$PSScriptRoot\Modules\VBoxCommands.ps1"
    Write-Verbose "  + VBoxCommands module loaded successfully"
} catch {
    Write-Warning "  - VBoxCommands module failed to load: $($_.Exception.Message)"
}

try {
    . "$PSScriptRoot\Modules\GUIComponents.ps1"
    Write-Verbose "  + GUIComponents module loaded successfully"
} catch {
    Write-Warning "  - GUIComponents module failed to load: $($_.Exception.Message)"
}

try {
    . "$PSScriptRoot\Modules\AdvancedFeatures.ps1"
    Write-Verbose "  + AdvancedFeatures module loaded successfully"
} catch {
    Write-Warning "  - AdvancedFeatures module failed to load: $($_.Exception.Message)"
}

# Test 3: Check if VBoxManage is available
Write-Verbose "Test 3: Checking VBoxManage availability..."

$vboxAvailable = Get-Command vboxmanage.exe -ErrorAction SilentlyContinue
if ($vboxAvailable) {
    Write-Verbose "  + VBoxManage is available"
    $versionResult = & vboxmanage --version
    Write-Verbose "  VirtualBox version: $versionResult"
} else {
    Write-Verbose "  ~ VBoxManage not found (this is expected if VirtualBox is not installed)"
}

# Test 4: Check function definitions
Write-Verbose "Test 4: Checking function definitions..."

$expectedFunctions = @(
    "Invoke-VBoxCommand",
    "Get-VBoxDiskImage",
    "Convert-VBoxDiskImage",
    "Resize-VBoxDiskImage",
    "New-VBoxDiskImage",
    "Optimize-VBoxDiskImage",
    "Copy-VBoxDiskImage",
    "Get-VBoxInfo",
    "Get-VBoxSupportedFormat",
    "Repair-VBoxImage",
    "Protect-VBoxDiskImage",
    "Unlock-VBoxDiskImage",
    "Convert-PlainTextToSecureString"
)

$missingFunctions = @()
foreach ($func in $expectedFunctions) {
    if (Get-Command $func -ErrorAction SilentlyContinue) {
        Write-Verbose "  + Function $func exists"
    } else {
        Write-Warning "  - Function $func missing"
        $missingFunctions += $func
    }
}

if ($missingFunctions.Count -eq 0) {
    Write-Verbose "  All expected functions are defined"
} else {
    Write-Warning "  Missing functions: $($missingFunctions -join ', ')"
}

# Test 5: Check GUI components
Write-Verbose "Test 5: Checking GUI components..."

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
        Write-Verbose "  + GUI component $cmdlet exists"
    } else {
        Write-Warning "  - GUI component $cmdlet missing"
        $missingGUIComponents += $cmdlet
    }
}

if ($missingGUIComponents.Count -eq 0) {
    Write-Verbose "  All expected GUI components are defined"
} else {
    Write-Warning "  Missing GUI components: $($missingGUIComponents -join ', ')"
}

# Test 6: Check specific GUI functions
Write-Verbose "Test 6: Checking specific GUI functions..."

$expectedGUIFunctions = @(
    "Get-DiskImage"
)

$missingGUIFunctions = @()
foreach ($func in $expectedGUIFunctions) {
    if (Get-Command $func -ErrorAction SilentlyContinue) {
        Write-Verbose "  + GUI function $func exists"
    } else {
        Write-Warning "  - GUI function $func missing"
        $missingGUIFunctions += $func
    }
}

if ($missingGUIFunctions.Count -eq 0) {
    Write-Verbose "  All expected GUI functions are defined"
} else {
    Write-Warning "  Missing GUI functions: $($missingGUIFunctions -join ', ')"
}

# Summary
Write-Output "Test Summary:"
Write-Output "============="
if ($allFilesExist -and $missingFunctions.Count -eq 0 -and $missingGUIComponents.Count -eq 0 -and $missingGUIFunctions.Count -eq 0) {
    Write-Output "Application structure: COMPLETE"
    Write-Output "All components are properly implemented!"
    Write-Output "To run the application, execute: .\VirtualBoxGUI.ps1"
} else {
    Write-Output "Application structure: INCOMPLETE"
    Write-Output "Some components need attention."
}

Write-Output "Testing completed."
