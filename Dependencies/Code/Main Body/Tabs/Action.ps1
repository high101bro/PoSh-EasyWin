
$Column5RightPosition     = 3
$Column5DownPosition      = 6
$Column5DownPositionShift = 28
$Column5BoxWidth          = 124
$Column5BoxHeight         = 22

Update-FormProgress "$Dependencies\Code\Tree View\Computer\Create-ComputerNodeCheckBoxArray.ps1"
. "$Dependencies\Code\Tree View\Computer\Create-ComputerNodeCheckBoxArray.ps1"

Update-FormProgress "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedLessThanOne.ps1"
. "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedLessThanOne.ps1"

Update-FormProgress "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedMoreThanOne.ps1"
. "$Dependencies\Code\Tree View\Computer\ComputerNodeSelectedMoreThanOne.ps1"

Update-FormProgress "$Dependencies\Code\Tree View\Computer\Verify-Action.ps1"
. "$Dependencies\Code\Tree View\Computer\Verify-Action.ps1"

$Section3ActionTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "Action"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Height = $FormScale * $Column5BoxWidth
    Width  = $FormScale * $Column5BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainRightTabControl.Controls.Add($Section3ActionTab)


<# TODO: Needs more testing
# Used to verify settings before capturing memory as this can be quite resource exhaustive
# Contains various checks to ensure that adequate resources are available on the remote and local hosts
Update-FormProgress "$Dependencies\Code\Execution\Action\Launch-RekallWinPmemForm.ps1"
. "$Dependencies\Code\Execution\Action\Launch-RekallWinPmemForm.ps1"


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\RekallWinPmemMemoryCaptureButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\RekallWinPmemMemoryCaptureButton.ps1"
$RekallWinPmemMemoryCaptureButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Memory Capture"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_MouseHover = $RekallWinPmemMemoryCaptureButtonAdd_MouseHover
    Add_Click      = $RekallWinPmemMemoryCaptureButtonAdd_Click
}
CommonButtonSettings -Button $RekallWinPmemMemoryCaptureButton


# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\WinPmem\WinPmem.exe") { $Section3ActionTab.Controls.Add($RekallWinPmemMemoryCaptureButton) }

$Column5DownPosition += $Column5DownPositionShift
#>

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\EventViewerButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\EventViewerButton.ps1"
$EventViewerButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Event Viewer'
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Height = $FormScale * $Column5BoxHeight
    Width  = $FormScale * $Column5BoxWidth
    Add_Click = $EventViewerButtonAdd_Click
    Add_MouseHover = $EventViewerButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($EventViewerButton)
CommonButtonSettings -Button $EventViewerButton

$Column5DownPosition += $Column5DownPositionShift


#. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListScreenShot.ps1"

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListRDPButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListRDPButton.ps1"
$ComputerListRDPButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'Remote Desktop'
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click = $ComputerListRDPButtonAdd_Click
    Add_MouseHover = $ComputerListRDPButtonAdd_MouseHover
    Add_MouseEnter = {$script:ComputerListEndpointNameToolStripLabel.text = $null}
}
$Section3ActionTab.Controls.Add($ComputerListRDPButton)
CommonButtonSettings -Button $ComputerListRDPButton

$Column5DownPosition += $Column5DownPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPSSessionButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPSSessionButton.ps1"
$ComputerListPSSessionButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "PS Session"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click      = $ComputerListPSSessionButtonAdd_Click
    Add_MouseHover = $ComputerListPSSessionButtonAdd_MouseHover
    Add_MouseEnter = {$script:ComputerListEndpointNameToolStripLabel.text = $null}
}
$Section3ActionTab.Controls.Add($ComputerListPSSessionButton)
CommonButtonSettings -Button $ComputerListPSSessionButton

$Column5DownPosition += $Column5DownPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPsExecButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListPsExecButton.ps1"
$ComputerListPsExecButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = 'PsExec'
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click = $ComputerListPsExecButtonAdd_Click
    Add_MouseHover = $ComputerListPsExecButtonAdd_MouseHover
    Add_MouseEnter = {$script:ComputerListEndpointNameToolStripLabel.text = $null}
}
CommonButtonSettings -Button $ComputerListPsExecButton

# Test if the External Programs directory is present; if it's there load the tab
if (Test-Path "$ExternalPrograms\PsExec.exe") { $Section3ActionTab.Controls.Add($ComputerListPsExecButton) }

$Column5DownPosition += $Column5DownPositionShift


# Rolls the credenaisl: 250 characters of random: abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890
Update-FormProgress "$Dependencies\Code\Credential Management\Generate-NewRollingPassword.ps1"
. "$Dependencies\Code\Credential Management\Generate-NewRollingPassword.ps1"

# Used to create new credentials (Get-Credential), create a log entry, and save an encypted local copy
Update-FormProgress "$Dependencies\Code\Credential Management\Create-NewCredentials.ps1"
. "$Dependencies\Code\Credential Management\Create-NewCredentials.ps1"
# Encrypt an exported credential object
# The Export-Clixml cmdlet encrypts credential objects by using the Windows Data Protection API.
# The encryption ensures that only your user account on only that computer can decrypt the contents of the
# credential object. The exported CLIXML file can't be used on a different computer or by a different user.

# Code to launch the Credential Management Form
# Provides the abiltiy to select create, select, and save credentials
# Provides the option to enable password auto rolling
Update-FormProgress "$Dependencies\Code\Credential Management\Launch-CredentialManagementForm.ps1"
. "$Dependencies\Code\Credential Management\Launch-CredentialManagementForm.ps1"


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ProvideCredentialsButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ProvideCredentialsButton.ps1"
$ProvideCredentialsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Manage Credentials"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight
    Add_Click      = $ProvideCredentialsButtonAdd_Click
    Add_MouseHover = $ProvideCredentialsButtonAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ProvideCredentialsButton)
CommonButtonSettings -Button $ProvideCredentialsButton

$Column5DownPosition += $Column5DownPositionShift - 2


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\CheckBox\ComputerListProvideCredentialsCheckBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\CheckBox\ComputerListProvideCredentialsCheckBox.ps1"
$ComputerListProvideCredentialsCheckBox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Specify Credentials"
    Left   = $FormScale * $Column5RightPosition + 1
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * $Column5BoxHeight - 5
    Checked = $false
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click      = $ComputerListProvideCredentialsCheckBoxAdd_Click
    Add_MouseHover = $ComputerListProvideCredentialsCheckBoxAdd_MouseHover
}
$Section3ActionTab.Controls.Add($ComputerListProvideCredentialsCheckBox)

$Column5DownPosition += $Column5DownPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandTreeViewQueryMethodSelectionComboBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\ComboBox\CommandTreeViewQueryMethodSelectionComboBox.ps1"
$script:CommandTreeViewQueryMethodSelectionComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = ($FormScale * $Column5BoxWidth + 1)
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor     = 'Black'
    DropDownStyle = 'DropDownList'
    Add_SelectedIndexChanged = {
        & $script:CommandTreeViewQueryMethodSelectionComboBoxAdd_SelectedIndexChanged
        #$This.Text | Set-Content "$PoShHome\Settings\Script Execution Mode.txt" -Force

        if ($this.SelectedItem -eq 'Monitor Jobs') {
            $Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionLabel)
            $Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionComboBox)
            $Column5DownPosition += $Column5DownPositionShift
            $script:ComputerListExecuteButton.Top = $script:OptionJobTimeoutSelectionLabel.Top + $($FormScale * $Column5DownPositionShift)
        }
        else {
            $Section3ActionTab.Controls.Remove($script:OptionJobTimeoutSelectionLabel)
            $Section3ActionTab.Controls.Remove($script:OptionJobTimeoutSelectionComboBox)
            $script:ComputerListExecuteButton.Top = $this.Top + $($FormScale * $Column5DownPositionShift)
        }
    }
}
$QueryMethodSelectionList = @(
    'Monitor Jobs',
    'Individual Execution',
    'Session Based'
    #'Compiled Script'
    )
Foreach ($QueryMethod in $QueryMethodSelectionList) { $script:CommandTreeViewQueryMethodSelectionComboBox.Items.Add($QueryMethod) }
if (Test-Path "$PoShHome\Settings\Script Execution Mode.txt") { $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem = Get-Content "$PoShHome\Settings\Script Execution Mode.txt" }
else { $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 }
$Section3ActionTab.Controls.Add($script:CommandTreeViewQueryMethodSelectionComboBox)

$Column5DownPosition += $Column5DownPositionShift + 2


$script:OptionJobTimeoutSelectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Job Timeout:"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * 70
    Height = $FormScale * $Column5BoxHeight
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionLabel)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ComboBox\OptionJobTimeoutSelectionComboBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\ComboBox\OptionJobTimeoutSelectionComboBox.ps1"
$script:OptionJobTimeoutSelectionComboBox = New-Object -TypeName System.Windows.Forms.Combobox -Property @{
    Text   = $JobTimeOutSeconds
    Left   = $script:OptionJobTimeoutSelectionLabel.Left + $script:OptionJobTimeoutSelectionLabel.Width + $($FormScale * 5)
    Top    = $script:OptionJobTimeoutSelectionLabel.Top - $($FormScale * 3)
    Width  = $FormScale * 50
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,2,0)
    AutoCompleteMode = "SuggestAppend"
    Add_MouseHover   = $script:OptionJobTimeoutSelectionComboBoxAdd_MouseHover
    Add_SelectedIndexChanged = { $This.Text | Set-Content "$PoShHome\Settings\Job Timeout.txt" -Force }
}
$JobTimesAvailable = @(15,30,45,60,120,180,240,300,600)
ForEach ($Item in $JobTimesAvailable) { $script:OptionJobTimeoutSelectionComboBox.Items.Add($Item) }
if (Test-Path "$PoShHome\Settings\Job Timeout.txt") { $script:OptionJobTimeoutSelectionComboBox.text = Get-Content "$PoShHome\Settings\Job Timeout.txt" }
$Section3ActionTab.Controls.Add($script:OptionJobTimeoutSelectionComboBox)

$Column5DownPosition += $Column5DownPositionShift - $($FormScale * 2)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\ComputerListExecuteButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ComputerListExecuteButton.ps1"
$script:ComputerListExecuteButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Execute Script"
    Left   = $FormScale * $Column5RightPosition
    Top    = $FormScale * $Column5DownPosition
    Width  = $FormScale * $Column5BoxWidth
    Height = $FormScale * ($Column5BoxHeight * 2) - 10
    Enabled   = $false
    Add_MouseHover = $script:ComputerListExecuteButtonAdd_MouseHover
}
### $script:ComputerListExecuteButton.Add_Click($ExecuteScriptHandler) ### Is located lower in the script
$Section3ActionTab.Controls.Add($script:ComputerListExecuteButton)
CommonButtonSettings -Button $script:ComputerListExecuteButton
