
$SysinternalsRightPosition     = 3
$SysinternalsDownPosition      = -10
$SysinternalsDownPositionShift = 22
$SysinternalsButtonWidth       = 110
$SysinternalsButtonHeight      = 22

$Section1ExecutablesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Executables"
    Location = @{ X = $FormScale * $SysinternalsRightPosition
                  Y = $FormScale * $SysinternalsDownPosition }
    Size     = @{ Width  = $FormScale * 440
                  Height = $FormScale * 22 }
    UseVisualStyleBackColor = $True
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path $ExternalPrograms) { $MainLeftSection1InteractionsTabTabControl.Controls.Add($Section1ExecutablesTab) }

$SysinternalsDownPosition += $SysinternalsDownPositionShift


#============================================================================================================================================================
# Options GroupBox
#============================================================================================================================================================
$ExternalProgramsOptionsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Collection Options"
    Location  = @{ X = $FormScale * $SysinternalsRightPosition
                   Y = $FormScale * $SysinternalsDownPosition }
    Size     = @{ Width  = $FormScale * 430
                  Height = $FormScale * 47 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ExternalProgramsProtocolRadioButtonLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Protocol:"
                Location = @{ X = $FormScale * 7
                            Y = $FormScale * 22 }
                Size     = @{ Width  = $FormScale * 73
                            Height = $FormScale * 20 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
            }


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RadioButton\ExternalProgramsWinRMRadioButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\RadioButton\ExternalProgramsWinRMRadioButton.ps1"
            $ExternalProgramsWinRMRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "WinRM"
                Location = @{ X = $FormScale * 80
                            Y = $FormScale * 19 }
                Size     = @{ Width  = $FormScale * 80
                            Height = $FormScale * 22 }
                Checked  = $True
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $ExternalProgramsWinRMRadioButtonAdd_Click
                Add_MouseHover = $ExternalProgramsWinRMRadioButtonAdd_MouseHover
            }


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RadioButton\ExternalProgramsRPCRadioButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\RadioButton\ExternalProgramsRPCRadioButton.ps1"
            $ExternalProgramsRPCRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "RPC"
                Location = @{ X = $ExternalProgramsWinRMRadioButton.Location.X + $ExternalProgramsWinRMRadioButton.Size.Width + $($FormScale * 5)
                            Y = $ExternalProgramsWinRMRadioButton.Location.Y }
                Size     = @{ Width  = $FormScale * 60
                            Height = $FormScale * 22 }
                Checked  = $False
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = 'Black'
                Add_Click      = $ExternalProgramsRPCRadioButtonAdd_Click
                Add_MouseHover = $ExternalProgramsRPCRadioButtonAdd_MouseHover
            }


            $ExternalProgramsCheckTimeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Recheck Time (secs):"
                Location = @{ X = $ExternalProgramsRPCRadioButton.Location.X + $ExternalProgramsRPCRadioButton.Size.Width + $($FormScale * 30)
                            Y = $ExternalProgramsRPCRadioButton.Location.Y + $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 130
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\ExternalProgramsCheckTimeTextBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\TextBox\ExternalProgramsCheckTimeTextBox.ps1"
            $ExternalProgramsCheckTimeTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                Text     = 15
                Location = @{ X = $ExternalProgramsCheckTimeLabel.Location.X + $ExternalProgramsCheckTimeLabel.Size.Width
                                Y = $ExternalProgramsCheckTimeLabel.Location.Y - 3 }
                Size     = @{ Width  = $FormScale * 30
                                Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
                Enabled  = $True
                Add_MouseHover = $ExternalProgramsCheckTimeTextBoxAdd_MouseHover
            }

            $ExternalProgramsOptionsGroupBox.Controls.AddRange(@($ExternalProgramsProtocolRadioButtonLabel,$ExternalProgramsRPCRadioButton,$ExternalProgramsWinRMRadioButton,$ExternalProgramsCheckTimeLabel,$ExternalProgramsCheckTimeTextBox))
$Section1ExecutablesTab.Controls.Add($ExternalProgramsOptionsGroupBox)


#============================================================================================================================================================
# Sysinternals Sysmon
#============================================================================================================================================================

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsSysmonCheckbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsSysmonCheckbox.ps1"
$SysinternalsSysmonCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Sysmon"
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsOptionsGroupBox.Location.Y + $ExternalProgramsOptionsGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click      = $SysinternalsSysmonCheckBoxAdd_Click
    Add_MouseHover = $SysinternalsSysmonCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($SysinternalsSysmonCheckbox)


$ExternalProgramsSysmonGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X
                   Y =  $ExternalProgramsOptionsGroupBox.Location.Y + $ExternalProgramsOptionsGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width
                   Height = $FormScale * 133 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $SysinternalsSysmonLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $FormScale * 420
                            Height = $FormScale * 25 }
                Text      = "System Monitor (Sysmon) will be installed on the endpoints. Logs created by sysmon can be viewed via command lilne, Windows Event Viewer, or a SIEM."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonLabel)

            # Selects the .xml configuration file for sysmon
            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-SysinternalsSysmonXmlConfig.ps1"
            . "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-SysinternalsSysmonXmlConfig.ps1"
            $script:SysmonXMLPath = $null
            $SysinternalsSysmonSelectConfigButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Config"
                Location = @{ X = $SysinternalsSysmonLabel.Location.X
                            Y = $SysinternalsSysmonLabel.Location.Y + $SysinternalsSysmonLabel.Size.Height + $($FormScale * 10) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click = { Select-SysinternalsSysmonXmlConfig }
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonSelectConfigButton)
            CommonButtonSettings -Button $SysinternalsSysmonSelectConfigButton


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsSysmonEventIdsButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsSysmonEventIdsButton.ps1"
            $SysinternalsSysmonEventIdsButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Sysmon Event IDs"
                Location = @{ X = $SysinternalsSysmonSelectConfigButton.Location.X
                            Y = $SysinternalsSysmonSelectConfigButton.Location.Y + $SysinternalsSysmonSelectConfigButton.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click      = $SysinternalsSysmonEventIdsButtonAdd_Click
                Add_MouseHover = $SysinternalsSysmonEventIdsButtonAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonEventIdsButton)
            CommonButtonSettings -Button $SysinternalsSysmonEventIdsButton


            $SysinternalsSysmonConfigTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Config:"
                Location = @{ X = $FormScale * 125
                            Y = $SysinternalsSysmonSelectConfigButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $FormScale * 300
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonConfigTextBox)


            $SysinternalsSysmonRenameServiceProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Service/Process Name:"
                Location = @{ X = $FormScale * 200
                            Y = $SysinternalsSysmonConfigTextBox.Location.Y + $SysinternalsSysmonConfigTextBox.Size.Height + $($FormScale * 8) }
                Size     = @{ Width  = $FormScale * 130
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameServiceProcessLabel)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsSysmonRenameServiceProcessTextBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsSysmonRenameServiceProcessTextBox.ps1"
            $SysinternalsSysmonRenameServiceProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Sysmon"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X + $SysinternalsSysmonRenameServiceProcessLabel.Size.Width + $($FormScale * 10)
                            Y = $SysinternalsSysmonRenameServiceProcessLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $FormScale * 85
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsSysmonRenameServiceProcessTextBoxAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameServiceProcessTextBox)


            $SysinternalsSysmonRenameDriverLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Driver Name:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsSysmonRenameServiceProcessLabel.Location.Y + $SysinternalsSysmonRenameServiceProcessLabel.Size.Height }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameDriverLabel)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsSysmonRenameDriverTextBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsSysmonRenameDriverTextBox.ps1"
            $SysinternalsSysmonRenameDriverTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "SysmonDrv"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsSysmonRenameDriverLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                MaxLength = 8
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsSysmonRenameDriverTextBoxAdd_MouseHover
            }
            $ExternalProgramsSysmonGroupBox.Controls.Add($SysinternalsSysmonRenameDriverTextBox)
$Section1ExecutablesTab.Controls.Add($ExternalProgramsSysmonGroupBox)


#============================================================================================================================================================
# Sysinternals Autoruns
#============================================================================================================================================================

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsAutorunsCheckbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsAutorunsCheckbox.ps1"
$SysinternalsAutorunsCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Autoruns"
    Location  = @{ X = $ExternalProgramsOptionsGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsSysmonGroupBox.Location.Y + $ExternalProgramsSysmonGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_MouseHover = $SysinternalsAutorunsCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($SysinternalsAutorunsCheckbox)


$ExternalProgramsAutorunsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsSysmonGroupBox.Location.X
                   Y = $ExternalProgramsSysmonGroupBox.Location.Y + $ExternalProgramsSysmonGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width
                   Height = $FormScale * 76 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
}
            $SysinternalsAutorunsLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $SysinternalsSysmonLabel.Size.Width
                            Height = $FormScale * 25 }
                Text      = "Obtains More Startup Information than Native WMI and other Windows Commands, like various built-in Windows Applications."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsLabel)

            $SysinternalsDownPosition += $SysinternalsDownPositionShift


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsAutorunsButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsAutorunsButton.ps1"
            $SysinternalsAutorunsButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Open Autoruns"
                Location = @{ X = $SysinternalsAutorunsLabel.Location.X
                            Y = $SysinternalsAutorunsLabel.Location.Y + $SysinternalsAutorunsLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click = $SysinternalsAutorunsButtonAdd_Click
            }
            $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsButton)
            CommonButtonSettings -Button $SysinternalsAutorunsButton


            $SysinternalsAutorunsRenameProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Process Name:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsAutorunsButton.Location.Y }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsRenameProcessLabel)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsAutorunsRenameProcessTextBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsAutorunsRenameProcessTextBox.ps1"
            $SysinternalsAutorunsRenameProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Autoruns"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsAutorunsRenameProcessLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsAutorunsRenameProcessTextBoxAdd_MouseHover
            }
            $ExternalProgramsAutorunsGroupBox.Controls.Add($SysinternalsAutorunsRenameProcessTextBox)
$Section1ExecutablesTab.Controls.Add($ExternalProgramsAutorunsGroupBox)


#============================================================================================================================================================
# Sysinternals Process Monitor
#============================================================================================================================================================

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsProcessMonitorCheckbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckBox\SysinternalsProcessMonitorCheckbox.ps1"
$SysinternalsProcessMonitorCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text     = "Procmon"
    Location = @{ X = $ExternalProgramsAutorunsGroupBox.Location.X + $($FormScale * 5)
                  Y = $ExternalProgramsAutorunsGroupBox.Location.Y + $ExternalProgramsAutorunsGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
    Add_MouseHover = $SysinternalsProcessMonitorCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($SysinternalsProcessMonitorCheckbox)


$ExternalProgramsProcmonGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsAutorunsGroupBox.Location.X
                   Y = $ExternalProgramsAutorunsGroupBox.Location.Y + $ExternalProgramsAutorunsGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsOptionsGroupBox.Size.Width
                   Height = $FormScale * 102 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $SysinternalsProcessMonitorLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $SysinternalsSysmonLabel.Size.Width
                            Height = $FormScale * 25 }
                Text      = "Obtains process data over a timespan and can easily return data in 100's of MBs. Checks are done to see if 500MB is available on the localhost and endpoints."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcessMonitorLabel)

            $SysinternalsDownPosition += $SysinternalsDownPositionShift


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsProcmonButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\SysinternalsProcmonButton.ps1"
            $SysinternalsProcmonButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Open Procmon"
                Location = @{ X = $SysinternalsProcessMonitorLabel.Location.X
                            Y = $SysinternalsProcessMonitorLabel.Location.Y + $SysinternalsProcessMonitorLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * $SysinternalsButtonWidth
                            Height = $FormScale * $SysinternalsButtonHeight }
                Add_Click = $SysinternalsProcmonButtonAdd_Click
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonButton)
            CommonButtonSettings -Button $SysinternalsProcmonButton


            $SysinternalsProcmonCaptureTimeLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Capture Time:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsProcmonButton.Location.Y }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonCaptureTimeLabel)


            $script:SysinternalsProcessMonitorTimeComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                Text     = "5 Seconds"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsProcmonCaptureTimeLabel.Location.Y }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            }
            $ProcmonCaptureTimes = @('5 Seconds','10 Seconds','15 Seconds','30 Seconds','1 Minute','2 Minutes','3 Minutes','4 Minutes','5 Minutes')
                ForEach ($time in $ProcmonCaptureTimes) { $script:SysinternalsProcessMonitorTimeComboBox.Items.Add($time) }
            $ExternalProgramsProcmonGroupBox.Controls.Add($script:SysinternalsProcessMonitorTimeComboBox)


            $SysinternalsProcmonRenameProcessLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Process Name:"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessLabel.Location.X
                            Y = $SysinternalsProcmonCaptureTimeLabel.Location.Y + $SysinternalsProcmonCaptureTimeLabel.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessLabel.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Blue"
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonRenameProcessLabel)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsProcmonRenameProcessTextBox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Textbox\SysinternalsProcmonRenameProcessTextBox.ps1"
            $SysinternalsProcmonRenameProcessTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Procmon"
                Location = @{ X = $SysinternalsSysmonRenameServiceProcessTextBox.Location.X
                            Y = $SysinternalsProcmonRenameProcessLabel.Location.Y - $($FormScale * 3) }
                Size     = @{ Width  = $SysinternalsSysmonRenameServiceProcessTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_MouseHover = $SysinternalsProcmonRenameProcessTextBoxAdd_MouseHover
            }
            $ExternalProgramsProcmonGroupBox.Controls.Add($SysinternalsProcmonRenameProcessTextBox)
$Section1ExecutablesTab.Controls.Add($ExternalProgramsProcmonGroupBox)


#============================================================================================================================================================
# User Specified Files and Custom Script
#============================================================================================================================================================

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\CheckBox\ExeScriptUserSpecifiedExecutableAndScriptCheckbox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckBox\ExeScriptUserSpecifiedExecutableAndScriptCheckbox.ps1"
$ExeScriptUserSpecifiedExecutableAndScriptCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "User Specified Files and Custom Script (WinRM)"
    Location  = @{ X = $ExternalProgramsProcmonGroupBox.Location.X + $($FormScale * 5)
                   Y = $ExternalProgramsProcmonGroupBox.Location.Y + $ExternalProgramsProcmonGroupBox.Size.Height + $($FormScale * 5) }
    AutoSize  = $true
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click      = $ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_Click
    Add_MouseHover = $ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_MouseHover
}
$Section1ExecutablesTab.Controls.Add($ExeScriptUserSpecifiedExecutableAndScriptCheckbox)


$ExeScriptProgramGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location  = @{ X = $ExternalProgramsProcmonGroupBox.Location.X
                   Y = $ExternalProgramsProcmonGroupBox.Location.Y + $ExternalProgramsProcmonGroupBox.Size.Height + $($FormScale * 5) }
    Size      = @{ Width  = $ExternalProgramsProcmonGroupBox.Size.Width
                   Height = $FormScale * 135 }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
            $ExeScriptProgramLabel = New-Object System.Windows.Forms.Label -Property @{
                Location = @{ X = $FormScale * 5
                            Y = $FormScale * 20 }
                Size     = @{ Width  = $FormScale * 420
                            Height = $FormScale * 25 }
                Text      = "Allows for the custom deployment of executables and scripts. Execution flow, cleanup, and retrieval of files is to be managed within the accompanying script."
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptProgramLabel)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-UserSpecifiedExecutable.ps1"
            . "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-UserSpecifiedExecutable.ps1"
            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ExeScriptSelectExecutableButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\ExeScriptSelectExecutableButton.ps1"
            $ExeScriptSelectExecutableButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Dir or File"
                Location = @{ X = $ExeScriptProgramLabel.Location.X
                            Y = $ExeScriptProgramLabel.Location.Y + $ExeScriptProgramLabel.Size.Height + $($FormScale * 10) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Add_Click      = { Select-UserSpecifiedExecutable }
                Add_MouseHover = $ExeScriptSelectExecutableButtonAdd_MouseHover
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectExecutableButton)
            CommonButtonSettings -Button $ExeScriptSelectExecutableButton


            $ExeScriptSelectExecutableTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Directory:"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptSelectExecutableButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $FormScale * 200
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectExecutableTextBox)


            $ExeScriptSelectDirRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "Dir"
                Location = @{ X = $ExeScriptSelectExecutableTextBox.Location.X + $ExeScriptSelectExecutableTextBox.Size.Width + $($FormScale * 10)
                            Y = $ExeScriptSelectExecutableTextBox.Location.Y }
                Size     = @{ Width  = $FormScale * 45
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_Click = {
                    $ExeScriptSelectExecutableTextBox.text = "Directory:"
                    if ($ExeScriptSelectExecutableTextBox.text -eq "Directory:") {$ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false}
                }
                Checked   = $True
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectDirRadioButton)


            $ExeScriptSelectFileRadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
                Text     = "File"
                Location = @{ X = $ExeScriptSelectDirRadioButton.Location.X + $ExeScriptSelectDirRadioButton.Size.Width
                            Y = $ExeScriptSelectDirRadioButton.Location.Y }
                Size     = @{ Width  = $FormScale * 40
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                Add_Click = {
                    $ExeScriptSelectExecutableTextBox.text = "File:"
                    if ($ExeScriptSelectExecutableTextBox.text -eq "File:") {$ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false}
                }
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectFileRadioButton)



            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-UserSpecifiedScript.ps1"
            . "$Dependencies\Code\System.Windows.Forms\OpenFileDialog\Select-UserSpecifiedScript.ps1"
            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ExeScriptSelectScriptButton.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Button\ExeScriptSelectScriptButton.ps1"
            $ExeScriptSelectScriptButton = New-Object System.Windows.Forms.Button -Property @{
                Text     = "Select Script"
                Location = @{ X = $ExeScriptSelectExecutableButton.Location.X
                            Y = $ExeScriptSelectExecutableButton.Location.Y + $ExeScriptSelectExecutableButton.Size.Height + $($FormScale * 5) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Add_Click      = { Select-UserSpecifiedScript }
                Add_MouseHover = $ExeScriptSelectScriptButtonAdd_MouseHover
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectScriptButton)
            CommonButtonSettings -Button $ExeScriptSelectScriptButton


            $ExeScriptSelectScriptTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "Script:"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptSelectScriptButton.Location.Y + $($FormScale * 1) }
                Size     = @{ Width  = $ExeScriptSelectExecutableTextBox.Size.Width
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                BackColor = "White"
                Enabled   = $false
                Multiline = $true
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptSelectScriptTextBox)


            Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Checkbox\ExeScriptScriptOnlyCheckbox.ps1"
            . "$Dependencies\Code\System.Windows.Forms\Checkbox\ExeScriptScriptOnlyCheckbox.ps1"
            $ExeScriptScriptOnlyCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
                Text     = "Script Only"
                Location = @{ X = $ExeScriptSelectDirRadioButton.Location.X
                            Y = $ExeScriptSelectScriptTextBox.Location.Y }
                Size     = @{ Width  = $FormScale * 90
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
                Add_Click = $ExeScriptScriptOnlyCheckboxAdd_Click
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptScriptOnlyCheckbox)


            $ExeScriptDestinationDirectoryLabel = New-Object System.Windows.Forms.Label -Property @{
                Text     = "Destination Folder:"
                Location = @{ X = $ExeScriptSelectScriptButton.Location.X
                            Y = $ExeScriptSelectScriptButton.Location.Y + $ExeScriptSelectScriptButton.Size.Height + $($FormScale * 7) }
                Size     = @{ Width  = $FormScale * 110
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                ForeColor = "Black"
            }
            $ExeScriptProgramGroupBox.Controls.Add($ExeScriptDestinationDirectoryLabel)


            $script:ExeScriptDestinationDirectoryTextBox = New-Object System.Windows.Forms.Textbox -Property @{
                Text     = "C:\Windows\Temp\"
                Location = @{ X = $FormScale * 125
                            Y = $ExeScriptDestinationDirectoryLabel.Location.Y - $($FormScale * 2) }
                Size     = @{ Width  = $FormScale * 300
                            Height = $FormScale * 22 }
                Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                AutoCompleteSource = "FileSystem"
                AutoCompleteMode   = "SuggestAppend"
                }
            $ExeScriptProgramGroupBox.Controls.Add($script:ExeScriptDestinationDirectoryTextBox)
$Section1ExecutablesTab.Controls.Add($ExeScriptProgramGroupBox)
