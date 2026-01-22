# GUIComponents.ps1
# Module for GUI components and layout

function Initialize-MainForm {
    param(
        [System.Windows.Forms.Form]$Form
    )

    # Create tab control for different operations
    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Location = New-Object System.Drawing.Point(10, 10)
    $tabControl.Size = New-Object System.Drawing.Size(760, 530)

    # Create tabs
    $convertTab = New-Object System.Windows.Forms.TabPage
    $convertTab.Text = "Convert Images"
    $manageTab = New-Object System.Windows.Forms.TabPage
    $manageTab.Text = "Manage Images"
    $createTab = New-Object System.Windows.Forms.TabPage
    $createTab.Text = "Create Image"
    $advancedTab = New-Object System.Windows.Forms.TabPage
    $advancedTab.Text = "Advanced"

    # Add tabs to tab control
    $tabControl.TabPages.Add($convertTab)
    $tabControl.TabPages.Add($manageTab)
    $tabControl.TabPages.Add($createTab)
    $tabControl.TabPages.Add($advancedTab)

    # Initialize each tab
    Initialize-ConvertTab -TabPage $convertTab
    Initialize-ManageTab -TabPage $manageTab
    Initialize-CreateTab -TabPage $createTab
    Initialize-AdvancedTab -TabPage $advancedTab

    # Add tab control to form
    $Form.Controls.Add($tabControl)
}

function Initialize-ConvertTab {
    param(
        [System.Windows.Forms.TabPage]$TabPage
    )

    # Store the TabPage in script scope to make it accessible in event handlers
    $Script:convertTabPage = $TabPage

    # Source file selection
    $Script:sourceLabel = New-Object System.Windows.Forms.Label
    $Script:sourceLabel.Location = New-Object System.Drawing.Point(20, 20)
    $Script:sourceLabel.Size = New-Object System.Drawing.Size(100, 20)
    $Script:sourceLabel.Text = "Source Image:"
    $TabPage.Controls.Add($Script:sourceLabel)

    $Script:sourceTextBox = New-Object System.Windows.Forms.TextBox
    $Script:sourceTextBox.Location = New-Object System.Drawing.Point(130, 20)
    $Script:sourceTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $TabPage.Controls.Add($Script:sourceTextBox)

    $Script:sourceButton = New-Object System.Windows.Forms.Button
    $Script:sourceButton.Location = New-Object System.Drawing.Point(540, 20)
    $Script:sourceButton.Size = New-Object System.Drawing.Size(75, 23)
    $Script:sourceButton.Text = "Browse..."
    $TabPage.Controls.Add($Script:sourceButton)

    # Destination file selection
    $Script:destLabel = New-Object System.Windows.Forms.Label
    $Script:destLabel.Location = New-Object System.Drawing.Point(20, 60)
    $Script:destLabel.Size = New-Object System.Drawing.Size(100, 20)
    $Script:destLabel.Text = "Destination:"
    $TabPage.Controls.Add($Script:destLabel)

    $Script:destTextBox = New-Object System.Windows.Forms.TextBox
    $Script:destTextBox.Location = New-Object System.Drawing.Point(130, 60)
    $Script:destTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $TabPage.Controls.Add($Script:destTextBox)

    $Script:destButton = New-Object System.Windows.Forms.Button
    $Script:destButton.Location = New-Object System.Drawing.Point(540, 60)
    $Script:destButton.Size = New-Object System.Drawing.Size(75, 23)
    $Script:destButton.Text = "Browse..."
    $TabPage.Controls.Add($Script:destButton)

    # Format selection
    $Script:formatLabel = New-Object System.Windows.Forms.Label
    $Script:formatLabel.Location = New-Object System.Drawing.Point(20, 100)
    $Script:formatLabel.Size = New-Object System.Drawing.Size(100, 20)
    $Script:formatLabel.Text = "Format:"
    $TabPage.Controls.Add($Script:formatLabel)

    $Script:formatComboBox = New-Object System.Windows.Forms.ComboBox
    $Script:formatComboBox.Location = New-Object System.Drawing.Point(130, 100)
    $Script:formatComboBox.Size = New-Object System.Drawing.Size(120, 20)
    $Script:formatComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $Script:formatComboBox.Items.AddRange(@("VDI", "VMDK", "VHD", "RAW"))
    $Script:formatComboBox.SelectedIndex = 0
    $TabPage.Controls.Add($Script:formatComboBox)

    # Options panel
    $Script:optionsPanel = New-Object System.Windows.Forms.Panel
    $Script:optionsPanel.Location = New-Object System.Drawing.Point(20, 140)
    $Script:optionsPanel.Size = New-Object System.Drawing.Size(700, 60)
    $Script:optionsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $TabPage.Controls.Add($Script:optionsPanel)

    # Compact option
    $Script:compactCheckBox = New-Object System.Windows.Forms.CheckBox
    $Script:compactCheckBox.Location = New-Object System.Drawing.Point(10, 10)
    $Script:compactCheckBox.Size = New-Object System.Drawing.Size(200, 20)
    $Script:compactCheckBox.Text = "Compact after conversion"
    $Script:compactCheckBox.Checked = $false
    $Script:optionsPanel.Controls.Add($Script:compactCheckBox)

    # Keep source option
    $Script:keepSourceCheckBox = New-Object System.Windows.Forms.CheckBox
    $Script:keepSourceCheckBox.Location = New-Object System.Drawing.Point(10, 30)
    $Script:keepSourceCheckBox.Size = New-Object System.Drawing.Size(200, 20)
    $Script:keepSourceCheckBox.Text = "Keep source image"
    $Script:keepSourceCheckBox.Checked = $true
    $Script:optionsPanel.Controls.Add($Script:keepSourceCheckBox)

    # Convert button
    $Script:convertButton = New-Object System.Windows.Forms.Button
    $Script:convertButton.Location = New-Object System.Drawing.Point(20, 220)
    $Script:convertButton.Size = New-Object System.Drawing.Size(100, 30)
    $Script:convertButton.Text = "Convert"
    $TabPage.Controls.Add($Script:convertButton)

    # Progress bar
    $Script:progressBar = New-Object System.Windows.Forms.ProgressBar
    $Script:progressBar.Location = New-Object System.Drawing.Point(20, 270)
    $Script:progressBar.Size = New-Object System.Drawing.Size(600, 20)
    $Script:progressBar.Visible = $false
    $TabPage.Controls.Add($Script:progressBar)

    # Status label
    $Script:statusLabel = New-Object System.Windows.Forms.Label
    $Script:statusLabel.Location = New-Object System.Drawing.Point(20, 300)
    $Script:statusLabel.Size = New-Object System.Drawing.Size(600, 60)
    $Script:statusLabel.Text = "Select source and destination files to begin conversion."
    $Script:statusLabel.AutoSize = $true
    $TabPage.Controls.Add($Script:statusLabel)

    # Event handlers
    $Script:sourceButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Disk Images|*.vdi;*.vmdk;*.vhd;*.img;*.iso;*.raw|VirtualBox Disk Images|*.vdi;*.vmdk;*.vhd|All Files (*.*)|*.*"
        $openFileDialog.Title = "Select Source Disk Image"
        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $Script:sourceTextBox.Text = $openFileDialog.FileName
            # Auto-suggest destination if empty
            if ([string]::IsNullOrEmpty($Script:destTextBox.Text)) {
                $sourceDir = Split-Path $openFileDialog.FileName -Parent
                $sourceBaseName = [System.IO.Path]::GetFileNameWithoutExtension($openFileDialog.FileName)
                $ext = $Script:formatComboBox.SelectedItem.ToString().ToLower()
                $Script:destTextBox.Text = Join-Path $sourceDir "$sourceBaseName-converted.$ext"
            }
        }
    })

    $Script:destButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveFileDialog.Filter = "VDI (*.vdi)|*.vdi|VMDK (*.vmdk)|*.vmdk|VHD (*.vhd)|*.vhd|RAW (*.raw)|*.raw|All Files (*.*)|*.*"
        $saveFileDialog.Title = "Select Destination Disk Image"
        $extension = $Script:formatComboBox.SelectedItem.ToString().ToLower()
        $saveFileDialog.DefaultExt = ".$extension"
        if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $Script:destTextBox.Text = $saveFileDialog.FileName
        }
    })

    $Script:formatComboBox.add_SelectedIndexChanged({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        # Update destination file extension when format changes
        if (-not [string]::IsNullOrEmpty($Script:destTextBox.Text)) {
            $currentPath = $Script:destTextBox.Text
            $dir = Split-Path $currentPath -Parent
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($currentPath)
            $newExt = $Script:formatComboBox.SelectedItem.ToString().ToLower()
            $Script:destTextBox.Text = Join-Path $dir "$baseName.$newExt"
        }
    })

    $Script:convertButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        if ([string]::IsNullOrEmpty($Script:sourceTextBox.Text) -or [string]::IsNullOrEmpty($Script:destTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please select both source and destination files.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        if (-not (Test-Path $Script:sourceTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Source file does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        # Check if destination file already exists
        if (Test-Path $Script:destTextBox.Text) {
            $dialogResult = [System.Windows.Forms.MessageBox]::Show("Destination file already exists. Do you want to overwrite it?", "Confirm Overwrite", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
            if ($dialogResult -eq [System.Windows.Forms.DialogResult]::No) {
                return
            }
        }

        $Script:progressBar.Visible = $true
        $Script:statusLabel.Text = "Converting image..."
        $Script:convertTabPage.Parent.Parent.Refresh()

        try {
            $result = Convert-VBoxDiskImage -Source $Script:sourceTextBox.Text -Destination $Script:destTextBox.Text -Format $Script:formatComboBox.SelectedItem
            if ($result.ExitCode -eq 0) {
                $Script:statusLabel.Text = "Conversion completed successfully!"

                # Optionally compact the image after conversion
                if ($Script:compactCheckBox.Checked) {
                    $Script:statusLabel.Text = "Conversion completed. Compacting image..."
                    $compactResult = Optimize-VBoxDiskImage -ImagePath $Script:destTextBox.Text
                    if ($compactResult.ExitCode -eq 0) {
                        $Script:statusLabel.Text = "Conversion and compaction completed successfully!"
                    } else {
                        $Script:statusLabel.Text = "Conversion completed but compaction failed: $($compactResult.Error)"
                    }
                }

                [System.Windows.Forms.MessageBox]::Show("Conversion completed successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } else {
                $Script:statusLabel.Text = "Error: $($result.Error)"
                Write-Host "VBoxManage Error: $($result.Error)"  # Print error to console
                [System.Windows.Forms.MessageBox]::Show("Conversion failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } catch {
            $Script:statusLabel.Text = "Error: $($_.Exception.Message)"
            Write-Host "Exception: $($_.Exception.Message)"  # Print exception to console
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } finally {
            $Script:progressBar.Visible = $false
        }
    })
}

function Initialize-ManageTab {
    param(
        [System.Windows.Forms.TabPage]$TabPage
    )

    # Store the TabPage in script scope to make it accessible in event handlers
    $Script:manageTabPage = $TabPage

    # Refresh button
    $Script:refreshButton = New-Object System.Windows.Forms.Button
    $Script:refreshButton.Location = New-Object System.Drawing.Point(20, 20)
    $Script:refreshButton.Size = New-Object System.Drawing.Size(100, 30)
    $Script:refreshButton.Text = "Refresh"
    $TabPage.Controls.Add($Script:refreshButton)

    # Data grid view for disk images
    $Script:dataGridView = New-Object System.Windows.Forms.DataGridView
    $Script:dataGridView.Location = New-Object System.Drawing.Point(20, 70)
    $Script:dataGridView.Size = New-Object System.Drawing.Size(700, 350)
    $Script:dataGridView.ReadOnly = $true
    $Script:dataGridView.AllowUserToAddRows = $false
    $Script:dataGridView.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect

    # Define columns
    $Script:dataGridView.Columns.Add("UUID", "UUID") | Out-Null
    $Script:dataGridView.Columns.Add("Location", "Location") | Out-Null
    $Script:dataGridView.Columns.Add("Format", "Format") | Out-Null
    $Script:dataGridView.Columns.Add("Capacity", "Capacity") | Out-Null
    $Script:dataGridView.Columns.Add("State", "State") | Out-Null
    $Script:dataGridView.Columns.Add("Type", "Type") | Out-Null

    $TabPage.Controls.Add($Script:dataGridView)

    # Action buttons
    $Script:compactButton = New-Object System.Windows.Forms.Button
    $Script:compactButton.Location = New-Object System.Drawing.Point(20, 440)
    $Script:compactButton.Size = New-Object System.Drawing.Size(100, 30)
    $Script:compactButton.Text = "Compact"
    $Script:compactButton.Enabled = $false
    $TabPage.Controls.Add($Script:compactButton)

    $Script:resizeButton = New-Object System.Windows.Forms.Button
    $Script:resizeButton.Location = New-Object System.Drawing.Point(130, 440)
    $Script:resizeButton.Size = New-Object System.Drawing.Size(100, 30)
    $Script:resizeButton.Text = "Resize"
    $Script:resizeButton.Enabled = $false
    $TabPage.Controls.Add($Script:resizeButton)

    # Status label
    $Script:statusLabel = New-Object System.Windows.Forms.Label
    $Script:statusLabel.Location = New-Object System.Drawing.Point(20, 480)
    $Script:statusLabel.Size = New-Object System.Drawing.Size(600, 20)
    $Script:statusLabel.Text = "Click Refresh to load disk images."
    $TabPage.Controls.Add($Script:statusLabel)

    # Load disk images function
    function Get-DiskImage {
        $Script:dataGridView.Rows.Clear()
        $disks = Get-VBoxDiskImage

        foreach ($disk in $disks) {
            $row = $Script:dataGridView.Rows.Add()
            $Script:dataGridView.Rows[$row].Cells["UUID"].Value = $disk.UUID
            $Script:dataGridView.Rows[$row].Cells["Location"].Value = $disk.Location
            $Script:dataGridView.Rows[$row].Cells["Format"].Value = $disk.Format
            $Script:dataGridView.Rows[$row].Cells["Capacity"].Value = $disk.Capacity
            $Script:dataGridView.Rows[$row].Cells["State"].Value = $disk.State
            $Script:dataGridView.Rows[$row].Cells["Type"].Value = $disk.Type
        }

        $Script:statusLabel.Text = "Loaded $($disks.Count) disk images."
    }

    # Event handlers
    $Script:refreshButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        Get-DiskImage
    })

    $Script:dataGridView.Add_SelectionChanged({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        if ($Script:dataGridView.SelectedRows.Count -gt 0) {
            $Script:compactButton.Enabled = $true
            $Script:resizeButton.Enabled = $true
        } else {
            $Script:compactButton.Enabled = $false
            $Script:resizeButton.Enabled = $false
        }
    })

    $Script:compactButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        if ($Script:dataGridView.SelectedRows.Count -gt 0) {
            $selectedRow = $Script:dataGridView.SelectedRows[0]
            $imagePath = $selectedRow.Cells["Location"].Value

            if ([System.Windows.Forms.MessageBox]::Show("Compact disk image '$imagePath'? This operation cannot be undone.", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) -eq [System.Windows.Forms.DialogResult]::Yes) {

                try {
                    $result = Optimize-VBoxDiskImage -ImagePath $imagePath
                    if ($result.ExitCode -eq 0) {
                        [System.Windows.Forms.MessageBox]::Show("Disk image compacted successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                        Get-DiskImage  # Refresh the list
                    } else {
                        Write-Host "VBoxManage Error: $($result.Error)"  # Print error to console
                        [System.Windows.Forms.MessageBox]::Show("Compaction failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                    }
                } catch {
                    Write-Host "Exception: $($_.Exception.Message)"  # Print exception to console
                    [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            }
        }
    })

    $Script:resizeButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        if ($Script:dataGridView.SelectedRows.Count -gt 0) {
            $selectedRow = $Script:dataGridView.SelectedRows[0]
            $imagePath = $selectedRow.Cells["Location"].Value

            # Prompt for new size
            $inputForm = New-Object System.Windows.Forms.Form
            $inputForm.Text = "Resize Disk Image"
            $inputForm.Size = New-Object System.Drawing.Size(300, 150)
            $inputForm.StartPosition = "CenterParent"

            $label = New-Object System.Windows.Forms.Label
            $label.Location = New-Object System.Drawing.Point(10, 20)
            $label.Size = New-Object System.Drawing.Size(200, 20)
            $label.Text = "New size (MB):"
            $inputForm.Controls.Add($label)

            $textBox = New-Object System.Windows.Forms.TextBox
            $textBox.Location = New-Object System.Drawing.Point(10, 45)
            $textBox.Size = New-Object System.Drawing.Size(200, 20)
            $inputForm.Controls.Add($textBox)

            $okButton = New-Object System.Windows.Forms.Button
            $okButton.Location = New-Object System.Drawing.Point(10, 80)
            $okButton.Size = New-Object System.Drawing.Size(75, 23)
            $okButton.Text = "OK"
            $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $inputForm.AcceptButton = $okButton
            $inputForm.Controls.Add($okButton)

            $cancelButton = New-Object System.Windows.Forms.Button
            $cancelButton.Location = New-Object System.Drawing.Point(95, 80)
            $cancelButton.Size = New-Object System.Drawing.Size(75, 23)
            $cancelButton.Text = "Cancel"
            $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $inputForm.CancelButton = $cancelButton
            $inputForm.Controls.Add($cancelButton)

            if ($inputForm.ShowDialog($Script:manageTabPage.Parent.FindForm()) -eq [System.Windows.Forms.DialogResult]::OK) {
                try {
                    $newSize = [int]$textBox.Text
                    $result = Resize-VBoxDiskImage -ImagePath $imagePath -SizeMB $newSize
                    if ($result.ExitCode -eq 0) {
                        [System.Windows.Forms.MessageBox]::Show("Disk image resized successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                        Get-DiskImage  # Refresh the list
                    } else {
                        Write-Host "VBoxManage Error: $($result.Error)"  # Print error to console
                        [System.Windows.Forms.MessageBox]::Show("Resize failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                    }
                } catch {
                    Write-Host "Exception: $($_.Exception.Message)"  # Print exception to console
                    [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            }
        }
    })

    # Load disk images initially
    Get-DiskImage
}

function Initialize-CreateTab {
    param(
        [System.Windows.Forms.TabPage]$TabPage
    )

    # Store the TabPage in script scope to make it accessible in event handlers
    $Script:createTabPage = $TabPage

    # Path selection
    $Script:pathLabel = New-Object System.Windows.Forms.Label
    $Script:pathLabel.Location = New-Object System.Drawing.Point(20, 20)
    $Script:pathLabel.Size = New-Object System.Drawing.Size(100, 20)
    $Script:pathLabel.Text = "Path:"
    $TabPage.Controls.Add($Script:pathLabel)

    $Script:pathTextBox = New-Object System.Windows.Forms.TextBox
    $Script:pathTextBox.Location = New-Object System.Drawing.Point(130, 20)
    $Script:pathTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $TabPage.Controls.Add($Script:pathTextBox)

    $Script:pathButton = New-Object System.Windows.Forms.Button
    $Script:pathButton.Location = New-Object System.Drawing.Point(540, 20)
    $Script:pathButton.Size = New-Object System.Drawing.Size(75, 23)
    $Script:pathButton.Text = "Browse..."
    $TabPage.Controls.Add($Script:pathButton)

    # Format selection
    $Script:formatLabel = New-Object System.Windows.Forms.Label
    $Script:formatLabel.Location = New-Object System.Drawing.Point(20, 60)
    $Script:formatLabel.Size = New-Object System.Drawing.Size(100, 20)
    $Script:formatLabel.Text = "Format:"
    $TabPage.Controls.Add($Script:formatLabel)

    $Script:formatComboBox = New-Object System.Windows.Forms.ComboBox
    $Script:formatComboBox.Location = New-Object System.Drawing.Point(130, 60)
    $Script:formatComboBox.Size = New-Object System.Drawing.Size(120, 20)
    $Script:formatComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $Script:formatComboBox.Items.AddRange(@("VDI", "VMDK", "VHD", "RAW"))
    $Script:formatComboBox.SelectedIndex = 0
    $TabPage.Controls.Add($Script:formatComboBox)

    # Size input
    $Script:sizeLabel = New-Object System.Windows.Forms.Label
    $Script:sizeLabel.Location = New-Object System.Drawing.Point(20, 100)
    $Script:sizeLabel.Size = New-Object System.Drawing.Size(100, 20)
    $Script:sizeLabel.Text = "Size (MB):"
    $TabPage.Controls.Add($Script:sizeLabel)

    $Script:sizeTextBox = New-Object System.Windows.Forms.TextBox
    $Script:sizeTextBox.Location = New-Object System.Drawing.Point(130, 100)
    $Script:sizeTextBox.Size = New-Object System.Drawing.Size(100, 20)
    $Script:sizeTextBox.Text = "1024"
    $TabPage.Controls.Add($Script:sizeTextBox)

    # Create button
    $Script:createButton = New-Object System.Windows.Forms.Button
    $Script:createButton.Location = New-Object System.Drawing.Point(20, 140)
    $Script:createButton.Size = New-Object System.Drawing.Size(100, 30)
    $Script:createButton.Text = "Create"
    $TabPage.Controls.Add($Script:createButton)

    # Status label
    $Script:statusLabel = New-Object System.Windows.Forms.Label
    $Script:statusLabel.Location = New-Object System.Drawing.Point(20, 180)
    $Script:statusLabel.Size = New-Object System.Drawing.Size(600, 60)
    $Script:statusLabel.Text = "Enter path and size to create a new disk image."
    $Script:statusLabel.AutoSize = $true
    $TabPage.Controls.Add($Script:statusLabel)

    # Event handlers
    $Script:pathButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveFileDialog.Filter = "VDI (*.vdi)|*.vdi|VMDK (*.vmdk)|*.vmdk|VHD (*.vhd)|*.vhd|RAW (*.raw)|*.raw|All Files (*.*)|*.*"
        $extension = $Script:formatComboBox.SelectedItem.ToString().ToLower()
        $saveFileDialog.DefaultExt = ".$extension"
        if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $Script:pathTextBox.Text = $saveFileDialog.FileName
        }
    })

    $Script:createButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        # Use the parameters to avoid PSScriptAnalyzer warnings
        $null = $scriptSender
        $null = $scriptEventArgs

        if ([string]::IsNullOrEmpty($Script:pathTextBox.Text) -or [string]::IsNullOrEmpty($Script:sizeTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter path and size.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        # Check if destination file already exists
        if (Test-Path $Script:pathTextBox.Text) {
            $dialogResult = [System.Windows.Forms.MessageBox]::Show("Destination file already exists. Do you want to overwrite it?", "Confirm Overwrite", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
            if ($dialogResult -eq [System.Windows.Forms.DialogResult]::No) {
                return
            }
        }

        try {
            $size = [int]$Script:sizeTextBox.Text
            $result = New-VBoxDiskImage -Path $Script:pathTextBox.Text -Format $Script:formatComboBox.SelectedItem -SizeMB $size
            if ($result.ExitCode -eq 0) {
                $Script:statusLabel.Text = "Disk image created successfully!"
                [System.Windows.Forms.MessageBox]::Show("Disk image created successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } else {
                $Script:statusLabel.Text = "Error: $($result.Error)"
                Write-Host "VBoxManage Error: $($result.Error)"  # Print error to console
                [System.Windows.Forms.MessageBox]::Show("Creation failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } catch {
            $Script:statusLabel.Text = "Error: $($_.Exception.Message)"
            Write-Host "Exception: $($_.Exception.Message)"  # Print exception to console
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
}
