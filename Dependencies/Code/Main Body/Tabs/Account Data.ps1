$Section3AccountDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Account Data  "
    Name = "Account Data Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
    ImageIndex = 4
}
$InformationTabControl.Controls.Add($Section3AccountDataTab)


#############
### Row 1 ###
#############


$script:Section3AccountDataIconPictureBox= New-Object Windows.Forms.PictureBox -Property @{
    Left   = 0
    Top    = $FormScale * 3
    Width  = $FormScale * 44
    Height = $FormScale * 44
    Image  = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Accounts.png")
    SizeMode = 'StretchImage'
    Add_Click = {
        if (-not $script:NodeAccount){
            [System.Windows.Forms.MessageBox]::Show("You need to select the account in the treeview to change the icon.","PoSh-EasyWin",'Ok',"Info")
        }
        else {            
            $AccountsTreeViewChangeIconForm = New-Object system.Windows.Forms.Form -Property @{
                Text   = "PoSh-EasyWin - Change Icon"
                Width  = $FormScale * 335
                Height = $FormScale * 500
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                StartPosition = "CenterScreen"
                Add_Closing = { $This.dispose() }
            }
        
            
            $AccountsTreeViewChangeIconLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Select another icon to represent this account."
                Left   = $FormScale * 10
                Top    = $FormScale * 10
                Width  = $FormScale * 300
                Height = $FormScale * 25
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $AccountsTreeViewChangeIconForm.Controls.Add($AccountsTreeViewChangeIconLabel)
        

            $AccountsTreeViewChangeIconTreeView = New-Object System.Windows.Forms.TreeView -Property @{
                Left   = $FormScale * 10
                Top    = $AccountsTreeViewChangeIconLabel.Top + $AccountsTreeViewChangeIconLabel.Height + $($FormScale * 10)
                Width  = $FormScale * 300
                Height = $FormScale * 375
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                CheckBoxes       = $false
                ShowLines        = $True
                ShowNodeToolTips = $True
                Add_Click        = $null
                Add_AfterSelect  = {
                    $script:AccountsTreeViewChangeIconTreeViewSelected = $null
                    foreach ($Node in $This.Nodes) {
                        if ($Node.isSelected){
                            $AccountsTreeViewChangeIconPreviewPictureBox.Image = [System.Drawing.Image]::FromFile($Node.ToolTipText)
                            $script:AccountsTreeViewChangeIconTreeViewSelected = $Node.ToolTipText
                        }
                    }
                }
                Add_KeyDown = { 
                    if ($_.KeyCode -eq "Enter") { & $AccountsTreeViewChangeIconScriptBlock }
                }
                Add_MouseHover   = $null
                Add_MouseLeave   = $null
                ContextMenuStrip = $null
                ShowPlusMinus    = $true
                HideSelection    = $false
                ImageList        = $AccountsTreeViewImageList
                ImageIndex       = 1
            }
            $AccountsTreeViewChangeIconTreeView.Sort()
            $AccountsTreeViewChangeIconForm.Controls.Add($AccountsTreeViewChangeIconTreeView)
        

            $AccountsTreeViewChangeIconRootTreeNodeCount = 2
            foreach ($Icon in $script:AccountsTreeViewIconList) {
                $AccountsTreeViewChangeIconRootTreeNodeCount++
                $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
                    Text = $Icon.BaseName
                    ImageIndex  = $AccountsTreeViewChangeIconRootTreeNodeCount
                    #NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    ToolTipText = "$($Icon.FullName)"
                }
                $AccountsTreeViewChangeIconTreeView.Nodes.Add($newNode)
            }
        

            $AccountsTreeViewChangeIconScriptBlock = {
                $script:Section3AccountDataIconPictureBox.Image = [System.Drawing.Image]::FromFile("$script:AccountsTreeViewChangeIconTreeViewSelected")

                $AccountsTreeviewImageHashTable.GetEnumerator() | ForEach-Object {
                    If ("$($_.Value)" -eq "$script:AccountsTreeViewChangeIconTreeViewSelected"){
                        $script:NodeAccount.ImageIndex = $_.Key
                    }
                }

                Foreach($Account in $script:AccountsTreeViewData) {
                    if ($Account.Name -eq $script:NodeAccount.Text) {
                        $Account.ImageIndex = $script:NodeAccount.ImageIndex
                    }
                }

                $script:AccountsTreeView.Nodes.Clear()
                Initialize-TreeViewData -Accounts
                
                $script:AccountsTreeView.Nodes.Add($script:TreeNodeAccountsList)
                Foreach($Account in $script:AccountsTreeViewData) {
                    AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.CanonicalName -Entry $Account.Name -ToolTip $Account.IPv4Address -Metadata $Account
                }

                Save-TreeViewData -Accounts
                $script:AccountsTreeView.ExpandAll()

                $AccountsTreeViewChangeIconForm.Close()                
            }


            $AccountsTreeViewChangeIconButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Change Icon"
                Left   = $FormScale * 210
                Top    = $AccountsTreeViewChangeIconTreeView.Top + $AccountsTreeViewChangeIconTreeView.Height + $($FormScale * 10)
                Width  = $FormScale * 100
                Height = $FormScale * 25
                Add_Click = $AccountsTreeViewChangeIconScriptBlock
            }
            Apply-CommonButtonSettings -Button $AccountsTreeViewChangeIconButton
            $AccountsTreeViewChangeIconForm.Controls.Add($AccountsTreeViewChangeIconButton)
        

            $script:AccountsTreeViewSelectedIconPath = $null
            $AccountsTreeviewImageHashTable.GetEnumerator() | ForEach-Object {
                If ("$($_.Key)" -eq "$($script:NodeAccount.ImageIndex)"){
                    $script:AccountsTreeViewSelectedIconPath = $_.Value
                }
            }

            $AccountsTreeViewChangeIconPreviewPictureBox = New-Object Windows.Forms.PictureBox -Property @{
                Left     = $FormScale * (210 - 44 - 10)
                Top      = $AccountsTreeViewChangeIconTreeView.Top + $AccountsTreeViewChangeIconTreeView.Height
                Width    = $FormScale * 44
                Height   = $FormScale * 44
                Image    = [System.Drawing.Image]::FromFile($script:AccountsTreeViewSelectedIconPath)
                SizeMode = 'StretchImage'
            }
            $AccountsTreeViewChangeIconForm.Controls.Add($AccountsTreeViewChangeIconPreviewPictureBox)
            $AccountsTreeViewChangeIconPreviewPictureBox.BringToFront()

            $AccountsTreeViewChangeIconForm.ShowDialog()
        }
    }
}
$Section3AccountDataTab.Controls.Add($script:Section3AccountDataIconPictureBox)


$Section3AccountDataNameLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Name:'
    Left      = $script:Section3AccountDataIconPictureBox.Left + $script:Section3AccountDataIconPictureBox.Width + $($FormScale * 5)
    Top       = $FormScale * 3
    Width     = $FormScale * 50
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataNameLabel)
$Section3AccountDataNameLabel.bringtofront()


$script:Section3AccountDataNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataNameLabel.Left + $Section3AccountDataNameLabel.Width
    Top       = $FormScale * 3
    Width     = $($FormScale * 200) - $($script:Section3AccountDataIconPictureBox.Width + $($FormScale * 5))
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
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


$Section3AccountDataOULabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'OU/CN:'
    Left      = $script:Section3AccountDataIconPictureBox.Left + $script:Section3AccountDataIconPictureBox.Width + $($FormScale * 5)
    Top       = $Section3AccountDataNameLabel.Top + $Section3AccountDataNameLabel.Height
    Width     = $FormScale * 50
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataOULabel)
$Section3AccountDataOULabel.bringtofront()


$Section3AccountDataOUTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $script:Section3HostDataNameTextBox.Left
    Top       = $Section3AccountDataOULabel.Top
    Width     = $($FormScale * 200) - $($script:Section3AccountDataIconPictureBox.Width + $($FormScale * 5))
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Organizational Unit / Container Name" -Icon "Info" -Message @"
+  The OU/CN that the account belongs to.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataOUTextBox)


$Section3AccountDataCreatedLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Account Creation:'
    Left      = 0
    Top       = $Section3AccountDataOULabel.Top + $Section3AccountDataOULabel.Height
    Width     = $FormScale * 115
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataCreatedLabel)


$Section3AccountDataCreatedTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataCreatedLabel.Left + $Section3AccountDataCreatedLabel.Width
    Top       = $Section3AccountDataCreatedLabel.Top
    Width     = $FormScale * 135
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Created" -Icon "Info" -Message @"
+  When the account was created.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataCreatedTextBox)


$Section3AccountDataModifiedLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Last Modified:'
    Left      = 0
    Top       = $Section3AccountDataCreatedLabel.Top + $Section3AccountDataCreatedLabel.Height
    Width     = $FormScale * 110
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataModifiedLabel)


$Section3AccountDataModifiedTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataCreatedTextBox.Left
    Top       = $Section3AccountDataModifiedLabel.Top
    Width     = $FormScale * 135
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Modified" -Icon "Info" -Message @"
+  When the account was last modified.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataModifiedTextBox)


$Section3AccountDataLastLogonDateLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Last Logon Date:'
    Left      = $Section3AccountDataModifiedLabel.Left
    Top       = $Section3AccountDataModifiedLabel.Top + $Section3AccountDataModifiedLabel.Height
    Width     = $FormScale * 110
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLastLogonDateLabel)
$Section3AccountDataLastLogonDateLabel.bringtofront()


$Section3AccountDataLastLogonDateTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataModifiedTextBox.Left
    Top       = $Section3AccountDataLastLogonDateLabel.Top
    Width     = $FormScale * 135
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Last Logon" -Icon "Info" -Message @"
+  Whent the account was last logged on to.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLastLogonDateTextBox)


$Section3AccountDataLastBadPasswordAttemptLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Last Bad Password:'
    Left      = 0
    Top       = $Section3AccountDataLastLogonDateLabel.Top + $Section3AccountDataLastLogonDateLabel.Height
    Width     = $FormScale * 110
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLastBadPasswordAttemptLabel)
$Section3AccountDataLastBadPasswordAttemptLabel.bringtofront()


$Section3AccountDataLastBadPasswordAttemptTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataLastLogonDateTextBox.Left
    Top       = $Section3AccountDataLastBadPasswordAttemptLabel.Top
    Width     = $FormScale * 135
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Last Bad Password Attempt" -Icon "Info" -Message @"
+  Whent the account was last bad password attempt was logged.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLastBadPasswordAttemptTextBox)


#############
### Row 2 ###
#############


$Section3AccountDataEnabledLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Account is Enabled:'
    Left      = $script:Section3AccountDataNameTextBox.Left + $script:Section3AccountDataNameTextBox.Width + $($FormScale * 10)
    Top       = $FormScale * 3
    Width     = $FormScale * 170
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataEnabledLabel)
$Section3AccountDataEnabledLabel.bringtofront()


$Section3AccountDataEnabledTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataEnabledLabel.Left + $Section3AccountDataEnabledLabel.Width
    Top       = $Section3AccountDataEnabledLabel.Top
    Width     = $FormScale * 80
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Enabled" -Icon "Info" -Message @"
+  Enabled status of the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataEnabledTextBox)


$Section3AccountDataSmartCardLogonRequiredLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Smart Card Logon Required:'
    Left      = $Section3AccountDataEnabledLabel.Left
    Top       = $Section3AccountDataEnabledLabel.Top + $Section3AccountDataEnabledLabel.Height
    Width     = $FormScale * 170
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataSmartCardLogonRequiredLabel)
$Section3AccountDataSmartCardLogonRequiredLabel.bringtofront()


$Section3AccountDataSmartCardLogonRequiredTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataEnabledTextBox.Left
    Top       = $Section3AccountDataSmartCardLogonRequiredLabel.Top
    Width     = $FormScale * 80
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Smart Card Logon Required" -Icon "Info" -Message @"
+  Configuration state if a smart card logon is required for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataSmartCardLogonRequiredTextBox)


$Section3AccountDataSIDLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'SID:'
    Left      = $Section3AccountDataSmartCardLogonRequiredLabel.Left
    Top       = $Section3AccountDataSmartCardLogonRequiredLabel.Top + $Section3AccountDataSmartCardLogonRequiredLabel.Height
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataSIDLabel)
$Section3AccountDataSIDLabel.bringtofront()


$Section3AccountDataSIDTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataSIDLabel.Left + $Section3AccountDataSIDLabel.Width
    Top       = $Section3AccountDataSIDLabel.Top
    Width     = $FormScale * 175
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "SID" -Icon "Info" -Message @"
+  This is the accounts Security Identifier (SID).
+  A SID is a unique value of variable length that is used to identify a security principal (such as a security group) in Windows operating systems. SIDs that identify generic users or generic groups is well known. Their values remain constant across all operating systems.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataSIDTextBox)


$Section3AccountDataScriptPathLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Script Path:'
    Left      = $Section3AccountDataSIDLabel.Left
    Top       = $Section3AccountDataSIDLabel.Top + $Section3AccountDataSIDLabel.Height
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataScriptPathLabel)
$Section3AccountDataScriptPathLabel.bringtofront()


$Section3AccountDataScriptPathTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataScriptPathLabel.Left + $Section3AccountDataScriptPathLabel.Width
    Top       = $Section3AccountDataScriptPathLabel.Top
    Width     = $FormScale * 175
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Script Path" -Icon "Info" -Message @"
+  Configured script path for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataScriptPathTextBox)


$Section3AccountDataHomeDriveLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Home Drive:'
    Left      = $Section3AccountDataScriptPathLabel.Left
    Top       = $Section3AccountDataScriptPathLabel.Top + $Section3AccountDataScriptPathLabel.Height
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataHomeDriveLabel)
$Section3AccountDataHomeDriveLabel.bringtofront()


$Section3AccountDataHomeDriveTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataHomeDriveLabel.Left + $Section3AccountDataHomeDriveLabel.Width
    Top       = $Section3AccountDataHomeDriveLabel.Top
    Width     = $FormScale * 175
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Home Drive" -Icon "Info" -Message @"
+  Configured home drive for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataHomeDriveTextBox)


$Section3AccountDataMemberOfComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Left      = $Section3AccountDataHomeDriveLabel.Left
    Top       = $Section3AccountDataHomeDriveLabel.Top + $Section3AccountDataHomeDriveLabel.Height
    Width     = $FormScale * 250
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_MouseEnter = {
        $This.ForeColor = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Member Of" -Icon "Info" -Message @"
+  The groups the account is a member of.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataMemberOfComboBox)


#############
### Row 3 ###
#############


$Section3AccountDataLockedOutLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Account is Locked Out:'
    Left      = $Section3AccountDataSIDTextBox.Left + $Section3AccountDataSIDTextBox.Width + $($FormScale * 10)
    Top       = $FormScale * 3
    Width     = $FormScale * 145
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLockedOutLabel)
$Section3AccountDataLockedOutLabel.bringtofront()


$Section3AccountDataLockedOutTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataLockedOutLabel.Left + $Section3AccountDataLockedOutLabel.Width
    Top       = $Section3AccountDataLockedOutLabel.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Locked Out" -Icon "Info" -Message @"
+  Locked Out status of the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataLockedOutTextBox)


$Section3AccountDataBadLogonCountLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Bad Logon Count:'
    Left      = $Section3AccountDataLockedOutLabel.Left
    Top       = $Section3AccountDataLockedOutLabel.Top + $Section3AccountDataLockedOutLabel.Height
    Width     = $FormScale * 145
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataBadLogonCountLabel)
$Section3AccountDataBadLogonCountLabel.bringtofront()


$Section3AccountDataBadLogonCountTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataLockedOutTextBox.Left
    Top       = $Section3AccountDataBadLogonCountLabel.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Bad Logon Count" -Icon "Info" -Message @"
+  Number of bad logon counts for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataBadLogonCountTextBox)
                            

$Section3AccountDataPasswordExpiredLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Password Expired:'
    Left      = $Section3AccountDataBadLogonCountLabel.Left
    Top       = $Section3AccountDataBadLogonCountLabel.Top + $Section3AccountDataBadLogonCountLabel.Height
    Width     = $FormScale * 145
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordExpiredLabel)
$Section3AccountDataPasswordExpiredLabel.bringtofront()


$Section3AccountDataPasswordExpiredTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataBadLogonCountTextBox.Left
    Top       = $Section3AccountDataPasswordExpiredLabel.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Password Expired" -Icon "Info" -Message @"
+  Password expiration status for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordExpiredTextBox)


$Section3AccountDataPasswordNeverExpiresLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Password Never Expires:'
    Left      = $Section3AccountDataPasswordExpiredLabel.Left
    Top       = $Section3AccountDataPasswordExpiredLabel.Top + $Section3AccountDataPasswordExpiredLabel.Height
    Width     = $FormScale * 145
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordNeverExpiresLabel)
$Section3AccountDataPasswordNeverExpiresLabel.bringtofront()


$Section3AccountDataPasswordNeverExpiresTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataPasswordNeverExpiresLabel.Left + $Section3AccountDataPasswordNeverExpiresLabel.Width
    Top       = $Section3AccountDataPasswordNeverExpiresLabel.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Password Never Expires" -Icon "Info" -Message @"
+  Status if the account's password is set to never expire.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordNeverExpiresTextBox)


$Section3AccountDataPasswordNotRequiredLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Password Not Required:'
    Left      = $Section3AccountDataPasswordNeverExpiresLabel.Left
    Top       = $Section3AccountDataPasswordNeverExpiresLabel.Top + $Section3AccountDataPasswordNeverExpiresLabel.Height
    Width     = $FormScale * 145
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordNotRequiredLabel)
$Section3AccountDataPasswordNotRequiredLabel.bringtofront()


$Section3AccountDataPasswordNotRequiredTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3AccountDataPasswordNotRequiredLabel.Left + $Section3AccountDataPasswordNotRequiredLabel.Width
    Top       = $Section3AccountDataPasswordNotRequiredLabel.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $true
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Password Not Required" -Icon "Info" -Message @"
+  Status if the account's does not require a password.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataPasswordNotRequiredTextBox)



$Section3AccountDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Tags"
    Left      = $Section3AccountDataPasswordNotRequiredLabel.Left
    Top       = $Section3AccountDataPasswordNotRequiredLabel.Top + $Section3AccountDataPasswordNotRequiredLabel.Height
    Width     = $FormScale * 170
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseEnter = {
        $This.ForeColor = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Blue'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "List of Pre-Built Tags" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be modified, created, and used.
"@
    }
}
ForEach ($Item in $TagListFileContents) { $Section3AccountDataTagsComboBox.Items.Add($Item) }
$Section3AccountDataTab.Controls.Add($Section3AccountDataTagsComboBox)



$Section3AccountDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add"
    Left      = $Section3AccountDataTagsComboBox.Width + $Section3AccountDataTagsComboBox.Left + $($FormScale * 5)
    Top       = $Section3AccountDataTagsComboBox.Top - $($FormScale * 1)
    Width     = $FormScale * 45
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_Click = {
        if (-not ($Section3AccountDataTagsComboBox.SelectedItem -eq "Tags")) {
            $script:Section3AccountDataNotesRichTextBox.text = "$(Get-Date) -- $($Section3AccountDataTagsComboBox.SelectedItem)`n" + $script:Section3AccountDataNotesRichTextBox.text
        }
        Save-TreeViewData -Accounts
    }
    Add_MouseEnter = {}
    Add_MouseLeave = {}
    Add_MouseHover = {
        Show-ToolTip -Title "Add Tag to Notes" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be created and used.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataTagsAddButton)
Apply-CommonButtonSettings -Button $Section3AccountDataTagsAddButton


###############
# Botton Half #
###############


$script:Section3AccountDataNotesRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Left       = 0
    Top        = $Section3AccountDataLastBadPasswordAttemptTextBox.Top + $Section3AccountDataLastBadPasswordAttemptTextBox.Height + $($FormScale * 6)
    Width      = $FormScale * 740
    Height     = $FormScale * 194
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor  = 'White'
    Multiline  = $True
    ScrollBars = 'ForcedVertical'
    WordWrap   = $True
    ReadOnly   = $false
    Add_MouseHover = {
        Show-ToolTip -Title "Account Notes" -Icon "Info" -Message @"
+  These notes are specific to the Account.
+  Also can contains Tags if used.
"@
    }
    Add_MouseEnter = {
        $This.ForeColor = 'DarkRed'
        $script:Section3AccountDataNotesRichTextBoxPreSave = $This.text
        $This.text = "$(Get-Date) -- `n" + $This.text
        $script:Section3AccountDataNotesRichTextBoxSaveCheck = $This.text
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
        if ($script:Section3AccountDataNotesRichTextBoxSaveCheck -ne $This.text) {
            Save-TreeViewData -Accounts
        }
        else {
            $This.text = $script:Section3AccountDataNotesRichTextBoxPreSave
        }
    }
    Add_KeyDown    = {
        if ($_.KeyCode) {
            $This.ForeColor = 'DarkRed'
        }
    }
}
$Section3AccountDataTab.Controls.Add($script:Section3AccountDataNotesRichTextBox)
$Section3AccountDataTab.ForcedVertical()


$Section3AccountDataUpdateDataButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Update Data"
    Left      = $script:Section3AccountDataNotesRichTextBox.Left + $script:Section3AccountDataNotesRichTextBox.Width - $($FormScale * 114 + 5)
    Top       = $script:Section3AccountDataNotesRichTextBox.Top + $script:Section3AccountDataNotesRichTextBox.Height - $($FormScale * 22 + 5)
    Width     = $FormScale * 100
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_Click = {
        $ADAccount = $script:Section3AccountDataNameTextBox.text

        $Verify = [System.Windows.Forms.MessageBox]::Show(
            "Do you want to pull updated data for the account `"$($ADAccount)`" from Active Directory?",
            "PoSh-EasyWin - high101bro",
            'YesNo',
            "Warning")
        switch ($Verify) {
            'Yes'{
                if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                    $Username = $script:Credential.UserName
                    $Password = '"PASSWORD HIDDEN"'
        
                    ### TODO: put in addition checks that prompt if this file is not populated or notifies the user of the AD server used
                    if (Get-Content $script:ActiveDirectoryEndpoint) { $ImportFromADWinRMManuallEntryTextBoxTarget = Get-Content $script:ActiveDirectoryEndpoint }
        
                    $script:UpdatedADAccountInfo = Invoke-Command -ScriptBlock {
                        param ($ADAccount)
                        Get-ADUser -Filter {Name -eq $ADAccount} -Properties Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                    } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -Credential $script:Credential -ArgumentList @($ADAccount,$null)
                    
                    foreach ($Account in $script:AccountsTreeViewData) {
                        if ($Account.Name -eq $ADAccount){
                            $Account | Add-Member -MemberType NoteProperty -Name SID                    -Value $script:UpdatedADAccountInfo.SID -Force
                            $Account | Add-Member -MemberType NoteProperty -Name Enabled                -Value $script:UpdatedADAccountInfo.Enabled -Force
                            $Account | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $script:UpdatedADAccountInfo.LockedOut -Force
                            $Account | Add-Member -MemberType NoteProperty -Name Created                -Value $script:UpdatedADAccountInfo.Created -Force
                            $Account | Add-Member -MemberType NoteProperty -Name Modified               -Value $script:UpdatedADAccountInfo.Modified -Force
                            $Account | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $script:UpdatedADAccountInfo.LastLogonDate -Force
                            $Account | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $script:UpdatedADAccountInfo.LastBadPasswordAttempt -Force
                            $Account | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $script:UpdatedADAccountInfo.BadLogonCount -Force
                            $Account | Add-Member -MemberType NoteProperty -Name PasswordLastSet        -Value $script:UpdatedADAccountInfo.PasswordLastSet -Force
                            $Account | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $script:UpdatedADAccountInfo.PasswordExpired -Force
                            $Account | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $script:UpdatedADAccountInfo.PasswordNeverExpires -Force
                            $Account | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $script:UpdatedADAccountInfo.PasswordNotRequired -Force
                            $Account | Add-Member -MemberType NoteProperty -Name CanonicalName          -Value "/$($script:UpdatedADAccountInfo.CanonicalName | Split-Path -Parent | Split-Path -Leaf)" -Force
                            $Account | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $(($script:UpdatedADAccountInfo | Select-Object -ExpandProperty MemberOf) -join "`n") -Force
                            $Account | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $script:UpdatedADAccountInfo.SmartCardLogonRequired -Force
                            $Account | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $script:UpdatedADAccountInfo.ScriptPath -Force
                            $Account | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $script:UpdatedADAccountInfo.HomeDrive -Force
                            $Account | Add-Member -MemberType NoteProperty -Name Notes                  -Value $("$(Get-Date) -- Pulled Updated Account Data`n" + $script:Section3AccountDataNotesRichTextBox.text) -Force
                        }
                    }

                    # Yep, needed to update treeview before saving
                    Update-TreeViewData -Accounts -TreeView $script:AccountsTreeView.Nodes

                    Normalize-TreeViewData -Accounts
                    Save-TreeViewData -Accounts -SkipTextFieldSave

                    # Yep, needed to reload the data in the Accounts tab
                    Update-TreeViewData -Accounts -TreeView $script:AccountsTreeView.Nodes

                    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Generate-NewRollingPassword
                    }               
        
                    #$script:UpdatedADAccountInfo | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text) -Credential [ $UserName | $Password ]"
                }
                else {
                    ### TODO: put in addition checks that prompt if this file is not populated or notifies the user of the AD server used
                    if (Get-Content $script:ActiveDirectoryEndpoint) { $ImportFromADWinRMManuallEntryTextBoxTarget = Get-Content $script:ActiveDirectoryEndpoint }
        
                    $script:UpdatedADAccountInfo = Invoke-Command -ScriptBlock {
                        param ($ADAccount)
                        Get-ADUser -Filter {Name -eq $ADAccount} -Properties Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive
                    } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -ArgumentList @($ADAccount,$null)
                    
                    foreach ($Account in $script:AccountsTreeViewData) {
                        if ($Account.Name -eq $ADAccount){
                            $Account | Add-Member -MemberType NoteProperty -Name SID                    -Value $script:UpdatedADAccountInfo.SID -Force
                            $Account | Add-Member -MemberType NoteProperty -Name Enabled                -Value $script:UpdatedADAccountInfo.Enabled -Force
                            $Account | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $script:UpdatedADAccountInfo.LockedOut -Force
                            $Account | Add-Member -MemberType NoteProperty -Name Created                -Value $script:UpdatedADAccountInfo.Created -Force
                            $Account | Add-Member -MemberType NoteProperty -Name Modified               -Value $script:UpdatedADAccountInfo.Modified -Force
                            $Account | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $script:UpdatedADAccountInfo.LastLogonDate -Force
                            $Account | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $script:UpdatedADAccountInfo.LastBadPasswordAttempt -Force
                            $Account | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $script:UpdatedADAccountInfo.BadLogonCount -Force
                            $Account | Add-Member -MemberType NoteProperty -Name PasswordLastSet        -Value $script:UpdatedADAccountInfo.PasswordLastSet -Force
                            $Account | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $script:UpdatedADAccountInfo.PasswordExpired -Force
                            $Account | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $script:UpdatedADAccountInfo.PasswordNeverExpires -Force
                            $Account | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $script:UpdatedADAccountInfo.PasswordNotRequired -Force
                            $Account | Add-Member -MemberType NoteProperty -Name CanonicalName          -Value "/$($script:UpdatedADAccountInfo.CanonicalName | Split-Path -Parent | Split-Path -Leaf)" -Force
                            $Account | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $(($script:UpdatedADAccountInfo | Select-Object -ExpandProperty MemberOf) -join "`n") -Force
                            $Account | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $script:UpdatedADAccountInfo.SmartCardLogonRequired -Force
                            $Account | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $script:UpdatedADAccountInfo.ScriptPath -Force
                            $Account | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $script:UpdatedADAccountInfo.HomeDrive -Force
                            $Account | Add-Member -MemberType NoteProperty -Name Notes                  -Value $("$(Get-Date) -- Pulled Updated Account Data`n" + $script:Section3AccountDataNotesRichTextBox.text) -Force
                        }
                    }

                    # Yep, needed to update treeview before saving
                    Update-TreeViewData -Accounts -TreeView $script:AccountsTreeView.Nodes

                    Normalize-TreeViewData -Accounts
                    Save-TreeViewData -Accounts -SkipTextFieldSave

                    # Yep, needed to reload the data in the Accounts tab
                    Update-TreeViewData -Accounts -TreeView $script:AccountsTreeView.Nodes

                    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Generate-NewRollingPassword
                    }               
        
                    #$script:UpdatedADAccountInfo | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text)"
                }
            }
            'No' {continue}
        }
    }
    Add_MouseEnter = {}
    Add_MouseLeave = {}
    Add_MouseHover = {
        Show-ToolTip -Title "Update Account Data From Active Directory" -Icon "Info" -Message @"
+  This will query Active Directory and pull any updated information for the account.
"@
    }
}
$Section3AccountDataTab.Controls.Add($Section3AccountDataUpdateDataButton)
$Section3AccountDataUpdateDataButton.bringtofront()
Apply-CommonButtonSettings -Button $Section3AccountDataUpdateDataButton

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUV1ZAjaHkGL1VIoxxzxfz0QSH
# rSWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUnv8tbNc5RHCWEurbOHviBKkMU0UwDQYJKoZI
# hvcNAQEBBQAEggEARgG0CoV6mKJkXTXknITYKTq1SXymlphMroFJeB5ens92Xbt0
# iPFep26ce0gI3YF07UPaY4iLocDwEcf067PyjEOPL5KRAHif4mjpucyAMI6EIUMv
# 3P3EXX0qqfEzLXfIcA6nIahkNX53wSxSziBGyexr0hiU/LmyKTihE+g20o45bZS+
# EtYFOiuz5spVv8E8kw9ZVqKm7A+odzTlbLZjYKknuKAB/lvjLK3O7kh74LsEhBhT
# z/HNlo+fJcSLK9XG0P6+K4ggaFCCKDAbS3UQCu37Nl2l70AzCTU2Ia2NQ04vy3y+
# PwPYSvdMjFTlI4tm1NAHKT2KjBNeoDdEL6GbxA==
# SIG # End signature block
