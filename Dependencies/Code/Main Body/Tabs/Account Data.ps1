$Section3AccountDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Account Data"
    Name = "Account Data Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
}
$InformationTabControl.Controls.Add($Section3AccountDataTab)


### Row 1 ###


$script:Section3AccountDataNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $FormScale * 3
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Account Name" -Icon "Info" -Message @"
+  This field is reserved for the Account Name.
+  Account Names are not case sensitive.
+  Though IP addresses may be entered, WinRM queries may fail as
    IPs may only be used for authentication under certain conditions.
"@
    }
}
$Section3AccountDataTab.Controls.Add($script:Section3AccountDataNameTextBox)


$Section3AccountDataOUTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $script:Section3AccountDataNameTextBox.Top + $script:Section3AccountDataNameTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Organizational Unit / Container Name" -Icon "Info" -Message @"
+  The OU/CN that the account belongs to.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataOUTextBox)


$Section3AccountDataCreatedTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $Section3AccountDataOUTextBox.Top + $Section3AccountDataOUTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Created" -Icon "Info" -Message @"
+  When the account was created.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataCreatedTextBox)


$Section3AccountDataModifiedTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $Section3AccountDataCreatedTextBox.Top + $Section3AccountDataCreatedTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Modified" -Icon "Info" -Message @"
+  When the account was last modified.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataModifiedTextBox)


$Section3AccountDataLastLogonDateTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $Section3AccountDataModifiedTextBox.Top + $Section3AccountDataModifiedTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Last Logon Date" -Icon "Info" -Message @"
+  Whent the account was last logged on to.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLastLogonDateTextBox)


$Section3AccountDataLastBadPasswordAttemptTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = 0
    Top       = $Section3AccountDataLastLogonDateTextBox.Top + $Section3AccountDataLastLogonDateTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Last Bad Password Attempt" -Icon "Info" -Message @"
+  Whent the account was last bad password attempt was logged.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLastBadPasswordAttemptTextBox)


### Row 2 ###


$Section3AccountDataSIDTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $script:Section3AccountDataNameTextBox.Left + $script:Section3AccountDataNameTextBox.Width + $($FormScale * 10)
    Top       = $FormScale * 3
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "SID" -Icon "Info" -Message @"
+  This is the accounts Security Identifier (SID).
+  A SID is a unique value of variable length that is used to identify a security principal (such as a security group) in Windows operating systems. SIDs that identify generic users or generic groups is well known. Their values remain constant across all operating systems.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataSIDTextBox)


$Section3AccountDataEnabledTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataSIDTextBox.Left
    Top       = $FormScale * 3
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Enabled" -Icon "Info" -Message @"
+  Enabled status of the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataEnabledTextBox)


$Section3AccountDataLockedOutTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataSIDTextBox.Left
    Top       = $Section3AccountDataEnabledTextBox.Top + $Section3AccountDataEnabledTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Locked Out" -Icon "Info" -Message @"
+  Locked Out status of the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLockedOutTextBox)


$Section3AccountDataSmartCardLogonRequiredTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataSIDTextBox.Left
    Top       = $Section3AccountDataLockedOutTextBox.Top + $Section3AccountDataLockedOutTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Smart Card Logon Required" -Icon "Info" -Message @"
+  Configuration state if a smart card logon is required for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataSmartCardLogonRequiredTextBox)


$Section3AccountDataScriptPathTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataSIDTextBox.Left
    Top       = $Section3AccountDataSmartCardLogonRequiredTextBox.Top + $Section3AccountDataSmartCardLogonRequiredTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Script Path" -Icon "Info" -Message @"
+  Configured script path for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataScriptPathTextBox)


$Section3AccountDataHomeDriveTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataSIDTextBox.Left
    Top       = $Section3AccountDataScriptPathTextBox.Top + $Section3AccountDataScriptPathTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 250
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Script Path" -Icon "Info" -Message @"
+  Configured script path for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataHomeDriveTextBox)


$Section3AccountDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Name      = "Tags"
    Text      = "Tags"
    Left      = $FormScale * 260
    Top       = $Section3AccountDataLastBadPasswordAttemptTextBox.Top
    Width     = $FormScale * 200
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseHover     = {
        Show-ToolTip -Title "List of Pre-Built Tags" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be modified, created, and used.
"@
    }
}
ForEach ($Item in $TagListFileContents) { $Section3AccountDataTagsComboBox.Items.Add($Item) }
$Section3AccountDataTab.Controls.Add($Section3AccountDataTagsComboBox)


### Row 3 ###


$Section3AccountDataBadLogonCountTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataSIDTextBox.Left + $Section3AccountDataSIDTextBox.Width + $($FormScale * 10)
    Top       = $FormScale * 3
    Width     = $FormScale * 220
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Bad Logon Count" -Icon "Info" -Message @"
+  Number of bad logon counts for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataBadLogonCountTextBox)
                            

$Section3AccountDataPasswordExpiredTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataBadLogonCountTextBox.Left
    Top       = $Section3AccountDataBadLogonCountTextBox.Top + $Section3AccountDataBadLogonCountTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 220
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Password Expired" -Icon "Info" -Message @"
+  Password expiration status for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordExpiredTextBox)


$Section3AccountDataPasswordNeverExpiresTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataBadLogonCountTextBox.Left
    Top       = $Section3AccountDataPasswordExpiredTextBox.Top + $Section3AccountDataPasswordExpiredTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 220
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Password Never Expires" -Icon "Info" -Message @"
+  Status if the account's password is set to never expire.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordNeverExpiresTextBox)


$Section3AccountDataPasswordNotRequiredTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataBadLogonCountTextBox.Left
    Top       = $Section3AccountDataPasswordNeverExpiresTextBox.Top + $Section3AccountDataPasswordNeverExpiresTextBox.Height + $($FormScale * 4)
    Width     = $FormScale * 220
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseHover = {
        Show-ToolTip -Title "Password Not Required" -Icon "Info" -Message @"
+  Status if the account's does not require a password.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordNotRequiredTextBox)


$Section3AccountDataMemberOfComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Left      = $Section3AccountDataBadLogonCountTextBox.Left
    Top       = $Section3AccountDataTagsComboBox.Top
    Width     = $FormScale * 220
    Height    = $FormScale * 25
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_MouseHover = {
        Show-ToolTip -Title "Member Of" -Icon "Info" -Message @"
+  The groups the account is a member of.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataMemberOfComboBox)























$Section3AccountDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add"
    Left      = $Section3AccountDataTagsComboBox.Width + $Section3AccountDataTagsComboBox.Left + $($FormScale * 5)
    Top       = $Section3AccountDataTagsComboBox.Top - $($FormScale * 1)
    Width     = $FormScale * 45
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_Click = {
        if (!($Section3AccountDataTagsComboBox.SelectedItem -eq "Tags")) {
            $Section3AccountDataNotesRichTextBox.text = "[$($Section3AccountDataTagsComboBox.SelectedItem)] " + $Section3AccountDataNotesRichTextBox.text
        }
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Add Tag to Notes" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be created and used.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataTagsAddButton)
CommonButtonSettings -Button $Section3AccountDataTagsAddButton


$Section3AccountDataNotesRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Left       = 0
    Top        = $Section3AccountDataLastBadPasswordAttemptTextBox.Top + $Section3AccountDataLastBadPasswordAttemptTextBox.Height + $($FormScale * 6)
    Width      = $FormScale * 634
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor  = 'White'
    Multiline  = $True
    ScrollBars = 'Vertical'
    WordWrap   = $True
    ReadOnly   = $false
    Add_MouseHover = {
        Show-ToolTip -Title "Host Notes" -Icon "Info" -Message @"
+  These notes are specific to the host.
+  Also can contains Tags if used.
"@
    }
    Add_MouseEnter = { Check-AccountDataIfModified }
    Add_MouseLeave = { Check-AccountDataIfModified }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataNotesRichTextBox)


$script:Section3AccountDataNotesSaveCheck = ""
$Section3AccountDataSaveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Data Saved"
    Left      = $Section3AccountDataNotesRichTextBox.Left + $Section3AccountDataNotesRichTextBox.Width + $($FormScale + 5)
    Top       = $Section3AccountDataNotesRichTextBox.Top
    Width     = $FormScale * 100
    Height    = $FormScale * 22
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_Click = {
        Save-TreeViewData -Endpoint
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Saved Host Data:  $($script:Section3AccountDataNameTextBox.Text)")            
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Warning" -Icon "Warning" -Message @"
+  It's Best practice is to manually save after modifying each host data.
+  That said, data is automatically saved when you select a endpoint in the computer treeview
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataSaveButton)
CommonButtonSettings -Button $Section3AccountDataSaveButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\Section3AccountDataNotesAddOpNotesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\Section3AccountDataNotesAddOpNotesButton.ps1"
$Section3AccountDataNotesAddOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add To OpNotes"
    Left      = $Section3AccountDataSaveButton.Left
    Top       = $Section3AccountDataSaveButton.Top + $Section3AccountDataSaveButton.Height + $($FormScale + 5)
    Width     = $FormScale * 100
    Height    = $FormScale * 22
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_Click = {
        $MainLeftTabControl.SelectedTab   = $Section1OpNotesTab
        
        if ($Section3AccountDataNotesRichTextBox.text) {
            $TimeStamp = Get-Date
            $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Host Data Notes from: $($script:Section3AccountDataNameTextBox.Text)")
            Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Host Data Notes from: $($script:Section3AccountDataNameTextBox.Text)" -Force
            foreach ( $Line in ($Section3AccountDataNotesRichTextBox.text -split "`r`n") ){
                $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line")
                Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line" -Force
            }
            Save-OpNotes
        }    
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Add Selected To OpNotes" -Icon "Info" -Message @"
+  One or more lines can be selected to add to the OpNotes.
+  The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
+  A Datetime stampe will be prefixed to the entry.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataNotesAddOpNotesButton)
CommonButtonSettings -Button $Section3AccountDataNotesAddOpNotesButton


# Checks if the Host Data has been modified and determines the text color: Green/Red
Update-FormProgress "$Dependencies\Code\Main Body\Check-AccountDataIfModified.ps1"
. "$Dependencies\Code\Main Body\Check-AccountDataIfModified.ps1"
