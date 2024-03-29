####################################################################################################
# ScriptBlocks
####################################################################################################
Update-FormProgress "Options.ps1 - ScriptBlocks"

$PoShEasyWinLicenseAndAboutButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3AboutTab

    if ($PoShEasyWinLicenseAndAboutButton.Text -eq "License (GPLv3)" ) {
        $PoShEasyWinLicenseAndAboutButton.Text = "About PoSh-EasyWin"
        $Section1AboutSubTabRichTextBox.Text   = $(Get-Content "$Dependencies\GPLv3 - GNU General Public License.txt" -raw)
    }
    elseif ($PoShEasyWinLicenseAndAboutButton.Text -eq "About PoSh-EasyWin" ) {
        $PoShEasyWinLicenseAndAboutButton.Text = "License (GPLv3)"
        $Section1AboutSubTabRichTextBox.Text   = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    }
}

$PoShEasyWinLicenseAndAboutButtonAdd_MouseHover = {
    Show-ToolTip -Title "Posh-EasyWin" -Icon "Info" -Message @"
+  Switch between the following:
     About PoSh-EasyWin
     GNU General Public License v3
"@
}

####################################################################################################
# WinForms
####################################################################################################
Update-FormProgress "Options.ps1 - WinForms"

$Section2OptionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Options  "
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 1
}
$MainCenterTabControl.Controls.Add($Section2OptionsTab)


$OptionViewReadMeButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "View Read Me"
    Left   = $FormScale * 3
    Top    = $FormScale * 3
    Width  = $FormScale * 100
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { Show-ReadMe -ReadMe }
}
$Section2OptionsTab.Controls.Add($OptionViewReadMeButton)
Add-CommonButtonSettings -Button $OptionViewReadMeButton


$PoShEasyWinLicenseAndAboutButton = New-Object Windows.Forms.Button -Property @{
    Text   = "License (GPLv3)"
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Left   = $OptionViewReadMeButton.Left + $OptionViewReadMeButton.Width + ($FormScale * 5)
    Top    = $OptionViewReadMeButton.Top
    Width  = $FormScale * 150
    Height = $FormScale * 22
    Add_Click      = $PoShEasyWinLicenseAndAboutButtonAdd_Click
    Add_MouseHover = $PoShEasyWinLicenseAndAboutButtonAdd_MouseHover
}
$Section2OptionsTab.Controls.Add($PoShEasyWinLicenseAndAboutButton)
Add-CommonButtonSettings -Button $PoShEasyWinLicenseAndAboutButton


$OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox = New-Object System.Windows.Forms.Groupbox -Property @{
    Text   = "Search Endpoints for Previously Collected Data"
    Top    = $OptionViewReadMeButton.Top + $OptionViewReadMeButton.Height + $($FormScale * 5)
    Left   = $FormScale * 3
    # Width  = $FormScale * 352
    Width  = $FormScale * 590
    Height = $FormScale * 100
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
}

    $PewCollectedDataSearchLimitComboBox = New-Object System.Windows.Forms.Combobox -Property @{
        Text   = 50
        Left   = $FormScale * 10
        Top    = $FormScale * 15
        Width  = $FormScale * 50
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_MouseHover  = {
Show-ToolTip -Title "Statistics Update Interval" -Icon "Info" -Message @"
+  This is how many directories to search for data within the Collected Data directory.
+  It allows you to search for specified data within previous data collections.
+  The more directories you search, the longer the wait time.
"@
        }
        Add_SelectedIndexChanged = { $This.Text | Set-Content "$PewSettings\Directory Search Limit.txt" -Force }
    }
    $NumberOfDirectoriesToSearchBack = @(25,50,100,150,200,250,500,750,1000)
    ForEach ($Item in $NumberOfDirectoriesToSearchBack) { $PewCollectedDataSearchLimitComboBox.Items.Add($Item) }
    if (Test-Path "$PewSettings\Directory Search Limit.txt") { $PewCollectedDataSearchLimitComboBox.text = Get-Content "$PewSettings\Directory Search Limit.txt" }
    $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($PewCollectedDataSearchLimitCombobox)


    $PewCollectedDataSearchLimitLabel = New-Object System.Windows.Forms.Label -Property @{
        Text   = "Number of Past Directories to Search"
        Left   = $PewCollectedDataSearchLimitCombobox.Size.Width + $($FormScale * 10)
        Top    = $PewCollectedDataSearchLimitCombobox.Top + $($FormScale + 3)
        Width  = $FormScale * 200
        Height = $FormScale * 22
        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($PewCollectedDataSearchLimitLabel)


    $OptionSearchProcessesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text    = "Processes"
        Left    = $FormScale * 10
        Top     = $PewCollectedDataSearchLimitLabel.Top + $PewCollectedDataSearchLimitLabel.Height
        Width   = $FormScale * 200
        Height  = $FormScale * 20
        Enabled = $true
        Checked = $False
        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_Click = { $This.Checked | Set-Content "$PewSettings\Search - Processes Checkbox.txt" -Force }
    }
    if (Test-Path "$PewSettings\Search - Processes Checkbox.txt") {
        if ((Get-Content "$PewSettings\Search - Processes Checkbox.txt") -eq 'True'){$OptionSearchProcessesCheckBox.checked = $true}
        else {$OptionSearchProcessesCheckBox.checked = $false}
    }
    $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchProcessesCheckBox)


    $OptionSearchServicesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text    = "Services"
        Left    = $FormScale * 10
        Top     = $OptionSearchProcessesCheckBox.Top + $OptionSearchProcessesCheckBox.Height
        Width   = $FormScale * 200
        Height  = $FormScale * 20
        Enabled = $true
        Checked = $False
        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_Click = { $This.Checked | Set-Content "$PewSettings\Search - Services Checkbox.txt" -Force }
    }
    if (Test-Path "$PewSettings\Search - Services Checkbox.txt") {
        if ((Get-Content "$PewSettings\Search - Services Checkbox.txt") -eq 'True'){$OptionSearchServicesCheckBox.checked = $true}
        else {$OptionSearchServicesCheckBox.checked = $false}
    }
    $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchServicesCheckBox)


    $OptionSearchNetworkTCPConnectionsCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text    = "Network TCP Connections"
        Left    = $FormScale * 10
        Top     = $OptionSearchServicesCheckBox.Top + $OptionSearchServicesCheckBox.Height - $($FormScale + 1)
        Width   = $FormScale * 200
        Height  = $FormScale * 20
        Enabled = $true
        Checked = $False
        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_Click = { $This.Checked | Set-Content "$PewSettings\Search - Network TCP Connections Checkbox.txt" -Force }
    }
    if (Test-Path "$PewSettings\Search - Network TCP Connections Checkbox.txt") {
        if ((Get-Content "$PewSettings\Search - Network TCP Connections Checkbox.txt") -eq 'True'){$OptionSearchNetworkTCPConnectionsCheckBox.checked = $true}
        else {$OptionSearchNetworkTCPConnectionsCheckBox.checked = $false}
    }
    $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Controls.Add($OptionSearchNetworkTCPConnectionsCheckBox)
$Section2OptionsTab.Controls.Add($OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox)


$script:OptionMonitorJobsDefaultRestartTimeCombobox = New-Object System.Windows.Forms.Combobox -Property @{
    Text   = 60
    Left   = $FormScale * 3
    Top    = $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Top + $OptionSearchComputersForPreviouslyCollectedDataProcessesGroupBox.Height + $($FormScale + 2)
    Width  = $FormScale * 50
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_SelectedIndexChanged = { $This.Text | Set-Content "$PewSettings\Monitor Jobs Default Restart Time.txt" -Force }
}
$MonitorJobDefaultRestartTimesAvailable = @(1,5,10,15,30,60,120,300,600,1800,3600)
ForEach ($Item in $MonitorJobDefaultRestartTimesAvailable) { $script:OptionMonitorJobsDefaultRestartTimeCombobox.Items.Add($Item) }
if (Test-Path "$PewSettings\Monitor Jobs Default Restart Time.txt") { $script:OptionMonitorJobsDefaultRestartTimeCombobox.text = Get-Content "$PewSettings\Monitor Jobs Default Restart Time.txt" }
$Section2OptionsTab.Controls.Add($script:OptionMonitorJobsDefaultRestartTimeCombobox)


$OptionMonitorJobsDefaultRestartTimeLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Monitor Jobs Default Restart Time"
    Left   = $script:OptionMonitorJobsDefaultRestartTimeCombobox.Left + $script:OptionMonitorJobsDefaultRestartTimeCombobox.Width + $($FormScale + 5)
    Top    = $script:OptionMonitorJobsDefaultRestartTimeCombobox.Top + $($FormScale + 3)
    Width  = $FormScale * 200
    Height = $FormScale * 18
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$Section2OptionsTab.Controls.Add($OptionMonitorJobsDefaultRestartTimeLabel)


$script:LogCommandsInEndpointNotes = New-Object System.Windows.Forms.Checkbox -Property @{
    Text   = "Log Commands in Endpoint Notes"
    Left   = $script:OptionMonitorJobsDefaultRestartTimeCombobox.Left
    Top    = $script:OptionMonitorJobsDefaultRestartTimeCombobox.Top + $script:OptionMonitorJobsDefaultRestartTimeCombobox.Height + ($FormScale * 5)
    Width  = $FormScale * 210
    Height = $FormScale * 18
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Checked = $true
    Add_Click = { $This.Checked | Set-Content "$PewSettings\Log Commands in Endpoint Notes.txt" -Force }
}
if (Test-Path "$PewSettings\Log Commands in Endpoint Notes.txt") {
    if ((Get-Content "$PewSettings\Log Commands in Endpoint Notes.txt") -eq 'True'){$script:LogCommandsInEndpointNotes.checked = $true}
    else {$script:LogCommandsInEndpointNotes.checked = $false}
}

$Section2OptionsTab.Controls.Add($script:LogCommandsInEndpointNotes)

    $OptionGUITopWindowCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text    = "GUI always on top"
        Left    = $FormScale * 300
        Top     = $script:LogCommandsInEndpointNotes.Top
        Width   = $FormScale * 200
        Height  = $FormScale * 22
        Enabled = $true
        Checked = $false
        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_Click = {
            $This.checked | Set-Content "$PewSettings\GUI Top Most Window.txt" -Force

            # Option to toggle if the Windows is not the top most
            if   ( $OptionGUITopWindowCheckBox.checked ) { $PoShEasyWin.Topmost = $true }
            else { $PoShEasyWin.Topmost = $false }
        }
    }
    if (Test-Path "$PewSettings\GUI Top Most Window.txt") {
        if ((Get-Content "$PewSettings\GUI Top Most Window.txt") -eq 'True'){
            $OptionGUITopWindowCheckBox.checked = $true
            $PoShEasyWin.Topmost = $true
        }
        else {
            $OptionGUITopWindowCheckBox.checked = $false
            $PoShEasyWin.Topmost = $false
        }
    }
    $Section2OptionsTab.Controls.Add( $OptionGUITopWindowCheckBox )


    $OptionShowToolTipCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text    = "Show ToolTip"
        Left    = $OptionGUITopWindowCheckBox.Left
        Top     = $OptionGUITopWindowCheckBox.Top + $OptionGUITopWindowCheckBox.Height
        Width   = $FormScale * 200
        Height  = $FormScale * 22
        Enabled = $true
        Checked = $True
        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_Click = { $This.Checked | Set-Content "$PewSettings\Show Tool Tip.txt" -Force }
    }
    if (Test-Path "$PewSettings\Show Tool Tip.txt") {
        if ((Get-Content "$PewSettings\Show Tool Tip.txt") -eq 'True'){$OptionShowToolTipCheckBox.checked = $true}
        else {$OptionShowToolTipCheckBox.checked = $false}
    }
    $Section2OptionsTab.Controls.Add($OptionShowToolTipCheckBox)


    $script:OptionEventViewerCollectVerboseCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
        Text    = "Event Viewer Collect (Verbose)"
        Left    = $OptionShowToolTipCheckBox.Left
        Top     = $OptionShowToolTipCheckBox.Top + $OptionShowToolTipCheckBox.Height
        Width   = $FormScale * 200
        Height  = $FormScale * 22
        Enabled = $true
        Checked = $false
        Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_Click = { $This.Checked | Set-Content "$PewSettings\Event Viewer Collect Verbose.txt" -Force }
    }
    if (Test-Path "$PewSettings\Event Viewer Collect Verbose.txt") {
        if ((Get-Content "$PewSettings\Event Viewer Collect Verbose.txt") -eq 'True'){$script:OptionEventViewerCollectVerboseCheckBox.checked = $true}
        else {$script:OptionEventViewerCollectVerboseCheckBox.checked = $false}
    }
    $Section2OptionsTab.Controls.Add($script:OptionEventViewerCollectVerboseCheckBox)


$OptionTextToSpeachCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "Audible Completion Message"
    Left    = $FormScale * 3
    Top     = $script:LogCommandsInEndpointNotes.Top + $script:LogCommandsInEndpointNotes.Height
    Width   = $FormScale * 225
    Height  = $FormScale * 22
    Enabled = $true
    Checked = $false
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PewSettings\Audible Completion Message.txt" -Force }
}
if (Test-Path "$PewSettings\Audible Completion Message.txt") {
    if ((Get-Content "$PewSettings\Audible Completion Message.txt") -eq 'True'){$OptionTextToSpeachCheckBox.checked = $true}
    else {$OptionTextToSpeachCheckBox.checked = $false}
}
$Section2OptionsTab.Controls.Add($OptionTextToSpeachCheckBox)


$OptionPacketKeepEtlCabFilesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "Packet Captures - Keep .etc and .cab files"
    Left    = $FormScale * 3
    Top     = $OptionTextToSpeachCheckBox.Top + $OptionTextToSpeachCheckBox.Height
    Width   = $FormScale * 250
    Height  = $FormScale * 22
    Enabled = $true
    Checked = $false
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PewSettings\Packet Captures - Keep etl and cab files.txt" -Force }
}
if (Test-Path "$PewSettings\Packet Captures - Keep etl and cab files.txt") {
    if ((Get-Content "$PewSettings\Packet Captures - Keep etl and cab files.txt") -eq 'True'){$OptionPacketKeepEtlCabFilesCheckBox.checked = $true}
    else {$OptionPacketKeepEtlCabFilesCheckBox.checked = $false}
}
$Section2OptionsTab.Controls.Add($OptionPacketKeepEtlCabFilesCheckBox)


# # BUG: When the box is unchecked, the results don't compile correctly
# $OptionKeepResultsByEndpointsFilesCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
#     Text    = "Individual Execution - Keep Results by Endpoints"
#     Left    = $FormScale * 3
#     Top     = $OptionPacketKeepEtlCabFilesCheckBox.Top + $OptionPacketKeepEtlCabFilesCheckBox.Height
#     Width   = $FormScale * 300
#     Height  = $FormScale * 22
#     Enabled = $true
#     Checked = $false
#     Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     Add_Click = { $This.Checked | Set-Content "$PewSettings\Individual Execution - Keep Results by Endpoints.txt" -Force }
# }
# if (Test-Path "$PewSettings\Individual Execution - Keep Results by Endpoints.txt") {
#     if ((Get-Content "$PewSettings\Individual Execution - Keep Results by Endpoints.txt") -eq 'True'){$OptionKeepResultsByEndpointsFilesCheckBox.checked = $true}
#     else {$OptionKeepResultsByEndpointsFilesCheckBox.checked = $false}
# }
# $Section2OptionsTab.Controls.Add($OptionKeepResultsByEndpointsFilesCheckBox)


$OptionSaveCliXmlDataCheckBox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text    = "Save XML Data - Object Data Used For Terminals"
    Left    = $FormScale * 3
    Top     = $OptionPacketKeepEtlCabFilesCheckBox.Top + $OptionPacketKeepEtlCabFilesCheckBox.Height
    Width   = $FormScale * 300
    Height  = $FormScale * 22
    Enabled = $true
    Checked = $true
    Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_Click = { $This.Checked | Set-Content "$PewSettings\Save XML Data - Object Data Used For Terminals.txt" -Force }
}
if (Test-Path "$PewSettings\Save XML Data - Object Data Used For Terminals.txt") {
    if ((Get-Content "$PewSettings\Save XML Data - Object Data Used For Terminals.txt") -eq 'True'){$OptionSaveCliXmlDataCheckBox.checked = $true}
    else {$OptionSaveCliXmlDataCheckBox.checked = $false}
}
$Section2OptionsTab.Controls.Add($OptionSaveCliXmlDataCheckBox)










# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZvQPNDAiqA1LZr1nzbXMeFyn
# 2BygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUojue7whc5MXKzLYJpCkB0QB0Wo0wDQYJKoZI
# hvcNAQEBBQAEggEAjbeZMbpCfIC2wrQ12P3Ht92RfJ4Bb0ivq8SKoU4L9js7H6MY
# XK/aCsO9YmZWmQVzxu+xNkLljQ8vO0XCiQLkIvf0fofOw9Dgv6YdtfVJWCPsmSP1
# z9jJSM0BCp0gcM1EZ2KDQYB3oLlzDble96azov+rl1SGvy0WMc1JFDfWy1zTSfh5
# Y5xRxtMcctEzsi99JvOEZPT45h+gsOhizfGgESkr2nrEzxn2BoXZvuU17JIng+0f
# XLurSkH2CFYivVnH1Mtv2LeWpTYI1gCKPrXkZtj5bEfN4XZFjxfjWy3R/Pg1HC92
# 0g5N0Lv5w7VFNEDSVhsUZR+2qrStNDYAO0/7wQ==
# SIG # End signature block
