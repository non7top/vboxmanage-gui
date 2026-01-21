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

    # Source file selection
    $sourceLabel = New-Object System.Windows.Forms.Label
    $sourceLabel.Location = New-Object System.Drawing.Point(20, 20)
    $sourceLabel.Size = New-Object System.Drawing.Size(100, 20)
    $sourceLabel.Text = "Source Image:"
    $TabPage.Controls.Add($sourceLabel)

    $sourceTextBox = New-Object System.Windows.Forms.TextBox
    $sourceTextBox.Location = New-Object System.Drawing.Point(130, 20)
    $sourceTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $TabPage.Controls.Add($sourceTextBox)

    $sourceButton = New-Object System.Windows.Forms.Button
    $sourceButton.Location = New-Object System.Drawing.Point(540, 20)
    $sourceButton.Size = New-Object System.Drawing.Size(75, 23)
    $sourceButton.Text = "Browse..."
    $TabPage.Controls.Add($sourceButton)

    # Destination file selection
    $destLabel = New-Object System.Windows.Forms.Label
    $destLabel.Location = New-Object System.Drawing.Point(20, 60)
    $destLabel.Size = New-Object System.Drawing.Size(100, 20)
    $destLabel.Text = "Destination:"
    $TabPage.Controls.Add($destLabel)

    $destTextBox = New-Object System.Windows.Forms.TextBox
    $destTextBox.Location = New-Object System.Drawing.Point(130, 60)
    $destTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $TabPage.Controls.Add($destTextBox)

    $destButton = New-Object System.Windows.Forms.Button
    $destButton.Location = New-Object System.Drawing.Point(540, 60)
    $destButton.Size = New-Object System.Drawing.Size(75, 23)
    $destButton.Text = "Browse..."
    $TabPage.Controls.Add($destButton)

    # Format selection
    $formatLabel = New-Object System.Windows.Forms.Label
    $formatLabel.Location = New-Object System.Drawing.Point(20, 100)
    $formatLabel.Size = New-Object System.Drawing.Size(100, 20)
    $formatLabel.Text = "Format:"
    $TabPage.Controls.Add($formatLabel)

    $formatComboBox = New-Object System.Windows.Forms.ComboBox
    $formatComboBox.Location = New-Object System.Drawing.Point(130, 100)
    $formatComboBox.Size = New-Object System.Drawing.Size(120, 20)
    $formatComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $formatComboBox.Items.AddRange(@("VDI", "VMDK", "VHD", "RAW"))
    $formatComboBox.SelectedIndex = 0
    $TabPage.Controls.Add($formatComboBox)

    # Options panel
    $optionsPanel = New-Object System.Windows.Forms.Panel
    $optionsPanel.Location = New-Object System.Drawing.Point(20, 140)
    $optionsPanel.Size = New-Object System.Drawing.Size(700, 60)
    $optionsPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $TabPage.Controls.Add($optionsPanel)

    # Compact option
    $compactCheckBox = New-Object System.Windows.Forms.CheckBox
    $compactCheckBox.Location = New-Object System.Drawing.Point(10, 10)
    $compactCheckBox.Size = New-Object System.Drawing.Size(200, 20)
    $compactCheckBox.Text = "Compact after conversion"
    $compactCheckBox.Checked = $false
    $optionsPanel.Controls.Add($compactCheckBox)

    # Keep source option
    $keepSourceCheckBox = New-Object System.Windows.Forms.CheckBox
    $keepSourceCheckBox.Location = New-Object System.Drawing.Point(10, 30)
    $keepSourceCheckBox.Size = New-Object System.Drawing.Size(200, 20)
    $keepSourceCheckBox.Text = "Keep source image"
    $keepSourceCheckBox.Checked = $true
    $optionsPanel.Controls.Add($keepSourceCheckBox)

    # Convert button
    $convertButton = New-Object System.Windows.Forms.Button
    $convertButton.Location = New-Object System.Drawing.Point(20, 220)
    $convertButton.Size = New-Object System.Drawing.Size(100, 30)
    $convertButton.Text = "Convert"
    $TabPage.Controls.Add($convertButton)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(20, 270)
    $progressBar.Size = New-Object System.Drawing.Size(600, 20)
    $progressBar.Visible = $false
    $TabPage.Controls.Add($progressBar)

    # Status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Location = New-Object System.Drawing.Point(20, 300)
    $statusLabel.Size = New-Object System.Drawing.Size(600, 60)
    $statusLabel.Text = "Select source and destination files to begin conversion."
    $statusLabel.AutoSize = $true
    $TabPage.Controls.Add($statusLabel)

    # Store controls in a hashtable to pass to event handlers
    $controls = @{
        SourceTextBox = $sourceTextBox
        DestTextBox = $destTextBox
        FormatComboBox = $formatComboBox
        CompactCheckBox = $compactCheckBox
        ProgressBar = $progressBar
        StatusLabel = $statusLabel
        TabPage = $TabPage
    }

    # Event handlers
    $sourceButton.Add_Click({
        param($sender, $eventArgs)

        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Disk Images|*.vdi;*.vmdk;*.vhd;*.img;*.iso;*.raw|VirtualBox Disk Images|*.vdi;*.vmdk;*.vhd|All Files (*.*)|*.*"
        $openFileDialog.Title = "Select Source Disk Image"
        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $controls.SourceTextBox.Text = $openFileDialog.FileName
            # Auto-suggest destination if empty
            if ([string]::IsNullOrEmpty($controls.DestTextBox.Text)) {
                $sourceDir = Split-Path $openFileDialog.FileName -Parent
                $sourceBaseName = [System.IO.Path]::GetFileNameWithoutExtension($openFileDialog.FileName)
                $ext = $controls.FormatComboBox.SelectedItem.ToString().ToLower()
                $controls.DestTextBox.Text = Join-Path $sourceDir "$sourceBaseName-converted.$ext"
            }
        }
    })

    $destButton.Add_Click({
        param($sender, $eventArgs)

        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveFileDialog.Filter = "VDI (*.vdi)|*.vdi|VMDK (*.vmdk)|*.vmdk|VHD (*.vhd)|*.vhd|RAW (*.raw)|*.raw|All Files (*.*)|*.*"
        $saveFileDialog.Title = "Select Destination Disk Image"
        $extension = $controls.FormatComboBox.SelectedItem.ToString().ToLower()
        $saveFileDialog.DefaultExt = ".$extension"
        if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $controls.DestTextBox.Text = $saveFileDialog.FileName
        }
    })

    $controls.FormatComboBox.add_SelectedIndexChanged({
        param($sender, $eventArgs)

        # Update destination file extension when format changes
        if (-not [string]::IsNullOrEmpty($controls.DestTextBox.Text)) {
            $currentPath = $controls.DestTextBox.Text
            $dir = Split-Path $currentPath -Parent
            $baseName = [System.IO.Path]::GetFileNameWithoutExtension($currentPath)
            $newExt = $controls.FormatComboBox.SelectedItem.ToString().ToLower()
            $controls.DestTextBox.Text = Join-Path $dir "$baseName.$newExt"
        }
    })

    $convertButton.Add_Click({
        param($sender, $eventArgs)

        if ([string]::IsNullOrEmpty($controls.SourceTextBox.Text) -or [string]::IsNullOrEmpty($controls.DestTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please select both source and destination files.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        if (-not (Test-Path $controls.SourceTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Source file does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        $controls.ProgressBar.Visible = $true
        $controls.StatusLabel.Text = "Converting image..."
        $controls.TabPage.Parent.Refresh()

        try {
            $result = Convert-VBoxDiskImage -Source $controls.SourceTextBox.Text -Destination $controls.DestTextBox.Text -Format $controls.FormatComboBox.SelectedItem
            if ($result.ExitCode -eq 0) {
                $controls.StatusLabel.Text = "Conversion completed successfully!"

                # Optionally compact the image after conversion
                if ($controls.CompactCheckBox.Checked) {
                    $controls.StatusLabel.Text = "Conversion completed. Compacting image..."
                    $compactResult = Optimize-VBoxDiskImage -ImagePath $controls.DestTextBox.Text
                    if ($compactResult.ExitCode -eq 0) {
                        $controls.StatusLabel.Text = "Conversion and compaction completed successfully!"
                    } else {
                        $controls.StatusLabel.Text = "Conversion completed but compaction failed: $($compactResult.Error)"
                    }
                }

                [System.Windows.Forms.MessageBox]::Show("Conversion completed successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } else {
                $controls.StatusLabel.Text = "Error: $($result.Error)"
                [System.Windows.Forms.MessageBox]::Show("Conversion failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } catch {
            $controls.StatusLabel.Text = "Error: $($_.Exception.Message)"
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        } finally {
            $controls.ProgressBar.Visible = $false
        }
    })
}

function Initialize-ManageTab {
    param(
        [System.Windows.Forms.TabPage]$TabPage
    )

    # Refresh button
    $refreshButton = New-Object System.Windows.Forms.Button
    $refreshButton.Location = New-Object System.Drawing.Point(20, 20)
    $refreshButton.Size = New-Object System.Drawing.Size(100, 30)
    $refreshButton.Text = "Refresh"
    $TabPage.Controls.Add($refreshButton)

    # Data grid view for disk images
    $dataGridView = New-Object System.Windows.Forms.DataGridView
    $dataGridView.Location = New-Object System.Drawing.Point(20, 70)
    $dataGridView.Size = New-Object System.Drawing.Size(700, 350)
    $dataGridView.ReadOnly = $true
    $dataGridView.AllowUserToAddRows = $false
    $dataGridView.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect

    # Define columns
    $dataGridView.Columns.Add("UUID", "UUID") | Out-Null
    $dataGridView.Columns.Add("Location", "Location") | Out-Null
    $dataGridView.Columns.Add("Format", "Format") | Out-Null
    $dataGridView.Columns.Add("Capacity", "Capacity") | Out-Null
    $dataGridView.Columns.Add("State", "State") | Out-Null
    $dataGridView.Columns.Add("Type", "Type") | Out-Null

    $TabPage.Controls.Add($dataGridView)

    # Action buttons
    $compactButton = New-Object System.Windows.Forms.Button
    $compactButton.Location = New-Object System.Drawing.Point(20, 440)
    $compactButton.Size = New-Object System.Drawing.Size(100, 30)
    $compactButton.Text = "Compact"
    $compactButton.Enabled = $false
    $TabPage.Controls.Add($compactButton)

    $resizeButton = New-Object System.Windows.Forms.Button
    $resizeButton.Location = New-Object System.Drawing.Point(130, 440)
    $resizeButton.Size = New-Object System.Drawing.Size(100, 30)
    $resizeButton.Text = "Resize"
    $resizeButton.Enabled = $false
    $TabPage.Controls.Add($resizeButton)

    # Status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Location = New-Object System.Drawing.Point(20, 480)
    $statusLabel.Size = New-Object System.Drawing.Size(600, 20)
    $statusLabel.Text = "Click Refresh to load disk images."
    $TabPage.Controls.Add($statusLabel)

    # Store controls in a hashtable to pass to event handlers
    $controls = @{
        DataGridView = $dataGridView
        CompactButton = $compactButton
        ResizeButton = $resizeButton
        StatusLabel = $statusLabel
        TabPage = $TabPage
    }

    # Load disk images function
    function Get-DiskImage {
        $controls.DataGridView.Rows.Clear()
        $disks = Get-VBoxDiskImage

        foreach ($disk in $disks) {
            $row = $controls.DataGridView.Rows.Add()
            $controls.DataGridView.Rows[$row].Cells["UUID"].Value = $disk.UUID
            $controls.DataGridView.Rows[$row].Cells["Location"].Value = $disk.Location
            $controls.DataGridView.Rows[$row].Cells["Format"].Value = $disk.Format
            $controls.DataGridView.Rows[$row].Cells["Capacity"].Value = $disk.Capacity
            $controls.DataGridView.Rows[$row].Cells["State"].Value = $disk.State
            $controls.DataGridView.Rows[$row].Cells["Type"].Value = $disk.Type
        }

        $controls.StatusLabel.Text = "Loaded $($disks.Count) disk images."
    }

    # Event handlers
    $refreshButton.Add_Click({
        param($sender, $eventArgs)
        Get-DiskImage
    })

    $controls.DataGridView.Add_SelectionChanged({
        param($sender, $eventArgs)
        if ($controls.DataGridView.SelectedRows.Count -gt 0) {
            $controls.CompactButton.Enabled = $true
            $controls.ResizeButton.Enabled = $true
        } else {
            $controls.CompactButton.Enabled = $false
            $controls.ResizeButton.Enabled = $false
        }
    })

    $compactButton.Add_Click({
        param($sender, $eventArgs)
        if ($controls.DataGridView.SelectedRows.Count -gt 0) {
            $selectedRow = $controls.DataGridView.SelectedRows[0]
            $imagePath = $selectedRow.Cells["Location"].Value

            if ([System.Windows.Forms.MessageBox]::Show("Compact disk image '$imagePath'? This operation cannot be undone.", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) -eq [System.Windows.Forms.DialogResult]::Yes) {

                try {
                    $result = Optimize-VBoxDiskImage -ImagePath $imagePath
                    if ($result.ExitCode -eq 0) {
                        [System.Windows.Forms.MessageBox]::Show("Disk image compacted successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                        Get-DiskImage  # Refresh the list
                    } else {
                        [System.Windows.Forms.MessageBox]::Show("Compaction failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                    }
                } catch {
                    [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            }
        }
    })

    $resizeButton.Add_Click({
        param($sender, $eventArgs)
        if ($controls.DataGridView.SelectedRows.Count -gt 0) {
            $selectedRow = $controls.DataGridView.SelectedRows[0]
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

            if ($inputForm.ShowDialog($controls.TabPage.Parent.FindForm()) -eq [System.Windows.Forms.DialogResult]::OK) {
                try {
                    $newSize = [int]$textBox.Text
                    $result = Resize-VBoxDiskImage -ImagePath $imagePath -SizeMB $newSize
                    if ($result.ExitCode -eq 0) {
                        [System.Windows.Forms.MessageBox]::Show("Disk image resized successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                        Get-DiskImage  # Refresh the list
                    } else {
                        [System.Windows.Forms.MessageBox]::Show("Resize failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                    }
                } catch {
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

    # Path selection
    $pathLabel = New-Object System.Windows.Forms.Label
    $pathLabel.Location = New-Object System.Drawing.Point(20, 20)
    $pathLabel.Size = New-Object System.Drawing.Size(100, 20)
    $pathLabel.Text = "Path:"
    $TabPage.Controls.Add($pathLabel)

    $pathTextBox = New-Object System.Windows.Forms.TextBox
    $pathTextBox.Location = New-Object System.Drawing.Point(130, 20)
    $pathTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $TabPage.Controls.Add($pathTextBox)

    $pathButton = New-Object System.Windows.Forms.Button
    $pathButton.Location = New-Object System.Drawing.Point(540, 20)
    $pathButton.Size = New-Object System.Drawing.Size(75, 23)
    $pathButton.Text = "Browse..."
    $TabPage.Controls.Add($pathButton)

    # Format selection
    $formatLabel = New-Object System.Windows.Forms.Label
    $formatLabel.Location = New-Object System.Drawing.Point(20, 60)
    $formatLabel.Size = New-Object System.Drawing.Size(100, 20)
    $formatLabel.Text = "Format:"
    $TabPage.Controls.Add($formatLabel)

    $formatComboBox = New-Object System.Windows.Forms.ComboBox
    $formatComboBox.Location = New-Object System.Drawing.Point(130, 60)
    $formatComboBox.Size = New-Object System.Drawing.Size(120, 20)
    $formatComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $formatComboBox.Items.AddRange(@("VDI", "VMDK", "VHD", "RAW"))
    $formatComboBox.SelectedIndex = 0
    $TabPage.Controls.Add($formatComboBox)

    # Size input
    $sizeLabel = New-Object System.Windows.Forms.Label
    $sizeLabel.Location = New-Object System.Drawing.Point(20, 100)
    $sizeLabel.Size = New-Object System.Drawing.Size(100, 20)
    $sizeLabel.Text = "Size (MB):"
    $TabPage.Controls.Add($sizeLabel)

    $sizeTextBox = New-Object System.Windows.Forms.TextBox
    $sizeTextBox.Location = New-Object System.Drawing.Point(130, 100)
    $sizeTextBox.Size = New-Object System.Drawing.Size(100, 20)
    $sizeTextBox.Text = "1024"
    $TabPage.Controls.Add($sizeTextBox)

    # Create button
    $createButton = New-Object System.Windows.Forms.Button
    $createButton.Location = New-Object System.Drawing.Point(20, 140)
    $createButton.Size = New-Object System.Drawing.Size(100, 30)
    $createButton.Text = "Create"
    $TabPage.Controls.Add($createButton)

    # Status label
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Location = New-Object System.Drawing.Point(20, 180)
    $statusLabel.Size = New-Object System.Drawing.Size(600, 60)
    $statusLabel.Text = "Enter path and size to create a new disk image."
    $statusLabel.AutoSize = $true
    $TabPage.Controls.Add($statusLabel)

    # Store controls in a hashtable to pass to event handlers
    $controls = @{
        PathTextBox = $pathTextBox
        FormatComboBox = $formatComboBox
        SizeTextBox = $sizeTextBox
        StatusLabel = $statusLabel
    }

    # Event handlers
    $pathButton.Add_Click({
        param($sender, $eventArgs)

        $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveFileDialog.Filter = "VDI (*.vdi)|*.vdi|VMDK (*.vmdk)|*.vmdk|VHD (*.vhd)|*.vhd|RAW (*.raw)|*.raw|All Files (*.*)|*.*"
        $extension = $controls.FormatComboBox.SelectedItem.ToString().ToLower()
        $saveFileDialog.DefaultExt = ".$extension"
        if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $controls.PathTextBox.Text = $saveFileDialog.FileName
        }
    })

    $createButton.Add_Click({
        param($sender, $eventArgs)

        if ([string]::IsNullOrEmpty($controls.PathTextBox.Text) -or [string]::IsNullOrEmpty($controls.SizeTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please enter path and size.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        try {
            $size = [int]$controls.SizeTextBox.Text
            $result = New-VBoxDiskImage -Path $controls.PathTextBox.Text -Format $controls.FormatComboBox.SelectedItem -SizeMB $size
            if ($result.ExitCode -eq 0) {
                $controls.StatusLabel.Text = "Disk image created successfully!"
                [System.Windows.Forms.MessageBox]::Show("Disk image created successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            } else {
                $controls.StatusLabel.Text = "Error: $($result.Error)"
                [System.Windows.Forms.MessageBox]::Show("Creation failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } catch {
            $controls.StatusLabel.Text = "Error: $($_.Exception.Message)"
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
}
