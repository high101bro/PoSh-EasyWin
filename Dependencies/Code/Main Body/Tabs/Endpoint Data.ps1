$Section3HostDataTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Endpoint Data  "
    Name = "Host Data Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
    ImageIndex = 3
}
$InformationTabControl.Controls.Add($Section3HostDataTab)


#############
### Row 1 ###
#############

$script:Section3EndpointDataIconPictureBox = New-Object Windows.Forms.PictureBox -Property @{
    Left   = 0
    Top    = $FormScale * 3
    Width  = $FormScale * 44
    Height = $FormScale * 44
    Image  = [System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Endpoint-Default.png")
    SizeMode = 'StretchImage'
    Add_Click = {
        if (-not $script:NodeEndpoint){
            [System.Windows.Forms.MessageBox]::Show("You need to select the endpoint in the treeview to change the icon.","PoSh-EasyWin",'Ok',"Info")
        }
        else {            
            $ComputerTreeViewChangeIconForm = New-Object system.Windows.Forms.Form -Property @{
                Text   = "PoSh-EasyWin - Change Icon"
                Width  = $FormScale * 335
                Height = $FormScale * 500
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
                StartPosition = "CenterScreen"
                Add_Closing = { $This.dispose() }
            }
        
        
            $ComputerTreeViewChangeIconLabel = New-Object System.Windows.Forms.Label -Property @{
                Text   = "Select another icon to represent this endpoint."
                Left   = $FormScale * 10
                Top    = $FormScale * 10
                Width  = $FormScale * 300
                Height = $FormScale * 25
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $ComputerTreeViewChangeIconForm.Controls.Add($ComputerTreeViewChangeIconLabel)
        

            $ComputerTreeViewChangeIconTreeView = New-Object System.Windows.Forms.TreeView -Property @{
                Left   = $FormScale * 10
                Top    = $ComputerTreeViewChangeIconLabel.Top + $ComputerTreeViewChangeIconLabel.Height + $($FormScale * 10)
                Width  = $FormScale * 300
                Height = $FormScale * 375
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                CheckBoxes       = $false
                ShowLines        = $True
                ShowNodeToolTips = $True
                Add_Click        = $null
                Add_AfterSelect  = {
                    $script:ComputerTreeViewChangeIconTreeViewSelected = $null
                    foreach ($Node in $This.Nodes) {
                        if ($Node.isSelected){
                            $ComputerTreeViewChangeIconPreviewPictureBox.Image = [System.Drawing.Image]::FromFile($Node.ToolTipText)
                            $script:ComputerTreeViewChangeIconTreeViewSelected = $Node.ToolTipText
                        }
                    }
                }
                Add_KeyDown = { 
                    if ($_.KeyCode -eq "Enter") { & $ComputerTreeViewChangeIconScriptBlock }
                }
                Add_MouseHover   = $null
                Add_MouseLeave   = $null
                ContextMenuStrip = $null
                ShowPlusMinus    = $true
                HideSelection    = $false
                ImageList        = $ComputerTreeviewImageList
                ImageIndex       = 1
            }
            $ComputerTreeViewChangeIconTreeView.Sort()
            $ComputerTreeViewChangeIconForm.Controls.Add($ComputerTreeViewChangeIconTreeView)
        

            $ComputerTreeViewChangeIconRootTreeNodeCount = 16 #$script:EndpointTreeviewImageHashTableCount
            foreach ($Icon in $script:ComputerTreeViewIconList) {
                $ComputerTreeViewChangeIconRootTreeNodeCount++
                $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
                    Text = $Icon.BaseName
                    ImageIndex  = $ComputerTreeViewChangeIconRootTreeNodeCount
                    #NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    ToolTipText = "$($Icon.FullName)"
                }
                $ComputerTreeViewChangeIconTreeView.Nodes.Add($newNode)
            }

        
            $ComputerTreeViewChangeIconScriptBlock = {
                $script:Section3EndpointDataIconPictureBox.Image = [System.Drawing.Image]::FromFile($script:ComputerTreeViewChangeIconTreeViewSelected)
                    
                $EndpointTreeviewImageHashTable.GetEnumerator() | ForEach-Object {
                    If ("$($_.Value)" -eq "$script:ComputerTreeViewChangeIconTreeViewSelected"){
                        $script:NodeEndpoint.ImageIndex = $_.Key
                    }
                }

                Foreach($Computer in $script:ComputerTreeViewData) {
                    if ($Computer.Name -eq $script:NodeEndpoint.Text) {
                        $Computer.ImageIndex = $script:NodeEndpoint.ImageIndex
                    }
                }

                $script:ComputerTreeView.Nodes.Clear()
                Initialize-TreeViewData -Endpoint
             
                $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList)
                Foreach($Computer in $script:ComputerTreeViewData) {
                    AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address -Metadata $Computer
                }
                Save-TreeViewData -Endpoint
                $script:ComputerTreeView.ExpandAll()

                $ComputerTreeViewChangeIconForm.Close()
            }


            $ComputerTreeViewChangeIconButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Change Icon"
                Left   = $FormScale * 210
                Top    = $ComputerTreeViewChangeIconTreeView.Top + $ComputerTreeViewChangeIconTreeView.Height + $($FormScale * 10)
                Width  = $FormScale * 100
                Height = $FormScale * 25
                Add_Click = $ComputerTreeViewChangeIconScriptBlock
            }
            Apply-CommonButtonSettings -Button $ComputerTreeViewChangeIconButton
            $ComputerTreeViewChangeIconForm.Controls.Add($ComputerTreeViewChangeIconButton)
        

            $script:EndpointTreeViewSelectedIconPath = $null
            $EndpointTreeviewImageHashTable.GetEnumerator() | ForEach-Object {
                If ("$($_.Key)" -eq "$($script:NodeEndpoint.ImageIndex)"){
                    $script:EndpointTreeViewSelectedIconPath = $_.Value
                }
            }

            $ComputerTreeViewChangeIconPreviewPictureBox = New-Object Windows.Forms.PictureBox -Property @{
                Left     = $FormScale * (210 - 44 - 10)
                Top      = $ComputerTreeViewChangeIconTreeView.Top + $ComputerTreeViewChangeIconTreeView.Height
                Width    = $FormScale * 44
                Height   = $FormScale * 44
                Image    = [System.Drawing.Image]::FromFile($script:EndpointTreeViewSelectedIconPath)
                SizeMode = 'StretchImage'
            }
            $ComputerTreeViewChangeIconForm.Controls.Add($ComputerTreeViewChangeIconPreviewPictureBox)
            $ComputerTreeViewChangeIconPreviewPictureBox.BringToFront()

            $ComputerTreeViewChangeIconForm.ShowDialog()
        }
    }
}
$Section3HostDataTab.Controls.Add($script:Section3EndpointDataIconPictureBox)


$Section3EndpointDataNameLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Name:'
    Left      = $script:Section3EndpointDataIconPictureBox.Left + $script:Section3EndpointDataIconPictureBox.Width + $($FormScale * 5)
    Top       = $FormScale * 3
    Width     = $FormScale * 50
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataNameLabel)
$Section3EndpointDataNameLabel.bringtofront()


$script:Section3HostDataNameTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataNameLabel.Left + $Section3EndpointDataNameLabel.Width
    Top       = $FormScale * 3
    Width     = $($FormScale * 200) - $($script:Section3EndpointDataIconPictureBox.Width + $($FormScale * 5))
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
        Show-ToolTip -Title "Hostname" -Icon "Info" -Message @"
+  This field is reserved for the hostname.
+  Hostnames are not case sensitive.
+  Though IP addresses may be entered, WinRM queries may fail as
    IPs may only be used for authentication under certain conditions.
"@
    }
}
$Section3HostDataTab.Controls.Add($script:Section3HostDataNameTextBox)


$Section3EndpointDataOULabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'OU/CN:'
    Left      = $script:Section3EndpointDataIconPictureBox.Left + $script:Section3EndpointDataIconPictureBox.Width + $($FormScale * 5)
    Top       = $Section3EndpointDataNameLabel.Top + $Section3EndpointDataNameLabel.Height
    Width     = $FormScale * 50
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataOULabel)
$Section3EndpointDataOULabel.bringtofront()


$Section3HostDataOUTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $script:Section3HostDataNameTextBox.Left
    Top       = $Section3EndpointDataOULabel.Top
    Width     = $($FormScale * 200) - $($script:Section3EndpointDataIconPictureBox.Width + $($FormScale * 5))
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
+  This field is useful to view groupings of hosts by OU/CN.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataOUTextBox)


$Section3EndpointDataCreatedLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Endpoint Creation:'
    Left      = 0
    Top       = $Section3EndpointDataOULabel.Top + $Section3EndpointDataOULabel.Height
    Width     = $FormScale * 115
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataCreatedLabel)


$Section3EndpointDataCreatedTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataCreatedLabel.Left + $Section3EndpointDataCreatedLabel.Width
    Top       = $Section3EndpointDataCreatedLabel.Top
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
$Section3HostDataTab.Controls.Add($Section3EndpointDataCreatedTextBox)


$Section3EndpointDataModifiedLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Last Modified:'
    Left      = 0
    Top       = $Section3EndpointDataCreatedLabel.Top + $Section3EndpointDataCreatedLabel.Height
    Width     = $FormScale * 110
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataModifiedLabel)


$Section3EndpointDataModifiedTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataCreatedTextBox.Left
    Top       = $Section3EndpointDataModifiedLabel.Top
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
+  When the endpoint was last modified.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataModifiedTextBox)


$Section3EndpointDataLastLogonDateLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Last Logon Date:'
    Left      = $Section3EndpointDataModifiedLabel.Left
    Top       = $Section3EndpointDataModifiedLabel.Top + $Section3EndpointDataModifiedLabel.Height
    Width     = $FormScale * 110
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataLastLogonDateLabel)
$Section3EndpointDataLastLogonDateLabel.bringtofront()


$Section3EndpointDataLastLogonDateTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataModifiedTextBox.Left
    Top       = $Section3EndpointDataLastLogonDateLabel.Top
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
$Section3HostDataTab.Controls.Add($Section3EndpointDataLastLogonDateTextBox)


$Section3HostDataIPLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'IPv4:   [Editable]'
    Left      = 0
    Top       = $Section3EndpointDataLastLogonDateLabel.Top + $Section3EndpointDataLastLogonDateLabel.Height
    Width     = $FormScale * 110
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3HostDataIPLabel)
$Section3HostDataIPLabel.bringtofront()


$Section3HostDataIPTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataLastLogonDateTextBox.Left
    Top       = $Section3HostDataIPLabel.Top
    Width     = $FormScale * 135
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $false
    Add_MouseHover = {
        Show-ToolTip -Title "IP Address" -Icon "Info" -Message @"
+  Informational field not used to query hosts.
"@
    }
    Add_MouseEnter = {
        $This.ForeColor = 'DarkRed'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
        Save-TreeViewData -Endpoint
    }
    Add_KeyDown    = {
        if ($_.KeyCode) {
            $This.ForeColor = 'DarkRed'
        }
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataIPTextBox)


$Section3HostDataMACLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'MAC:  [Editable]'
    Left      = 0
    Top       = $Section3HostDataIPLabel.Top + $Section3HostDataIPLabel.Height
    Width     = $FormScale * 110
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3HostDataMACLabel)
$Section3HostDataMACLabel.bringtofront()


$Section3HostDataMACTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3HostDataIPTextBox.Left
    Top       = $Section3HostDataMACLabel.Top
    Width     = $FormScale * 135
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ReadOnly  = $false
    Add_MouseHover = {
        Show-ToolTip -Title "MAC Address" -Icon "Info" -Message @"
+  MAC Address as recorded by Active Directory or manually entered.
"@
    }
    Add_MouseEnter = {
        $This.ForeColor = 'DarkRed'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
        Save-TreeViewData -Endpoint
    }
    Add_KeyDown    = {
        if ($_.KeyCode) {
            $This.ForeColor = 'DarkRed'
        }
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataMACTextBox)


#############
### Row 2 ###
#############


$Section3EndpointDataEnabledLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Endpoint is Enabled:'
    Left      = $script:Section3HostDataNameTextBox.Left + $script:Section3HostDataNameTextBox.Width + $($FormScale * 10)
    Top       = $FormScale * 3
    Width     = $FormScale * 170
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataEnabledLabel)
$Section3EndpointDataEnabledLabel.bringtofront()


$Section3EndpointDataEnabledTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataEnabledLabel.Left + $Section3EndpointDataEnabledLabel.Width
    Top       = $Section3EndpointDataEnabledLabel.Top
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
$Section3HostDataTab.Controls.Add($Section3EndpointDataEnabledTextBox)


$Section3EndpointDataisCriticalSystemObjectLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Critical System Object:'
    Left      = $Section3EndpointDataEnabledLabel.Left
    Top       = $Section3EndpointDataEnabledLabel.Top + $Section3EndpointDataEnabledLabel.Height
    Width     = $FormScale * 170
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataisCriticalSystemObjectLabel)
$Section3EndpointDataisCriticalSystemObjectLabel.bringtofront()


$Section3EndpointDataisCriticalSystemObjectTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataEnabledTextBox.Left
    Top       = $Section3EndpointDataisCriticalSystemObjectLabel.Top
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
$Section3HostDataTab.Controls.Add($Section3EndpointDataisCriticalSystemObjectTextBox)


$Section3EndpointDataSIDLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'SID:'
    Left      = $Section3EndpointDataisCriticalSystemObjectLabel.Left
    Top       = $Section3EndpointDataisCriticalSystemObjectLabel.Top + $Section3EndpointDataisCriticalSystemObjectLabel.Height
    Width     = $FormScale * 45
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataSIDLabel)
$Section3EndpointDataSIDLabel.bringtofront()


$Section3EndpointDataSIDTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataSIDLabel.Left + $Section3EndpointDataSIDLabel.Width
    Top       = $Section3EndpointDataSIDLabel.Top
    Width     = $FormScale * 205
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
+  This is the endpoint Security Identifier (SID).
+  A SID is a unique value of variable length that is used to identify a security principal (such as a security group) in Windows operating systems. SIDs that identify generic users or generic groups is well known. Their values remain constant across all operating systems.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataSIDTextBox)


$Section3EndpointDataOperatingSystemLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'OS:'
    Left      = $Section3EndpointDataSIDLabel.Left
    Top       = $Section3EndpointDataSIDLabel.Top + $Section3EndpointDataSIDLabel.Height
    Width     = $FormScale * 45
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataOperatingSystemLabel)
$Section3EndpointDataOperatingSystemLabel.bringtofront()


$Section3EndpointDataOperatingSystemTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataOperatingSystemLabel.Left + $Section3EndpointDataOperatingSystemLabel.Width
    Top       = $Section3EndpointDataOperatingSystemLabel.Top
    Width     = $FormScale * 205
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
$Section3HostDataTab.Controls.Add($Section3EndpointDataOperatingSystemTextBox)


$Section3EndpointDataOperatingSystemHotfixComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Left      = $Section3EndpointDataOperatingSystemLabel.Left
    Top       = $Section3EndpointDataLastLogonDateTextBox.Top
    Width     = $FormScale * 250
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Operating System Hotfix" -Icon "Info" -Message @"
+  Operating System Hotfixes on the endpoint.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataOperatingSystemHotfixComboBox)


$Section3EndpointDataOperatingSystemServicePackComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Left      = $Section3EndpointDataOperatingSystemHotfixComboBox.Left
    Top       = $Section3HostDataIPTextBox.Top
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
        Show-ToolTip -Title "Operating System Service Pack" -Icon "Info" -Message @"
+  Operating System Service Packs on the endpoint.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataOperatingSystemServicePackComboBox)


$Section3EndpointDataMemberOfComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Left      = $Section3EndpointDataOperatingSystemServicePackComboBox.Left
    Top       = $Section3HostDataMACTextBox.Top
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
$Section3HostDataTab.Controls.Add($Section3EndpointDataMemberOfComboBox)


#############
### Row 3 ###
#############


$Section3EndpointDataLockedOutLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Account is Locked Out:'
    Left      = $Section3EndpointDataSIDTextBox.Left + $Section3EndpointDataSIDTextBox.Width + $($FormScale * 10)
    Top       = $FormScale * 3
    Width     = $FormScale * 145
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataLockedOutLabel)
$Section3EndpointDataLockedOutLabel.bringtofront()


$Section3EndpointDataLockedOutTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataLockedOutLabel.Left + $Section3EndpointDataLockedOutLabel.Width
    Top       = $Section3EndpointDataLockedOutLabel.Top
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
$Section3HostDataTab.Controls.Add($Section3EndpointDataLockedOutTextBox)


$Section3EndpointDataLogonCountLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Successful Logon Count:'
    Left      = $Section3EndpointDataLockedOutLabel.Left
    Top       = $Section3EndpointDataLockedOutLabel.Top + $Section3EndpointDataLockedOutLabel.Height
    Width     = $FormScale * 145
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataLogonCountLabel)
$Section3EndpointDataLogonCountLabel.bringtofront()


$Section3EndpointDataLogonCountTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Left      = $Section3EndpointDataLockedOutTextBox.Left
    Top       = $Section3EndpointDataLogonCountLabel.Top
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
        Show-ToolTip -Title "Logon Count" -Icon "Info" -Message @"
+  Number of logon counts for the endpoint.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataLogonCountTextBox)
                            

$Section3EndpointDataPortScanLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = 'Enumeration (Port Scan):'
    Left      = $Section3EndpointDataLogonCountLabel.Left
    Top       = $Section3EndpointDataLogonCountLabel.Top + $Section3EndpointDataLogonCountLabel.Height
    Width     = $FormScale * 145
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataPortScanLabel)
$Section3EndpointDataPortScanLabel.bringtofront()


$Section3EndpointDataPortScanComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Left      = $Section3EndpointDataPortScanLabel.Left + $Section3EndpointDataPortScanLabel.Width
    Top       = $Section3EndpointDataPortScanLabel.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ForeColor = "Black"
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseEnter = {
        $This.ForeColor    = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor    = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Port Scans (Listening)" -Icon "Info" -Message @"
+  Contains a list of the results from the most recent port scan.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataPortScanComboBox)


$script:ArrowUpAndDownMessageBoxStatus = $true
$HostDataList1 = (Get-ChildItem -Path $CollectedDataDirectory -Recurse | Where-Object {$_.Extension -match 'csv'}).basename | ForEach-Object { $_.split('(')[0].trim() } | Sort-Object -Unique -Descending
$Section3HostDataSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Host Data - Selection"
    Left      = $Section3EndpointDataPortScanLabel.Left
    Top       = $Section3EndpointDataOperatingSystemTextBox.Top
    Width     = $FormScale * 220
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ForeColor = "Black"
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    DataSource         = $HostDataList1
    Add_Click = {
        $This.DataSource = (Get-ChildItem -Path $CollectedDataDirectory -Recurse | Where-Object {$_.Extension -match 'csv'}).basename | ForEach-Object { $_.split('(')[0].trim() } | Sort-Object -Unique -Descending
    }
    Add_MouseEnter = {
        $This.ForeColor = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Select Search Topic" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed below.
+  These files can be searchable, toggle in Options Tab.
+  Note: Datetimes with more than one collection type won't
display, these results will need to be navigated to manually.
"@            
    }
    Add_SelectedIndexChanged = {
        function Get-HostDataCsvResults {
            param(
                [string]$ComboxInput
            )
            # Searches though the all Collection Data Directories to find files that match
            $ListOfCollectedDataDirectories = $null
            $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory | Sort-Object -Descending).FullName
            $script:CSVFileMatch = @()
            foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
                $CSVFiles = Get-ChildItem -Path $CollectionDir -Recurse | Where-Object {$_.Extension -match 'csv'}
                foreach ($CSVFile in $CSVFiles) {
                    # Searches for the CSV file that matches the data selected
                    if ($CSVFile.BaseName -like "*$($ComboxInput)*") {
                        $CsvComputerNameList = Import-Csv $CSVFile.FullName | Select-Object -Property ComputerName -Unique
                        foreach ($computer in $CsvComputerNameList){
                            if ("$computer" -match "$($script:Section3HostDataNameTextBox.Text)"){
                                $script:CSVFileMatch += $CSVFile.Name
                            }
                        }
                    }
                }
            }
        }
    
        Get-HostDataCsvResults -ComboxInput $This.SelectedItem
    
        $Section3HostDataSelectionDateTimeComboBox.DataSource = $null
        if (($script:CSVFileMatch).count -eq 0) {
            $Section3HostDataSelectionDateTimeComboBox.DataSource = @('No Unique Data Available')
        }
        else {
            $Section3HostDataSelectionDateTimeComboBox.DataSource = $script:CSVFileMatch | Sort-Object -Descending
        }
    }
    Add_KeyDown = {
        if ($script:ArrowUpAndDownMessageBoxStatus) {
            if ($_.KeyCode -eq 'Down' -or $_.KeyCode -eq 'Up') {
                $script:ArrowUpAndDownMessageBoxStatus = $false
                [System.Windows.Forms.MessageBox]::Show('Avoid using the arrow keys, as it automatically searches for matching csv files. This can cause the tools to hang if arrowing too fast. Instead, use the mouse to select the desired field.',"PoSh-EasyWin",'Ok',"Warning")
            }
        }
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataSelectionComboBox)


$Section3HostDataSelectionDateTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Host Data - Date & Time"
    Left      = $Section3HostDataSelectionComboBox.Left
    Top       = $Section3EndpointDataOperatingSystemHotfixComboBox.top
    Width     = $FormScale * 220
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    ForeColor = "Black"
    AutoCompleteSource = "ListItems"
    AutoCompleteMode = "SuggestAppend"
    Add_MouseEnter = {
        $This.ForeColor = 'Blue'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Datetime of Results" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed.
+  These files can be searchable, toggle in Options Tab.
+  Note: Datetimes with more than one collection type won't
display, these results will need to be navigated to manually.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataSelectionDateTimeComboBox)


$Section3HostDataGridViewButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Grid View"
    Left      = $Section3HostDataSelectionDateTimeComboBox.Left #+ $($FormScale * 64)
    Top       = $Section3HostDataIPTextBox.Top - $($FormScale * 4)
    Width     = $FormScale * 110
    Height    = $FormScale * 22
    Add_Click = {
        # Chooses the most recent file if multiple exist
        $CSVFileToImport = (Get-ChildItem -File -Path $CollectedDataDirectory -Recurse | Where-Object {$_.name -like $Section3HostDataSelectionDateTimeComboBox.SelectedItem}).Fullname
        $HostData = Import-Csv $CSVFileToImport
        if ($HostData) {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Showing Results:  $HostDataSection")
            $HostData | Out-GridView -Title 'PoSh-EasyWin: Collected Data' -OutputMode Multiple | Set-Variable -Name HostDataResultsSection

            # Adds Out-GridView selected Host Data to OpNotes
            foreach ($Selection in $HostDataResultsSection) {
                $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $HostDataSection - $($Selection -replace '@{','' -replace '}','')")
                Add-Content -Path $OpNotesWriteOnlyFile -Value ($OpNotesListBox.SelectedItems) -Force
            }
            Save-OpNotes
        }
        else {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("No Unique Data Available:  $HostDataSection")
            # Sounds a chime if there is not data
            [system.media.systemsounds]::Exclamation.play()
        }
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Get Data" -Icon "Info" -Message @"
+  If data exists, the datetime group will be displayed.
+  These files can be searchable, toggle in Options Tab.
+  Note: If datetimes don't show contents, it may be due to multiple results.
If this is the case, navigate to the csv file manually.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataGridViewButton)
Apply-CommonButtonSettings -Button $Section3HostDataGridViewButton


if ((Test-Path -Path "$Dependencies\Modules\PSWriteHTML") -and (Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'Yes') {
    $Section3HostDataPSWriteHTMLButton = New-Object System.Windows.Forms.Button -Property @{
        Text      = "HTML"
        Left      = $Section3HostDataGridViewButton.Left + $Section3HostDataGridViewButton.Width + $($FormScale * 5)
        Top       = $Section3HostDataGridViewButton.Top
        Width     = $FormScale * 105
        Height    = $FormScale * 22
        Add_Click = {
            # Chooses the most recent file if multiple exist
            $CSVFileToImport = (Get-ChildItem -File -Path $CollectedDataDirectory -Recurse | Where-Object {$_.name -like $Section3HostDataSelectionDateTimeComboBox.SelectedItem}).Fullname
            $HostData = Import-Csv $CSVFileToImport
            if ($HostData) {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Showing Results:  $HostDataSection")
                $HostData | Out-HTMLView -Title "$($CSVFileToImport | Split-Path -Leaf)"
            }
            else {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("No Unique Data Available:  $HostDataSection")
                # Sounds a chime if there is not data
                [system.media.systemsounds]::Exclamation.play()
            }
        }
    }
    $Section3HostDataTab.Controls.Add($Section3HostDataPSWriteHTMLButton)
    Apply-CommonButtonSettings -Button $Section3HostDataPSWriteHTMLButton    
}


$Section3EndpointDataTagsComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Text      = "Tags"
    Left      = $Section3HostDataSelectionDateTimeComboBox.Left
    Top       = $Section3HostDataMACTextBox.Top
    Width     = $FormScale * 170
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    AutoCompleteSource = "ListItems"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseEnter = {
        $This.ForeColor = 'DarkRed'
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
    }
    Add_MouseHover = {
        Show-ToolTip -Title "List of Pre-Built Tags" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be modified, created, and used.
"@
    }
}
ForEach ($Item in $TagListFileContents) { $Section3EndpointDataTagsComboBox.Items.Add($Item) }
$Section3HostDataTab.Controls.Add($Section3EndpointDataTagsComboBox)


$Section3EndpointDataTagsAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Add"
    Left      = $Section3EndpointDataTagsComboBox.Width + $Section3EndpointDataTagsComboBox.Left + $($FormScale * 5)
    Top       = $Section3EndpointDataTagsComboBox.Top - $($FormScale * 1)
    Width     = $FormScale * 45
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_Click = {
        if (-not ($Section3HostDataTagsComboBox.SelectedItem -eq "Tags")) {
            $Section3HostDataNotesRichTextBox.text = "$(Get-Date) -- $($Section3HostDataTagsComboBox.SelectedItem)`n" + $Section3HostDataNotesRichTextBox.text
        }
        Save-TreeViewData -Endpoint
    }
    Add_MouseHover = {
        Show-ToolTip -Title "Add Tag to Notes" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be created and used.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataTagsAddButton)
Apply-CommonButtonSettings -Button $Section3EndpointDataTagsAddButton


###############
# Botton Half #
###############


$Section3HostDataNotesRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
    Left       = 0
    Top        = $Section3HostDataMACLabel.Top + $Section3HostDataMACLabel.Height
    Width      = $FormScale * 740
    Height     = $FormScale * 172
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
        $script:Section3EndpointDataNotesRichTextBoxPreSave = $This.text
        $This.text = "$(Get-Date) -- `n" + $This.text
        $script:Section3EndpointDataNotesRichTextBoxSaveCheck = $This.text
    }
    Add_MouseLeave = {
        $This.ForeColor = 'Black'
        if ($script:Section3EndpointDataNotesRichTextBoxSaveCheck -ne $This.text) {
            Save-TreeViewData -Endpoint
        }
        else {
            $This.text = $script:Section3EndpointDataNotesRichTextBoxPreSave
        }
    }
    Add_KeyDown    = {
        if ($_.KeyCode) {
            $This.ForeColor = 'DarkRed'
        }
    }
}
$Section3HostDataTab.Controls.Add($Section3HostDataNotesRichTextBox)
$Section3HostDataTab.ForcedVertical()


$Section3EndpointDataUpdateDataButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "Update Data"
    Left      = $Section3HostDataNotesRichTextBox.Left + $Section3HostDataNotesRichTextBox.Width - $($FormScale * 114 + 5)
    Top       = $Section3HostDataNotesRichTextBox.Top + $Section3HostDataNotesRichTextBox.Height - $($FormScale * 22 + 5)
    Width     = $FormScale * 100
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    BackColor = 'White'
    Add_Click = {
        $ADEndpoint = $script:Section3HostDataNameTextBox.text

        $Verify = [System.Windows.Forms.MessageBox]::Show(
            "Do you want to pull updated data for the Endpoint `"$($ADEndpoint)`" from Active Directory?",
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
        
                    $script:UpdatedADEndpointInfo = Invoke-Command -ScriptBlock {
                        param ($ADEndpoint)
                        Get-ADComputer -Filter {Name -eq $ADEndpoint} -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID
                    } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -Credential $script:Credential -ArgumentList @($ADEndpoint,$null)


                    foreach ($Endpoint in $script:ComputerTreeViewData) {
                        if ($Endpoint.Name -eq $ADEndpoint){
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Name                            -Value $script:UpdatedADEndpointInfo.Name -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name OperatingSystem                 -Value $script:UpdatedADEndpointInfo.OperatingSystem -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name CanonicalName                   -Value "/$($script:UpdatedADEndpointInfo.CanonicalName | Split-Path -Parent | Split-Path -Leaf)" -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name OperatingSystemHotfix           -Value $script:UpdatedADEndpointInfo.OperatingSystemHotfix -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name OperatingSystemServicePack      -Value $script:UpdatedADEndpointInfo.OperatingSystemServicePack -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Enabled                         -Value $script:UpdatedADEndpointInfo.Enabled -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name LockedOut                       -Value $script:UpdatedADEndpointInfo.LockedOut -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name LogonCount                      -Value $script:UpdatedADEndpointInfo.LogonCount -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Created                         -Value $script:UpdatedADEndpointInfo.Created -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Modified                        -Value $script:UpdatedADEndpointInfo.Modified -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name LastLogonDate                   -Value $script:UpdatedADEndpointInfo.LastLogonDate -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name IPv4Address                     -Value $script:UpdatedADEndpointInfo.IPv4Address -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name MACAddress                      -Value $script:UpdatedADEndpointInfo.MACAddress -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name MemberOf                        -Value $(($script:UpdatedADEndpointInfo | Select-Object -ExpandProperty MemberOf) -join "`n") -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name isCriticalSystemObject          -Value $script:UpdatedADEndpointInfo.isCriticalSystemObject -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name HomedirRequired                 -Value $script:UpdatedADEndpointInfo.HomedirRequired -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Location                        -Value $script:UpdatedADEndpointInfo.Location -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name ProtectedFromAccidentalDeletion -Value $script:UpdatedADEndpointInfo.ProtectedFromAccidentalDeletion -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name TrustedForDelegation            -Value $script:UpdatedADEndpointInfo.TrustedForDelegation -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name SID                             -Value $script:UpdatedADEndpointInfo.SID -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name PortScan                        -Value $script:UpdatedADEndpointInfo.PortScan -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Notes                           -Value $("$(Get-Date) -- Pulled Updated Endpoint Data`n" + $Section3HostDataNotesRichTextBox.text) -Force
                        }
                    }

                    # Yep, needed to update treeview before saving
                    Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes

                    Normalize-TreeViewData -Endpoint
                    Save-TreeViewData -Endpoint -SkipTextFieldSave

                    # Yep, needed to reload the data in the Endpoints tab
                    Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes
                    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Generate-NewRollingPassword
                    }               
        
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter {Name -eq $ADEndpoint} -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text) -Credential [ $UserName | $Password ]"
                }
                else {
                    ### TODO: put in addition checks that prompt if this file is not populated or notifies the user of the AD server used
                    if (Get-Content $script:ActiveDirectoryEndpoint) { $ImportFromADWinRMManuallEntryTextBoxTarget = Get-Content $script:ActiveDirectoryEndpoint }
        
                    $script:UpdatedADEndpointInfo = Invoke-Command -ScriptBlock {
                        param ($ADEndpoint)
                        Get-ADComputer -Filter {Name -eq $ADEndpoint} -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID
                    } -ComputerName $ImportFromADWinRMManuallEntryTextBoxTarget -ArgumentList @($ADEndpoint,$null)
                    
                    foreach ($Endpoint in $script:ComputerTreeViewData) {
                        if ($Endpoint.Name -eq $ADEndpoint){
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Name                            -Value $script:UpdatedADEndpointInfo.Name -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name OperatingSystem                 -Value $script:UpdatedADEndpointInfo.OperatingSystem -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name CanonicalName                   -Value "/$($script:UpdatedADEndpointInfo.CanonicalName | Split-Path -Parent | Split-Path -Leaf)" -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name OperatingSystemHotfix           -Value $script:UpdatedADEndpointInfo.OperatingSystemHotfix -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name OperatingSystemServicePack      -Value $script:UpdatedADEndpointInfo.OperatingSystemServicePack -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Enabled                         -Value $script:UpdatedADEndpointInfo.Enabled -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name LockedOut                       -Value $script:UpdatedADEndpointInfo.LockedOut -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name LogonCount                      -Value $script:UpdatedADEndpointInfo.LogonCount -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Created                         -Value $script:UpdatedADEndpointInfo.Created -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Modified                        -Value $script:UpdatedADEndpointInfo.Modified -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name LastLogonDate                   -Value $script:UpdatedADEndpointInfo.LastLogonDate -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name IPv4Address                     -Value $script:UpdatedADEndpointInfo.IPv4Address -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name MACAddress                      -Value $script:UpdatedADEndpointInfo.MACAddress -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name MemberOf                        -Value $(($script:UpdatedADEndpointInfo | Select-Object -ExpandProperty MemberOf) -join "`n") -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name isCriticalSystemObject          -Value $script:UpdatedADEndpointInfo.isCriticalSystemObject -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name HomedirRequired                 -Value $script:UpdatedADEndpointInfo.HomedirRequired -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Location                        -Value $script:UpdatedADEndpointInfo.Location -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name ProtectedFromAccidentalDeletion -Value $script:UpdatedADEndpointInfo.ProtectedFromAccidentalDeletion -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name TrustedForDelegation            -Value $script:UpdatedADEndpointInfo.TrustedForDelegation -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name SID                             -Value $script:UpdatedADEndpointInfo.SID -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name PortScan                        -Value $script:UpdatedADEndpointInfo.PortScan -Force
                            $Endpoint | Add-Member -MemberType NoteProperty -Name Notes                           -Value $("$(Get-Date) -- Pulled Updated Endpoint Data`n" + $Section3HostDataNotesRichTextBox.text) -Force
                        }
                    }

                    # Yep, needed to update treeview before saving
                    Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes

                    Normalize-TreeViewData -Endpoint
                    Save-TreeViewData -Endpoint -SkipTextFieldSave

                    # Yep, needed to reload the data in the Endpoints tab
                    Update-TreeViewData -Endpoint -TreeView $script:ComputerTreeView.Nodes
                    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
                        Start-Sleep -Seconds 3
                        Generate-NewRollingPassword
                    }               
        
                    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { Get-ADComputer -Filter {Name -eq $ADEndpoint} -Properties Name, CanonicalName, OperatingSystem, OperatingSystemHotfix, OperatingSystemServicePack, Enabled, LockedOut, LogonCount, Created, Modified, LastLogonDate, IPv4Address, MACAddress, MemberOf, isCriticalSystemObject, HomedirRequired, Location, ProtectedFromAccidentalDeletion, TrustedForDelegation, SID } -ComputerName $($ImportFromADWinRMManuallEntryTextBox.Text)"
                }
            }
            'No' {continue}
        }
    }
    Add_MouseEnter = {}
    Add_MouseLeave = {}
    Add_MouseHover = {
        Show-ToolTip -Title "Update Endpoint Data From Active Directory" -Icon "Info" -Message @"
+  This will query Active Directory and pull any updated information for the Endpoint.
"@
    }
}
$Section3HostDataTab.Controls.Add($Section3EndpointDataUpdateDataButton)
$Section3EndpointDataUpdateDataButton.bringtofront()
Apply-CommonButtonSettings -Button $Section3EndpointDataUpdateDataButton


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpRtIwjtnf1uJGrXYYRcAhsQ/
# GHGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUTp8Ikgf65CSEwAdSb1S2ju7/CuMwDQYJKoZI
# hvcNAQEBBQAEggEAIiweXFUB76PCfkpnBUCjlj4UrkTptmSsid8bAzHigzLpwmUD
# rKb5erVnhLPgt8yLdsnvKwGyqGcjV3/mzprP+OYADRphnwJFiHpNSEDVE9WEW31c
# 5yZLwNiqmIO4XEZVoNj+bTG8UgHwMx9dS37HLtDPUA8ncLCfKpd/IYNAA8iIivVt
# 5L6s3ftJ0CmLGlvEecCO3AIulAQfz1WG8DGIDPZ3NpzEY/WzD5FsMBsqrWg0AyeR
# 0RCzOKujDd34W2S68qqyW0xTHI9Nm1aqCHbBdPBB3zSda5bhWBBWOQSf9vHcMucK
# Lx994/30LWwD5CvHauvWZnS0xSq5e8yXVhZdsA==
# SIG # End signature block
