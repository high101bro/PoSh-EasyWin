$Section1ProcessesConnectionsSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Processes"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 5
}
$MainLeftCollectionsTabControl.Controls.Add($Section1ProcessesConnectionsSearchTab)


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
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Multiline = $true
}
$Section1ProcessesConnectionsSearchTab.Controls.Add($CollectionsProcessesTabControl)





################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################





$Section1ProcessesLiveSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Active Processes"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
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
                Checked = $true
            }
            $ProcessesLiveSearchGroupBox.Controls.Add($ProcessesLiveRegexCheckbox)


            $SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Regex Examples"
                Left   = $ProcessesLiveRegexCheckbox.Left + $ProcessesLiveRegexCheckbox.Width + $($FormScale * 28)
                Top    = $ProcessesLiveRegexCheckbox.Top
                Width  = $FormScale * 115
                Height = $FormScale * 22
                Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
            }
            $ProcessesLiveSearchGroupBox.Controls.Add($SupportsRegexButton)
            Apply-CommonButtonSettings -Button $SupportsRegexButton
$Section1ProcessesLiveSearchTab.Controls.Add($ProcessesLiveSearchGroupBox)

$ProcessLiveSearchNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Process Name" #Image
    Left   = $FormScale * 3
    Top    = $ProcessesLiveSearchGroupBox.Top + $ProcessesLiveSearchGroupBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 22
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
    Text   = "Process Command Line" #CommandLine
    Left   = $ProcessLiveSearchNameCheckbox.Left + $ProcessLiveSearchNameCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessLiveSearchNameCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 22
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
    Text   = "Parent Process Name" #ParentImage
    Left   = $ProcessLiveSearchNameRichTextBox.Left 
    Top    = $ProcessLiveSearchNameRichTextBox.Top+ $ProcessLiveSearchNameRichTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 22
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
    Text   = "Process Owner / SID" #ParentCommandLine
    Left   = $ProcessLiveSearchParentNameCheckbox.Left + $ProcessLiveSearchParentNameCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessLiveSearchParentNameCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 22
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
    Text   = "Service Info"
    Left   = $FormScale * 3
    Top    = $ProcessLiveSearchParentNameRichTextBox.Top + $ProcessLiveSearchParentNameRichTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 22
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
    Text   = "Network Connections"
    Left   = $ProcessLiveSearchServiceInfoCheckbox.Left + $ProcessLiveSearchServiceInfoCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessLiveSearchServiceInfoCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 22
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
    Height = $FormScale * 22
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
    Text   = "Company / Product"
    Left   = $ProcessLiveSearchHashesSignerCertsCheckbox.Left + $ProcessLiveSearchHashesSignerCertsCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessLiveSearchHashesSignerCertsCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 22
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
    Text   = "Logged Events (Sysmon)"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Blue'
    UseVisualStyleBackColor = $True
    ImageIndex = 1
}
$CollectionsProcessesTabControl.Controls.Add($Section1ProcessCreationSysmonSearchTab)



$ProcessCreationSysmonSearchGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text   = "Collection Options"
    Left   = $FormScale * 3
    Top    = $FormScale * 5
    Width  = $FormScale * 435
    Height = $FormScale * 50 #100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}

            $ProcessCreationSysmonRegexCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
                Text   = "Use Regular Expression. Note: The backslash is the escape character, ex: c:\\Windows\\System32"
                Left   = $FormScale * 7
                Top    = $FormScale * 18
                Width  = $FormScale * 280 #430
                Height = $FormScale * 25
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Checked = $true
            }
            $ProcessCreationSysmonSearchGroupBox.Controls.Add($ProcessCreationSysmonRegexCheckbox)


            $SupportsRegexButton = New-Object System.Windows.Forms.Button -Property @{
                Text   = "Regex Examples"
                Left   = $ProcessCreationSysmonRegexCheckbox.Left + $ProcessCreationSysmonRegexCheckbox.Width + $($FormScale * 28)
                Top    = $ProcessCreationSysmonRegexCheckbox.Top
                Width  = $FormScale * 115
                Height = $FormScale * 22
                Add_Click = { Import-Csv "$Dependencies\Reference RegEx Examples.csv" | Out-GridView }
            }
            $ProcessCreationSysmonSearchGroupBox.Controls.Add($SupportsRegexButton)
            Apply-CommonButtonSettings -Button $SupportsRegexButton


#             $ProcessCreationSysmonDatetimeStartLabel = New-Object System.Windows.Forms.Label -Property @{
#                 Text   = "DateTime Start:"
#                 Left   = $FormScale * 77
#                 Top    = $ProcessCreationSysmonRegexCheckbox.Top + $ProcessCreationSysmonRegexCheckbox.Height + $($FormScale * 10)
#                 Width  = $FormScale * 90
#                 Height = $FormScale * 22
#                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 ForeColor = "Black"
#             }
#             $ProcessCreationSysmonSearchGroupBox.Controls.Add($ProcessCreationSysmonDatetimeStartLabel)


#             $script:ProcessCreationSysmonStartTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
#                 Left         = $ProcessCreationSysmonDatetimeStartLabel.Left + $ProcessCreationSysmonDatetimeStartLabel.Width
#                 Top          = $ProcessCreationSysmonRegexCheckbox.Top + $ProcessCreationSysmonRegexCheckbox.Height + $($FormScale * 10)
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
#             $ProcessCreationSysmonSearchGroupBox.Controls.Add($script:ProcessCreationSysmonStartTimePicker)

            
#             $ProcessCreationSysmonDatetimeStopLabel = New-Object System.Windows.Forms.Label -Property @{
#                 Text   = "DateTime Stop:"
#                 Left   = $ProcessCreationSysmonDatetimeStartLabel.Left
#                 Top    = $ProcessCreationSysmonDatetimeStartLabel.Top + $ProcessCreationSysmonDatetimeStartLabel.Height
#                 Width  = $ProcessCreationSysmonDatetimeStartLabel.Width
#                 Height = $FormScale * 22
#                 Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#                 ForeColor = "Black"
#             }
#             $ProcessCreationSysmonSearchGroupBox.Controls.Add($ProcessCreationSysmonDatetimeStopLabel)


#             $script:ProcessCreationSysmonStopTimePicker = New-Object System.Windows.Forms.DateTimePicker -Property @{
#                 Left         = $ProcessCreationSysmonDatetimeStopLabel.Left + $ProcessCreationSysmonDatetimeStopLabel.Width
#                 Top          = $ProcessCreationSysmonDatetimeStartLabel.Top + $ProcessCreationSysmonDatetimeStartLabel.Height
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
#             $ProcessCreationSysmonSearchGroupBox.Controls.Add($script:ProcessCreationSysmonStopTimePicker)

$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchGroupBox)



$ProcessCreationSysmonSearchFilePathCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Process File Path" #Image
    Left   = $FormScale * 3
    Top    = $ProcessCreationSysmonSearchGroupBox.Top + $ProcessCreationSysmonSearchGroupBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchFilePathCheckbox)


        $ProcessCreationSysmonSearchFilePathRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Process File Path; One Per Line"
            Left   = $ProcessCreationSysmonSearchFilePathCheckbox.Left
            Top    = $ProcessCreationSysmonSearchFilePathCheckbox.Top + $ProcessCreationSysmonSearchFilePathCheckbox.Height + $($FormScale * 5)
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
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchFilePathRichTextBox)


$ProcessCreationSysmonSearchCommandlineCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Process Command Line" #CommandLine
    Left   = $ProcessCreationSysmonSearchFilePathCheckbox.Left + $ProcessCreationSysmonSearchFilePathCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessCreationSysmonSearchFilePathCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchCommandlineCheckbox)


        $ProcessCreationSysmonSearchCommandlineRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Process Command Line; One Per Line"
            Left   = $ProcessCreationSysmonSearchCommandlineCheckbox.Left
            Top    = $ProcessCreationSysmonSearchCommandlineCheckbox.Top + $ProcessCreationSysmonSearchCommandlineCheckbox.Height + $($FormScale * 5)
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
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchCommandlineRichTextBox)


$ProcessCreationSysmonSearchParentFilePathCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Parent Process File Path" #ParentImage
    Left   = $ProcessCreationSysmonSearchFilePathRichTextBox.Left 
    Top    = $ProcessCreationSysmonSearchFilePathRichTextBox.Top+ $ProcessCreationSysmonSearchFilePathRichTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchParentFilePathCheckbox)


        $ProcessCreationSysmonSearchParentFilePathRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Parent Process File Path; One Per Line"
            Left   = $ProcessCreationSysmonSearchParentFilePathCheckbox.Left
            Top    = $ProcessCreationSysmonSearchParentFilePathCheckbox.Top + $ProcessCreationSysmonSearchParentFilePathCheckbox.Height + $($FormScale * 5)
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
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchParentFilePathRichTextBox)


$ProcessCreationSysmonSearchParentCommandlineCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Parent Process Command Line" #ParentCommandLine
    Left   = $ProcessCreationSysmonSearchParentFilePathCheckbox.Left + $ProcessCreationSysmonSearchParentFilePathCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessCreationSysmonSearchParentFilePathCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchParentCommandlineCheckbox)


        $ProcessCreationSysmonSearchParentCommandlineRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Parent Process Command Line; One Per Line"
            Left   = $ProcessCreationSysmonSearchParentCommandlineCheckbox.Left
            Top    = $ProcessCreationSysmonSearchParentCommandlineCheckbox.Top + $ProcessCreationSysmonSearchParentCommandlineCheckbox.Height + $($FormScale * 5)
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
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchParentCommandlineRichTextBox)


$ProcessCreationSysmonSearchOriginalFileNameCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Rule Name"
    Left   = $FormScale * 3
    Top    = $ProcessCreationSysmonSearchParentFilePathRichTextBox.Top + $ProcessCreationSysmonSearchParentFilePathRichTextBox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchOriginalFileNameCheckbox)


        $ProcessCreationSysmonSearchOriginalFileNameRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter one Rule Name; One Per Line"
            Left   = $ProcessCreationSysmonSearchOriginalFileNameCheckbox.Left
            Top    = $ProcessCreationSysmonSearchOriginalFileNameCheckbox.Top + $ProcessCreationSysmonSearchOriginalFileNameCheckbox.Height + $($FormScale * 5)
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
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchOriginalFileNameRichTextbox)


$ProcessCreationSysmonSearchUserCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "User Account"
    Left   = $ProcessCreationSysmonSearchOriginalFileNameCheckbox.Left + $ProcessCreationSysmonSearchOriginalFileNameCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessCreationSysmonSearchOriginalFileNameCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchUserCheckbox)


        $ProcessCreationSysmonSearchUserRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter User Account; One Per Line"
            Left   = $ProcessCreationSysmonSearchUserCheckbox.Left
            Top    = $ProcessCreationSysmonSearchUserCheckbox.Top + $ProcessCreationSysmonSearchUserCheckbox.Height + $($FormScale * 5)
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
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchUserRichTextBox)


$ProcessCreationSysmonSearchHashesCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Hashes: MD5/SHA1/SHA256/IMP"
    Left   = $FormScale * 3
    Top    = $ProcessCreationSysmonSearchOriginalFileNameRichTextbox.Top + $ProcessCreationSysmonSearchOriginalFileNameRichTextbox.Height + $($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchHashesCheckbox)


        $ProcessCreationSysmonSearchHashesRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Hashes; One Per Line"
            Left   = $ProcessCreationSysmonSearchHashesCheckbox.Left
            Top    = $ProcessCreationSysmonSearchHashesCheckbox.Top + $ProcessCreationSysmonSearchHashesCheckbox.Height + $($FormScale * 5)
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
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchHashesRichTextBox)


$ProcessCreationSysmonSearchCompanyProductCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Company / Product"
    Left   = $ProcessCreationSysmonSearchHashesCheckbox.Left + $ProcessCreationSysmonSearchHashesCheckbox.Width + $($FormScale * 10)
    Top    = $ProcessCreationSysmonSearchHashesCheckbox.Top
    Width  = $FormScale * 210
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        Update-QueryCount
        
        Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
        if ($this.checked){$this.ForeColor = 'Red'} else {$this.ForeColor = 'Blue'}
    }
}
$Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchCompanyProductCheckbox)


        $ProcessCreationSysmonSearchCompanyProductRichTextBox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Company/Product; One Per Line"
            Left   = $ProcessCreationSysmonSearchCompanyProductCheckbox.Left
            Top    = $ProcessCreationSysmonSearchCompanyProductCheckbox.Top + $ProcessCreationSysmonSearchCompanyProductCheckbox.Height + $($FormScale * 5)
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
        $Section1ProcessCreationSysmonSearchTab.Controls.Add($ProcessCreationSysmonSearchCompanyProductRichTextBox)


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHDQGodsEJyRBoXS64NxpY052
# dj2gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUcLsP3L4dsQxHWjFx3TXxAJariiwwDQYJKoZI
# hvcNAQEBBQAEggEAOTbQiV4ZbVyBcWUP7/Q7T5Hpe9T2asdKRP8nLp8w6gYLi7pL
# n+VEZOsPV8l3QOmpTyvlhVWzDh9g4hhq+1HawUTVlJ3yNgNGR7Sje/GTD7U0lkZM
# mEGfsUL+WfGZIgtyP4HWfiw9rs/GFgXHKRALEdHqPYMhiQLlC/DW6v5HLIIsdHgf
# E79lm3hjxDdaRyIHh0iptWlg512ZEfFPgyNMgtmPdqv1CV51DhOlXdVaT3b7O0TK
# INES/aoO9l8k15vD9YLEAou9w76ZrwKtnJFRjg61F6wXsxkEJRFeLha+VoXpBRhf
# MwZPnOdD2O7rE09kRO7mXV0ZSKa0b8JcbeUGuw==
# SIG # End signature block
