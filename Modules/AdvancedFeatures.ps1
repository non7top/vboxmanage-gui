# AdvancedFeatures.ps1
# Additional advanced disk image management features

function Initialize-AdvancedTab {
    param(
        [System.Windows.Forms.TabPage]$TabPage
    )

    # Create a group box for encryption features
    $encryptionGroupBox = New-Object System.Windows.Forms.GroupBox
    $encryptionGroupBox.Location = New-Object System.Drawing.Point(20, 20)
    $encryptionGroupBox.Size = New-Object System.Drawing.Size(700, 150)
    $encryptionGroupBox.Text = "Encryption"
    $TabPage.Controls.Add($encryptionGroupBox)

    # Encryption controls
    $encPathLabel = New-Object System.Windows.Forms.Label
    $encPathLabel.Location = New-Object System.Drawing.Point(10, 25)
    $encPathLabel.Size = New-Object System.Drawing.Size(80, 20)
    $encPathLabel.Text = "Image Path:"
    $encryptionGroupBox.Controls.Add($encPathLabel)

    $encPathTextBox = New-Object System.Windows.Forms.TextBox
    $encPathTextBox.Location = New-Object System.Drawing.Point(90, 25)
    $encPathTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $encryptionGroupBox.Controls.Add($encPathTextBox)

    $encPathButton = New-Object System.Windows.Forms.Button
    $encPathButton.Location = New-Object System.Drawing.Point(500, 25)
    $encPathButton.Size = New-Object System.Drawing.Size(75, 23)
    $encPathButton.Text = "Browse..."
    $encryptionGroupBox.Controls.Add($encPathButton)

    $encPasswordLabel = New-Object System.Windows.Forms.Label
    $encPasswordLabel.Location = New-Object System.Drawing.Point(10, 55)
    $encPasswordLabel.Size = New-Object System.Drawing.Size(80, 20)
    $encPasswordLabel.Text = "Password:"
    $encryptionGroupBox.Controls.Add($encPasswordLabel)

    $encPasswordTextBox = New-Object System.Windows.Forms.TextBox
    $encPasswordTextBox.Location = New-Object System.Drawing.Point(90, 55)
    $encPasswordTextBox.Size = New-Object System.Drawing.Size(200, 20)
    $encPasswordTextBox.PasswordChar = '*'
    $encryptionGroupBox.Controls.Add($encPasswordTextBox)

    $encCipherLabel = New-Object System.Windows.Forms.Label
    $encCipherLabel.Location = New-Object System.Drawing.Point(10, 85)
    $encCipherLabel.Size = New-Object System.Drawing.Size(80, 20)
    $encCipherLabel.Text = "Cipher:"
    $encryptionGroupBox.Controls.Add($encCipherLabel)

    $encCipherComboBox = New-Object System.Windows.Forms.ComboBox
    $encCipherComboBox.Location = New-Object System.Drawing.Point(90, 85)
    $encCipherComboBox.Size = New-Object System.Drawing.Size(120, 20)
    $encCipherComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $encCipherComboBox.Items.AddRange(@("AES-256-XTS", "AES-128-XTS"))
    $encCipherComboBox.SelectedIndex = 0
    $encryptionGroupBox.Controls.Add($encCipherComboBox)

    $encryptButton = New-Object System.Windows.Forms.Button
    $encryptButton.Location = New-Object System.Drawing.Point(10, 115)
    $encryptButton.Size = New-Object System.Drawing.Size(100, 25)
    $encryptButton.Text = "Encrypt"
    $encryptionGroupBox.Controls.Add($encryptButton)

    # Create a group box for disk information
    $infoGroupBox = New-Object System.Windows.Forms.GroupBox
    $infoGroupBox.Location = New-Object System.Drawing.Point(20, 180)
    $infoGroupBox.Size = New-Object System.Drawing.Size(700, 200)
    $infoGroupBox.Text = "Disk Information"
    $TabPage.Controls.Add($infoGroupBox)

    # Info controls
    $infoPathLabel = New-Object System.Windows.Forms.Label
    $infoPathLabel.Location = New-Object System.Drawing.Point(10, 25)
    $infoPathLabel.Size = New-Object System.Drawing.Size(80, 20)
    $infoPathLabel.Text = "Image Path:"
    $infoGroupBox.Controls.Add($infoPathLabel)

    $infoPathTextBox = New-Object System.Windows.Forms.TextBox
    $infoPathTextBox.Location = New-Object System.Drawing.Point(90, 25)
    $infoPathTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $infoGroupBox.Controls.Add($infoPathTextBox)

    $infoPathButton = New-Object System.Windows.Forms.Button
    $infoPathButton.Location = New-Object System.Drawing.Point(500, 25)
    $infoPathButton.Size = New-Object System.Drawing.Size(75, 23)
    $infoPathButton.Text = "Browse..."
    $infoGroupBox.Controls.Add($infoPathButton)

    $getInfoButton = New-Object System.Windows.Forms.Button
    $getInfoButton.Location = New-Object System.Drawing.Point(10, 55)
    $getInfoButton.Size = New-Object System.Drawing.Size(100, 25)
    $getInfoButton.Text = "Get Info"
    $infoGroupBox.Controls.Add($getInfoButton)

    # Rich text box for displaying disk information
    $infoRichTextBox = New-Object System.Windows.Forms.RichTextBox
    $infoRichTextBox.Location = New-Object System.Drawing.Point(10, 85)
    $infoRichTextBox.Size = New-Object System.Drawing.Size(680, 100)
    $infoRichTextBox.ReadOnly = $true
    $infoRichTextBox.Font = New-Object System.Drawing.Font("Consolas", 8)
    $infoGroupBox.Controls.Add($infoRichTextBox)

    # Event handlers for encryption
    $encPathButton.Add_Click({
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Disk Images|*.vdi;*.vmdk;*.vhd;*.img;*.raw|All Files (*.*)|*.*"
        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $encPathTextBox.Text = $openFileDialog.FileName
        }
    })

    $encryptButton.Add_Click({
        if ([string]::IsNullOrEmpty($encPathTextBox.Text) -or [string]::IsNullOrEmpty($encPasswordTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please specify image path and password.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        if ([System.Windows.Forms.MessageBox]::Show("Encrypt disk image? This operation cannot be undone.", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) -eq [System.Windows.Forms.DialogResult]::Yes) {

            # Convert plain text password to SecureString
            $securePassword = ConvertTo-SecureString $encPasswordTextBox.Text -AsPlainText -Force

            try {
                $result = Protect-VBoxDiskImage -ImagePath $encPathTextBox.Text -Password $securePassword -Cipher $encCipherComboBox.SelectedItem
                if ($result.ExitCode -eq 0) {
                    [System.Windows.Forms.MessageBox]::Show("Disk image encrypted successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                } else {
                    [System.Windows.Forms.MessageBox]::Show("Encryption failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    })

    # Event handlers for disk info
    $infoPathButton.Add_Click({
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Disk Images|*.vdi;*.vmdk;*.vhd;*.img;*.raw|All Files (*.*)|*.*"
        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $infoPathTextBox.Text = $openFileDialog.FileName
        }
    })

    $getInfoButton.Add_Click({
        if ([string]::IsNullOrEmpty($infoPathTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please specify image path.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        try {
            $result = Get-VBoxInfo -ImagePath $infoPathTextBox.Text
            if ($result.ExitCode -eq 0) {
                $infoRichTextBox.Text = $result.Output
            } else {
                [System.Windows.Forms.MessageBox]::Show("Failed to get disk info: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
}
