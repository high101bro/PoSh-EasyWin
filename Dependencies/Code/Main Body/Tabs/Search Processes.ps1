$Section1ProcessesConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Processes  "
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 5
}
$MainLeftSearchTabControl.Controls.Add($Section1ProcessesConnectionsSearchTab)


$MainLeftProcessesTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
    ImageSize = @{
        Width  = $FormScale * 16
        Height = $FormScale * 16
    }
}
# Index 0 = Live 
$MainLeftProcessesTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Process.png"))
# Index 1 = Sysinternals
$MainLeftProcessesTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Sysinternals.png"))


$CollectionsProcessesTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * (557 + 5)}
    ShowToolTips  = $True
    SelectedIndex = 0
    ImageList     = $MainLeftProcessesTabControlImageList
    Appearance    = [System.Windows.Forms.TabAppearance]::Buttons
    Hottrack      = $true
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
    Multiline = $true
}
$Section1ProcessesConnectionsSearchTab.Controls.Add($CollectionsProcessesTabControl)





################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################





$Section1ProcessesLiveSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Active Processes  "
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    UseVisualStyleBackColor = $True
    ImageIndex = 0
}
$CollectionsProcessesTabControl.Controls.Add($Section1ProcessesLiveSearchTab)


$ProcessesLiveSearchGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 435
    Height = $FormScale * 50
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

            $ProcessesLiveRegexCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Use Regular Expression. Note: The backslash is the escape character, ex: c:\\Windows\\System32"
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $FormScale * 280 #430
                Height = $FormScale * 25
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Checked = $false
            }
            $ProcessesLiveSearchGroupBox.Controls.Add($ProcessesLiveRegexCheckbox)


            $SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Regex Examples"
                Left   = $ProcessesLiveRegexCheckbox.Left + $ProcessesLiveRegexCheckbox.Width + $($FormScale * 28)
                Top    = $ProcessesLiveRegexCheckbox.Top
                Width  = $FormScale * 115
                Height = $FormScale * 20
                Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
            }
            $ProcessesLiveSearchGroupBox.Controls.Add($SupportsRegexButton)
            Apply-CommonButtonSettings -Button $SupportsRegexButton
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessesLiveSearchGroupBox)


$ProcessLiveSearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Running multiple simultaneous process queries can be CPU intensive on endpoints."
    Left   = $FormScale * 3
    Top    = $ProcessesLiveSearchGroupBox.Top + $ProcessesLiveSearchGroupBox.Height + $($FormScale * 5)
    Width  = $FormScale * 430
    Height = $FormScale * 15
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchLabel)


$ProcessLiveSearchNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Process Name (WinRM)"
    Left   = $FormScale * 3
    Top    = $ProcessLiveSearchLabel.Top + $ProcessLiveSearchLabel.Height
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchNameCheckbox)


        $ProcessLiveSearchNameRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Process Name; One Per Line"
            Left   = $ProcessLiveSearchNameCheckbox.Left
            Top    = $ProcessLiveSearchNameCheckbox.Top + $ProcessLiveSearchNameCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter one Process Name; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter one Process Name; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter one Process Name
+  One Per Line
"@  
            }
        }
        $Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchNameRichTextBox)


$ProcessLiveSearchCommandlineCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Process Command Line (WinRM)"
    Left   = $ProcessLiveSearchNameCheckbox.Left + $ProcessLiveSearchNameCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessLiveSearchNameCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchCommandlineCheckbox)


        $ProcessLiveSearchCommandlineRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Process Command Line; One Per Line"
            Left   = $ProcessLiveSearchCommandlineCheckbox.Left
            Top    = $ProcessLiveSearchCommandlineCheckbox.Top + $ProcessLiveSearchCommandlineCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Process Command Line; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Process Command Line; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Process Command Line
+  One Per Line
"@  
            }
        }
        $Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchCommandlineRichTextBox)


$ProcessLiveSearchParentNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Parent Process Name (WinRM)" #ParentImage
    Left   = $ProcessLiveSearchNameRichTextBox.Left 
    Top    = $ProcessLiveSearchNameRichTextBox.Top+ $ProcessLiveSearchNameRichTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchParentNameCheckbox)


        $ProcessLiveSearchParentNameRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Parent Process Name; One Per Line"
            Left   = $ProcessLiveSearchParentNameCheckbox.Left
            Top    = $ProcessLiveSearchParentNameCheckbox.Top + $ProcessLiveSearchParentNameCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter one Parent Process Name; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter one Parent Process Name; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter one Parent Process Name
+  One Per Line
"@  
            }
        }
        $Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchParentNameRichTextBox)


$ProcessLiveSearchOwnerSIDCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Owner / SID (WinRM)"
    Left   = $ProcessLiveSearchParentNameCheckbox.Left + $ProcessLiveSearchParentNameCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessLiveSearchParentNameCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchOwnerSIDCheckbox)


        $ProcessLiveSearchOwnerSIDRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Process Owner / SID; One Per Line"
            Left   = $ProcessLiveSearchOwnerSIDCheckbox.Left
            Top    = $ProcessLiveSearchOwnerSIDCheckbox.Top + $ProcessLiveSearchOwnerSIDCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Process Owner / SID; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Process Owner / SID; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Process Owner
+  One Per Line
"@  
            }
        }
        $Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchOwnerSIDRichTextBox)


$ProcessLiveSearchServiceInfoCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Service Info (WinRM)"
    Left   = $FormScale * 3
    Top    = $ProcessLiveSearchParentNameRichTextBox.Top + $ProcessLiveSearchParentNameRichTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchServiceInfoCheckbox)


        $ProcessLiveSearchServiceInfoRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Service Info; One Per Line"
            Left   = $ProcessLiveSearchServiceInfoCheckbox.Left
            Top    = $ProcessLiveSearchServiceInfoCheckbox.Top + $ProcessLiveSearchServiceInfoCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter one Service Info; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter one Service Info; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter one Service Info
+  One Per Line
"@  
            }
        }
        $Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchServiceInfoRichTextbox)


$ProcessLiveSearchNetworkConnectionsCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Network Connections (WinRM)"
    Left   = $ProcessLiveSearchServiceInfoCheckbox.Left + $ProcessLiveSearchServiceInfoCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessLiveSearchServiceInfoCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchNetworkConnectionsCheckbox)


        $ProcessLiveSearchNetworkConnectionsRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Network Connections; One Per Line"
            Left   = $ProcessLiveSearchNetworkConnectionsCheckbox.Left
            Top    = $ProcessLiveSearchNetworkConnectionsCheckbox.Top + $ProcessLiveSearchNetworkConnectionsCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Network Connections; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Network Connections; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Network Connections
+  One Per Line
"@  
            }
        }
        $Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchNetworkConnectionsRichTextBox)


$ProcessLiveSearchHashesSignerCertsCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "MD5 Hash / Signer Certificate"
    Left   = $FormScale * 3
    Top    = $ProcessLiveSearchServiceInfoRichTextbox.Top + $ProcessLiveSearchServiceInfoRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchHashesSignerCertsCheckbox)


        $ProcessLiveSearchHashesSignerCertsRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Hashes/Certificate; One Per Line"
            Left   = $ProcessLiveSearchHashesSignerCertsCheckbox.Left
            Top    = $ProcessLiveSearchHashesSignerCertsCheckbox.Top + $ProcessLiveSearchHashesSignerCertsCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Hashes/Certificate; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Hashes/Certificate; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Hashes
+  One Per Line
"@  
            }
        }
        $Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchHashesSignerCertsRichTextBox)


$ProcessLiveSearchCompanyProductCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Company / Product (WinRM)"
    Left   = $ProcessLiveSearchHashesSignerCertsCheckbox.Left + $ProcessLiveSearchHashesSignerCertsCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessLiveSearchHashesSignerCertsCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchCompanyProductCheckbox)


        $ProcessLiveSearchCompanyProductRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Company/Product; One Per Line"
            Left   = $ProcessLiveSearchCompanyProductCheckbox.Left
            Top    = $ProcessLiveSearchCompanyProductCheckbox.Top + $ProcessLiveSearchCompanyProductCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Company/Product; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Company/Product; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Company/Product
+  One Per Line
"@  
            }
        }
        $Section1ProcessesLiveSearchTab.Controls.Add($ProcessLiveSearchCompanyProductRichTextBox)





################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################





$Section1ProcessCreationSysmonSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Logged Events (Sysmon)  "
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    UseVisualStyleBackColor = $True
    ImageIndex = 1
}
$CollectionsProcessesTabControl.Controls.Add($Section1ProcessCreationSysmonSearchTab)



$ProcessSysmonSearchGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 435
    Height = $FormScale * 50 #100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

            $ProcessSysmonRegexCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Use Regular Expression. Note: The backslash is the escape character, ex: c:\\Windows\\System32"
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $FormScale * 280 #430
                Height = $FormScale * 25
                Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Checked = $false
            }
            $ProcessSysmonSearchGroupBox.Controls.Add($ProcessSysmonRegexCheckbox)


            $SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Regex Examples"
                Left   = $ProcessSysmonRegexCheckbox.Left + $ProcessSysmonRegexCheckbox.Width + $($FormScale * 28)
                Top    = $ProcessSysmonRegexCheckbox.Top
                Width  = $FormScale * 115
                Height = $FormScale * 20
                Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
            }
            $ProcessSysmonSearchGroupBox.Controls.Add($SupportsRegexButton)
            Apply-CommonButtonSettings -Button $SupportsRegexButton


#             $ProcessSysmonDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
#                 Text   = "DateTime Start:"
#                 Left   = $FormScale * 77
#                 Top    = $ProcessSysmonRegexCheckbox.Top + $ProcessSysmonRegexCheckbox.Height + $($FormScale * 10)
#                 Width  = $FormScale * 90
#                 Height = $FormScale * 20
#                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 ForeColor = "Black"
#             }
#             $ProcessSysmonSearchGroupBox.Controls.Add($ProcessSysmonDatetimeStartLabel)


#             $script:ProcessCreationSysmonStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
#                 Left         = $ProcessSysmonDatetimeStartLabel.Left + $ProcessSysmonDatetimeStartLabel.Width
#                 Top          = $ProcessSysmonRegexCheckbox.Top + $ProcessSysmonRegexCheckbox.Height + $($FormScale * 10)
#                 Width        = $FormScale * 265
#                 Height       = $FormScale * 100
#                 Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 Format       = [windows.forms.datetimepickerFormat]::custom
#                 CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
#                 Checked      = $True
#                 ShowCheckBox = $True
#                 ShowUpDown   = $False
#                 AutoSize     = $true
#                 #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
#                 #MaxDate      = (Get-Date).DateTime
#                 Value         = (Get-Date).AddDays(-1).DateTime
#                 Add_Click = {
#                     if ($script:ProcessCreationSysmonStopTimePicker.checked -eq $false) {
#                         $script:ProcessCreationSysmonStopTimePicker.checked = $true
#                     }
#                 }
#                 Add_MouseHover = {
#                     Show-ToolTip -Title "DateTime - Starting" -Icon "Info" -Message @"
# +  Select the starting datetime to filter Event Logs
# +  This can be used with the Max Collection field
# +  If left blank, it will collect all available Event Logs
# +  If used, you must select both a start and end datetime
# "@
#                 }
#             }
#             # Wednesday, June 5, 2019 10:27:40 PM
#             # $TimePicker.Value
#             # 20190605162740.383143-240
#             # [System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:ProcessCreationSysmonStartTimePicker.Value))
#             $ProcessSysmonSearchGroupBox.Controls.Add($script:ProcessCreationSysmonStartTimePicker)

            
#             $ProcessSysmonDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
#                 Text   = "DateTime Stop:"
#                 Left   = $ProcessSysmonDatetimeStartLabel.Left
#                 Top    = $ProcessSysmonDatetimeStartLabel.Top + $ProcessSysmonDatetimeStartLabel.Height
#                 Width  = $ProcessSysmonDatetimeStartLabel.Width
#                 Height = $FormScale * 20
#                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 ForeColor = "Black"
#             }
#             $ProcessSysmonSearchGroupBox.Controls.Add($ProcessSysmonDatetimeStopLabel)


#             $script:ProcessCreationSysmonStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
#                 Left         = $ProcessSysmonDatetimeStopLabel.Left + $ProcessSysmonDatetimeStopLabel.Width
#                 Top          = $ProcessSysmonDatetimeStartLabel.Top + $ProcessSysmonDatetimeStartLabel.Height
#                 Width        = $script:ProcessCreationSysmonStartTimePicker.Width
#                 Height       = $FormScale * 100
#                 Font         = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 Format       = [windows.forms.datetimepickerFormat]::custom
#                 CustomFormat = "dddd MMM dd, yyyy hh:mm tt"
#                 Checked      = $True
#                 ShowCheckBox = $True
#                 ShowUpDown   = $False
#                 AutoSize     = $true
#                 #MinDate      = (Get-Date -Month 1 -Day 1 -Year 2000).DateTime
#                 #MaxDate      = (Get-Date).DateTime
#                 Add_MouseHover = {
#                     Show-ToolTip -Title "DateTime - Ending" -Icon "Info" -Message @"
# +  Select the ending datetime to filter Event Logs
# +  This can be used with the Max Collection field
# +  If left blank, it will collect all available Event Logs
# +  If used, you must select both a start and end datetime
# "@
#                 }
#             }
#             $ProcessSysmonSearchGroupBox.Controls.Add($script:ProcessCreationSysmonStopTimePicker)

$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchGroupBox)


$ProcessSysmonSearchLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "To return results, this section relies on sysmon being installed endpoints."
    Left   = $FormScale * 3
    Top    = $ProcessSysmonSearchGroupBox.Top + $ProcessSysmonSearchGroupBox.Height + $($FormScale * 5)
    Width  = $FormScale * 430
    Height = $FormScale * 15
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchLabel)


$ProcessSysmonSearchFilePathCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Process File Path (WinRM)"
    Left   = $FormScale * 3
    Top    = $ProcessSysmonSearchLabel.Top + $ProcessSysmonSearchLabel.Height
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchFilePathCheckbox)


        $ProcessSysmonSearchFilePathRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Process File Path; One Per Line"
            Left   = $ProcessSysmonSearchFilePathCheckbox.Left
            Top    = $ProcessSysmonSearchFilePathCheckbox.Top + $ProcessSysmonSearchFilePathCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter one Process File Path; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter one Process File Path; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter one Process File Path
+  One Per Line
"@  
            }
        }
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchFilePathRichTextBox)


$ProcessSysmonSearchCommandlineCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Command Line (WinRM)" #CommandLine
    Left   = $ProcessSysmonSearchFilePathCheckbox.Left + $ProcessSysmonSearchFilePathCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessSysmonSearchFilePathCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchCommandlineCheckbox)


        $ProcessSysmonSearchCommandlineRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Process Command Line; One Per Line"
            Left   = $ProcessSysmonSearchCommandlineCheckbox.Left
            Top    = $ProcessSysmonSearchCommandlineCheckbox.Top + $ProcessSysmonSearchCommandlineCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Process Command Line; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Process Command Line; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Process Command Line
+  One Per Line
"@  
            }
        }
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchCommandlineRichTextBox)


$ProcessSysmonSearchParentFilePathCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Parent Process File Path"
    Left   = $ProcessSysmonSearchFilePathRichTextBox.Left 
    Top    = $ProcessSysmonSearchFilePathRichTextBox.Top+ $ProcessSysmonSearchFilePathRichTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchParentFilePathCheckbox)


        $ProcessSysmonSearchParentFilePathRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Parent Process File Path; One Per Line"
            Left   = $ProcessSysmonSearchParentFilePathCheckbox.Left
            Top    = $ProcessSysmonSearchParentFilePathCheckbox.Top + $ProcessSysmonSearchParentFilePathCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter one Parent Process File Path; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter one Parent Process File Path; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter one Parent Process File Path
+  One Per Line
"@  
            }
        }
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchParentFilePathRichTextBox)


$ProcessSysmonSearchParentCommandlineCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Parent Process Command Line" #ParentCommandLine
    Left   = $ProcessSysmonSearchParentFilePathCheckbox.Left + $ProcessSysmonSearchParentFilePathCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessSysmonSearchParentFilePathCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchParentCommandlineCheckbox)


        $ProcessSysmonSearchParentCommandlineRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Parent Process Command Line; One Per Line"
            Left   = $ProcessSysmonSearchParentCommandlineCheckbox.Left
            Top    = $ProcessSysmonSearchParentCommandlineCheckbox.Top + $ProcessSysmonSearchParentCommandlineCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Parent Process Command Line; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Parent Process Command Line; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Parent Process Command Line
+  One Per Line
"@  
            }
        }
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchParentCommandlineRichTextBox)


$ProcessSysmonSearchRuleNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Rule Name (WinRM)"
    Left   = $FormScale * 3
    Top    = $ProcessSysmonSearchParentFilePathRichTextBox.Top + $ProcessSysmonSearchParentFilePathRichTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchRuleNameCheckbox)


        $ProcessSysmonSearchRuleNameRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Rule Name; One Per Line"
            Left   = $ProcessSysmonSearchRuleNameCheckbox.Left
            Top    = $ProcessSysmonSearchRuleNameCheckbox.Top + $ProcessSysmonSearchRuleNameCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter one Rule Name; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter one Rule Name; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter one Rule Name
+  One Per Line
"@  
            }
        }
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchRuleNameRichTextbox)


$ProcessSysmonSearchUserAccountIdCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "User Account / ID (WinRM)"
    Left   = $ProcessSysmonSearchRuleNameCheckbox.Left + $ProcessSysmonSearchRuleNameCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessSysmonSearchRuleNameCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchUserAccountIdCheckbox)


        $ProcessSysmonSearchUserAccountIdRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter User Account; One Per Line"
            Left   = $ProcessSysmonSearchUserAccountIdCheckbox.Left
            Top    = $ProcessSysmonSearchUserAccountIdCheckbox.Top + $ProcessSysmonSearchUserAccountIdCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter User Account; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter User Account; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter User Account
+  One Per Line
"@  
            }
        }
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchUserAccountIdRichTextBox)


$ProcessSysmonSearchHashesCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Hashes: MD5/SHA1/SHA256/IMP"
    Left   = $FormScale * 3
    Top    = $ProcessSysmonSearchRuleNameRichTextbox.Top + $ProcessSysmonSearchRuleNameRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchHashesCheckbox)


        $ProcessSysmonSearchHashesRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Hashes; One Per Line"
            Left   = $ProcessSysmonSearchHashesCheckbox.Left
            Top    = $ProcessSysmonSearchHashesCheckbox.Top + $ProcessSysmonSearchHashesCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Hashes; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Hashes; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Hashes
+  One Per Line
"@  
            }
        }
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchHashesRichTextBox)


$ProcessSysmonSearchCompanyProductCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Company / Product (WinRM)"
    Left   = $ProcessSysmonSearchHashesCheckbox.Left + $ProcessSysmonSearchHashesCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessSysmonSearchHashesCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 20
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchCompanyProductCheckbox)


        $ProcessSysmonSearchCompanyProductRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Company/Product; One Per Line"
            Left   = $ProcessSysmonSearchCompanyProductCheckbox.Left
            Top    = $ProcessSysmonSearchCompanyProductCheckbox.Top + $ProcessSysmonSearchCompanyProductCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 210
            Height = $FormScale * 75
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine  = $True
            ScrollBars = "Vertical"
            WordWrap   = $True
            ShortcutsEnabled = $true
            Add_MouseEnter = {if ($this.text -eq "Enter Company/Product; One Per Line"){$this.text = ""}}
            Add_MouseLeave = {if ($this.text -eq "") {$this.text = "Enter Company/Product; One Per Line"}}
            Add_MouseHover = {
                Show-ToolTip -Title "Source IP Address" -Icon "Info" -Message @"
+  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
+  Enter Company/Product
+  One Per Line
"@  
            }
        }
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessSysmonSearchCompanyProductRichTextBox)


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwFG04yzV5BOdbjCI/wAWjLf3
# SdygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQURhSostp1gE1hp97opGQCivpyJVYwDQYJKoZI
# hvcNAQEBBQAEggEAP0+vfKgdK1kg3/RBfYX33QCpg2cW5+lrL1RbGAqiE2SyuUb8
# NSNcpUGJxC/EiHm2p2zoMGC4iD4ckXjEmjtP9QV0YOQ1cJlbRtPmdSbALChf5+GE
# 3ZrOM0Zfj4c56rGay8Hx8CUpGzrrvC8KVjt2Dq+qAIRqZ4xFHnxkrYETSrF9wJVX
# DP22EOfivoHzdB1FkGM9Bvf8vvl9xC0J2WsG1VMM1eI+foL8BzL6v3ZxYzyr8+/+
# jT3zELfOP9ZzGoh5O9K8jeWR0uGxYfpmvt9zs04J0tgEQ7VRPTDuWhxx5xuzie2V
# 5WBKJlMOu1NdNNtUDD9toZSW5U0Icb0XCg3KJA==
# SIG # End signature block
