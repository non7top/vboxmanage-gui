# AdvancedFeatures.ps1
# Additional advanced disk image management features

# Helper function to convert plain text to SecureString with suppression
function Convert-PlainTextToSecureString {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
    param(
        [string]$PlainText
    )
    return ConvertTo-SecureString $PlainText -AsPlainText -Force
}

function Initialize-AdvancedTab {
    param(
        [System.Windows.Forms.TabPage]$TabPage
    )

    # Create a group box for encryption features
    $Script:encryptionGroupBox = New-Object System.Windows.Forms.GroupBox
    $Script:encryptionGroupBox.Location = New-Object System.Drawing.Point(20, 20)
    $Script:encryptionGroupBox.Size = New-Object System.Drawing.Size(700, 150)
    $Script:encryptionGroupBox.Text = "Encryption"
    $TabPage.Controls.Add($Script:encryptionGroupBox)

    # Encryption controls
    $Script:encPathLabel = New-Object System.Windows.Forms.Label
    $Script:encPathLabel.Location = New-Object System.Drawing.Point(10, 25)
    $Script:encPathLabel.Size = New-Object System.Drawing.Size(80, 20)
    $Script:encPathLabel.Text = "Image Path:"
    $Script:encryptionGroupBox.Controls.Add($Script:encPathLabel)

    $Script:encPathTextBox = New-Object System.Windows.Forms.TextBox
    $Script:encPathTextBox.Location = New-Object System.Drawing.Point(90, 25)
    $Script:encPathTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $Script:encryptionGroupBox.Controls.Add($Script:encPathTextBox)

    $Script:encPathButton = New-Object System.Windows.Forms.Button
    $Script:encPathButton.Location = New-Object System.Drawing.Point(500, 25)
    $Script:encPathButton.Size = New-Object System.Drawing.Size(75, 23)
    $Script:encPathButton.Text = "Browse..."
    $Script:encryptionGroupBox.Controls.Add($Script:encPathButton)

    $Script:encPasswordLabel = New-Object System.Windows.Forms.Label
    $Script:encPasswordLabel.Location = New-Object System.Drawing.Point(10, 55)
    $Script:encPasswordLabel.Size = New-Object System.Drawing.Size(80, 20)
    $Script:encPasswordLabel.Text = "Password:"
    $Script:encryptionGroupBox.Controls.Add($Script:encPasswordLabel)

    $Script:encPasswordTextBox = New-Object System.Windows.Forms.TextBox
    $Script:encPasswordTextBox.Location = New-Object System.Drawing.Point(90, 55)
    $Script:encPasswordTextBox.Size = New-Object System.Drawing.Size(200, 20)
    $Script:encPasswordTextBox.PasswordChar = '*'
    $Script:encryptionGroupBox.Controls.Add($Script:encPasswordTextBox)

    $Script:encCipherLabel = New-Object System.Windows.Forms.Label
    $Script:encCipherLabel.Location = New-Object System.Drawing.Point(10, 85)
    $Script:encCipherLabel.Size = New-Object System.Drawing.Size(80, 20)
    $Script:encCipherLabel.Text = "Cipher:"
    $Script:encryptionGroupBox.Controls.Add($Script:encCipherLabel)

    $Script:encCipherComboBox = New-Object System.Windows.Forms.ComboBox
    $Script:encCipherComboBox.Location = New-Object System.Drawing.Point(90, 85)
    $Script:encCipherComboBox.Size = New-Object System.Drawing.Size(120, 20)
    $Script:encCipherComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $Script:encCipherComboBox.Items.AddRange(@("AES-256-XTS", "AES-128-XTS"))
    $Script:encCipherComboBox.SelectedIndex = 0
    $Script:encryptionGroupBox.Controls.Add($Script:encCipherComboBox)

    $Script:encryptButton = New-Object System.Windows.Forms.Button
    $Script:encryptButton.Location = New-Object System.Drawing.Point(10, 115)
    $Script:encryptButton.Size = New-Object System.Drawing.Size(100, 25)
    $Script:encryptButton.Text = "Encrypt"
    $Script:encryptionGroupBox.Controls.Add($Script:encryptButton)

    # Create a group box for disk information
    $Script:infoGroupBox = New-Object System.Windows.Forms.GroupBox
    $Script:infoGroupBox.Location = New-Object System.Drawing.Point(20, 180)
    $Script:infoGroupBox.Size = New-Object System.Drawing.Size(700, 200)
    $Script:infoGroupBox.Text = "Disk Information"
    $TabPage.Controls.Add($Script:infoGroupBox)

    # Info controls
    $Script:infoPathLabel = New-Object System.Windows.Forms.Label
    $Script:infoPathLabel.Location = New-Object System.Drawing.Point(10, 25)
    $Script:infoPathLabel.Size = New-Object System.Drawing.Size(80, 20)
    $Script:infoPathLabel.Text = "Image Path:"
    $Script:infoGroupBox.Controls.Add($Script:infoPathLabel)

    $Script:infoPathTextBox = New-Object System.Windows.Forms.TextBox
    $Script:infoPathTextBox.Location = New-Object System.Drawing.Point(90, 25)
    $Script:infoPathTextBox.Size = New-Object System.Drawing.Size(400, 20)
    $Script:infoGroupBox.Controls.Add($Script:infoPathTextBox)

    $Script:infoPathButton = New-Object System.Windows.Forms.Button
    $Script:infoPathButton.Location = New-Object System.Drawing.Point(500, 25)
    $Script:infoPathButton.Size = New-Object System.Drawing.Size(75, 23)
    $Script:infoPathButton.Text = "Browse..."
    $Script:infoGroupBox.Controls.Add($Script:infoPathButton)

    $Script:getInfoButton = New-Object System.Windows.Forms.Button
    $Script:getInfoButton.Location = New-Object System.Drawing.Point(10, 55)
    $Script:getInfoButton.Size = New-Object System.Drawing.Size(100, 25)
    $Script:getInfoButton.Text = "Get Info"
    $Script:infoGroupBox.Controls.Add($Script:getInfoButton)

    # Rich text box for displaying disk information
    $Script:infoRichTextBox = New-Object System.Windows.Forms.RichTextBox
    $Script:infoRichTextBox.Location = New-Object System.Drawing.Point(10, 85)
    $Script:infoRichTextBox.Size = New-Object System.Drawing.Size(680, 100)
    $Script:infoRichTextBox.ReadOnly = $true
    $Script:infoRichTextBox.Font = New-Object System.Drawing.Font("Consolas", 8)
    $Script:infoGroupBox.Controls.Add($Script:infoRichTextBox)

    # Event handlers for encryption
    $Script:encPathButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Disk Images|*.vdi;*.vmdk;*.vhd;*.img;*.raw|All Files (*.*)|*.*"
        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $Script:encPathTextBox.Text = $openFileDialog.FileName
        }
    })

    $Script:encryptButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        if ([string]::IsNullOrEmpty($Script:encPathTextBox.Text) -or [string]::IsNullOrEmpty($Script:encPasswordTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please specify image path and password.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        if ([System.Windows.Forms.MessageBox]::Show("Encrypt disk image? This operation cannot be undone.", "Confirm", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question) -eq [System.Windows.Forms.DialogResult]::Yes) {

            # Convert plain text password to SecureString using helper function that properly handles the suppression
            $securePassword = Convert-PlainTextToSecureString -PlainText $Script:encPasswordTextBox.Text

            try {
                $result = Protect-VBoxDiskImage -ImagePath $Script:encPathTextBox.Text -Password $securePassword -Cipher $Script:encCipherComboBox.SelectedItem
                if ($result.ExitCode -eq 0) {
                    [System.Windows.Forms.MessageBox]::Show("Disk image encrypted successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
                } else {
                    Write-Host "VBoxManage Error: $($result.Error)"  # Print error to console
                    [System.Windows.Forms.MessageBox]::Show("Encryption failed: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
                }
            } catch {
                Write-Host "Exception: $($_.Exception.Message)"  # Print exception to console
                [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }
    })

    # Event handlers for disk info
    $Script:infoPathButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Filter = "Disk Images|*.vdi;*.vmdk;*.vhd;*.img;*.raw|All Files (*.*)|*.*"
        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $Script:infoPathTextBox.Text = $openFileDialog.FileName
        }
    })

    $Script:getInfoButton.Add_Click({
        param($scriptSender, $scriptEventArgs)

        if ([string]::IsNullOrEmpty($Script:infoPathTextBox.Text)) {
            [System.Windows.Forms.MessageBox]::Show("Please specify image path.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            return
        }

        try {
            $result = Get-VBoxInfo -ImagePath $Script:infoPathTextBox.Text
            if ($result.ExitCode -eq 0) {
                $Script:infoRichTextBox.Text = $result.Output
            } else {
                Write-Host "VBoxManage Error: $($result.Error)"  # Print error to console
                [System.Windows.Forms.MessageBox]::Show("Failed to get disk info: $($result.Error)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        } catch {
            Write-Host "Exception: $($_.Exception.Message)"  # Print exception to console
            [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
}
