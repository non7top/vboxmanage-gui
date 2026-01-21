# VirtualBox Disk Image Manager GUI
# Main application file

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "VirtualBox Disk Image Manager"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.MinimizeBox = $false

try {
    # Import other modules
    . "$PSScriptRoot\Modules\VBoxCommands.ps1"
    . "$PSScriptRoot\Modules\GUIComponents.ps1"
    . "$PSScriptRoot\Modules\AdvancedFeatures.ps1"
} catch {
    [System.Windows.Forms.MessageBox]::Show("Error initializing application: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    return
}

# Create the main GUI
Initialize-MainForm -Form $form

# Show the form
$form.ShowDialog()
