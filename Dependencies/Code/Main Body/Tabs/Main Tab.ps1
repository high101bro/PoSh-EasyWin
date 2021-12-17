
$MainCenterMainTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Main  "
    Name = "Main"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 0
}
$MainCenterTabControl.Controls.Add($MainCenterMainTab)


$DirectoryListLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Results Folder:"
    Left   = $FormScale * 3
    Top    = $FormScale * 4
    Width  = $FormScale * 120
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($DirectoryListLabel)


# This shows the name of the directy that data will be currently saved to
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\CollectionSavedDirectoryTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\CollectionSavedDirectoryTextBox.ps1"
$script:CollectionSavedDirectoryTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Name   = "Saved Directory List Box"
    Text   = $SaveLocation
    Left   = $DirectoryListLabel.Left
    Top    = $DirectoryListLabel.Top + $DirectoryListLabel.Height
    #Width  = $FormScale * 354
    Width  = $FormScale * 595
    Height = $FormScale * 22
    WordWrap   = $false
    AcceptsTab = $true
    TabStop    = $true
    Multiline  = $false
    AutoSize   = $false
    Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoCompleteSource = "FileSystem"
    AutoCompleteMode   = "SuggestAppend"
    Add_MouseHover     = $CollectionSavedDirectoryTextBoxAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($script:CollectionSavedDirectoryTextBox)


$ResultsFolderAutoTimestampCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text   = "Auto Timestamp"
    Top    = $script:CollectionSavedDirectoryTextBox.Top + $script:CollectionSavedDirectoryTextBox.Height + $($FormScale * 5)
    Left   = $script:CollectionSavedDirectoryTextBox.Left + ($FormScale * 240)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Checked = $true
}
$MainCenterMainTab.Controls.Add($ResultsFolderAutoTimestampCheckbox)


$SaveResultsToFileShareCheckbox = New-Object System.Windows.Forms.Checkbox -Property @{
    Text   = "Use File Share"
    Top    = $ResultsFolderAutoTimestampCheckbox.Top
    Left   = $CollectionSavedDirectoryTextBox.Left + ($FormScale * 125)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Checked = $false
    add_click = {
        if ($This.Checked) {
            . "$Dependencies\Code\Main Body\Launch-FileShareConnection.ps1"
        }
        else {
            $script:CollectionSavedDirectoryTextBox.Text = $SaveLocation
        }
    }
}
$MainCenterMainTab.Controls.Add($SaveResultsToFileShareCheckbox)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\DirectoryUpdateButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryUpdateButton.ps1"
$DirectoryUpdateButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "New Timestamp"
    Top    = $ResultsFolderAutoTimestampCheckbox.Top
    # Left   = $DirectoryOpenButton.Left + $DirectoryOpenButton.width + ($FormScale * 5)
    Left   = $ResultsFolderAutoTimestampCheckbox.Left + $ResultsFolderAutoTimestampCheckbox.Width + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $DirectoryUpdateButtonAdd_Click
    Add_MouseHover = $DirectoryUpdateButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryUpdateButton)
Apply-CommonButtonSettings -Button $DirectoryUpdateButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\DirectoryOpenButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\DirectoryOpenButton.ps1"
$DirectoryOpenButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Open Folder"
    Top    = $DirectoryUpdateButton.Top
    Left   = $DirectoryUpdateButton.Left + $DirectoryUpdateButton.Width + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $DirectoryOpenButtonAdd_Click
    Add_MouseHover = $DirectoryOpenButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($DirectoryOpenButton)
Apply-CommonButtonSettings -Button $DirectoryOpenButton


$ResultsSectionLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Actions and Analysis:"
    Left   = $CollectionSavedDirectoryTextBox.Left
    Top    = $DirectoryUpdateButton.Top + $DirectoryUpdateButton.Height + $($FormScale * 13)
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($ResultsSectionLabel)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\SendFilesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\SendFilesButton.ps1"
$SendFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Send Files"
    Left   = $ResultsSectionLabel.Left
    Top    = $ResultsSectionLabel.Top + $ResultsSectionLabel.Height + ($FormScale * 1)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = $SendFilesButtonAdd_Click
}
$MainCenterMainTab.Controls.Add($SendFilesButton)
Apply-CommonButtonSettings -Button $SendFilesButton


# batman
# Update-FormProgress "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
# . "$Dependencies\Code\Charts\Generate-AutoChartsCommand.ps1"
# Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateMultiSeriesChartButton.ps1"
# . "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateMultiSeriesChartButton.ps1"
# $AutoCreateMultiSeriesChartButton = New-Object System.Windows.Forms.Button -Property @{
#     Text   = "Multi-Charts"
#     Left   = $ResultsSectionLabel.Left
#     Top    = $ResultsSectionLabel.Top + $ResultsSectionLabel.Height + ($FormScale * 1)
#     Width  = $FormScale * 115
#     Height = $FormScale * 22
#     Add_Click      = $AutoCreateMultiSeriesChartButtonAdd_Click
#     Add_MouseHover = $AutoCreateMultiSeriesChartButtonAdd_MouseHover
# }
# $MainCenterMainTab.Controls.Add($AutoCreateMultiSeriesChartButton)
# Apply-CommonButtonSettings -Button $AutoCreateMultiSeriesChartButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\PSWriteHTMLButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\PSWriteHTMLButton.ps1"
$PSWriteHTMLButton = New-Object System.Windows.Forms.Button -Property @{
    Left   = $SendFilesButton.Left + $SendFilesButton.Width + $($FormScale * 5)
    Top    = $SendFilesButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $PSWriteHTMLButtonAdd_Click
    Add_MouseHover = $PSWriteHTMLButtonAdd_MouseHover
    Enabled = $false
}
$MainCenterMainTab.Controls.Add($PSWriteHTMLButton)
Apply-CommonButtonSettings -Button $PSWriteHTMLButton
if ((Test-Path -Path "$Dependencies\Modules\PSWriteHTML") -and (Get-Content "$PoShHome\Settings\PSWriteHTML Module Install.txt") -match 'Yes') {
    $PSWriteHTMLButton.enabled = $true
    $PSWriteHTMLButton.Text    = "Graph Data [Beta]"
}

# This is placed here as the code is used with the "Open Data In Shell" button in the main form as well as within the dashboards
Update-FormProgress "$Dependencies\Code\Main Body\script:Open-XmlResultsInShell.ps1"
. "$Dependencies\Code\Main Body\script:Open-XmlResultsInShell.ps1"

Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AutoChartSelectChartComboBoxSelectedItem_Monitor-Jobs.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoChartSelectChartComboBoxSelectedItem_Monitor-Jobs.ps1"


# Used to populate the dashboard choices form
Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateDashboardChartButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\AutoCreateDashboardChartButton.ps1"
$AutoCreateDashboardChartButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Dashboard Charts"
    Left   = $PSWriteHTMLButton.Left + $PSWriteHTMLButton.Width + $($FormScale * 5)
    Top    = $PSWriteHTMLButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $AutoCreateDashboardChartButtonAdd_Click
    Add_MouseHover = $AutoCreateDashboardChartButtonAdd_MouseHover
    Enabled        = $true
}
$MainCenterMainTab.Controls.Add($AutoCreateDashboardChartButton)
Apply-CommonButtonSettings -Button $AutoCreateDashboardChartButton


$TeamChatPopoutClientButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Start Chat Client"
    Left   = $AutoCreateDashboardChartButton.Left + $AutoCreateDashboardChartButton.Width + $($FormScale * 5)
    Top    = $AutoCreateDashboardChartButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = {
        if (Verify-Action -Title "Team Chat Client" -Question "Do you want to launch the team chat client?") {
            . "$Dependencies\Code\PoSh-Chat\Start-PoShChatClient.ps1"
        }
    }
}
$MainCenterMainTab.Controls.Add($TeamChatPopoutClientButton)
Apply-CommonButtonSettings -Button $TeamChatPopoutClientButton


$PowerShellTerminalButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "PowerShell"
    Left   = $TeamChatPopoutClientButton.Left + $TeamChatPopoutClientButton.Width + $($FormScale * 5)
    Top    = $TeamChatPopoutClientButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = {
        if (Verify-Action -Title "Team Chat" -Question "Do you want to launch a PowerShell terminal?") {
            Start-Process PowerShell.exe
        }
    }
}
$MainCenterMainTab.Controls.Add($PowerShellTerminalButton)
Apply-CommonButtonSettings -Button $PowerShellTerminalButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\RetrieveFilesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\RetrieveFilesButton.ps1"
Update-FormProgress "$Dependencies\Code\Main Body\Get-RemoteFile.ps1"
. "$Dependencies\Code\Main Body\Get-RemoteFile.ps1"
$RetrieveFilesButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Retrieve Files"
    Left   = $SendFilesButton.Left
    Top    = $SendFilesButton.Top + $SendFilesButton.Height + $($FormScale * 5)
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $RetrieveFilesButtonAdd_Click
    Add_MouseHover = $RetrieveFilesButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($RetrieveFilesButton)
Apply-CommonButtonSettings -Button $RetrieveFilesButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpenXmlResultsButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpenXmlResultsButton.ps1"
$OpenXmlResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Open Data In Shell"
    Left   = $RetrieveFilesButton.Left + $RetrieveFilesButton.Width + $($FormScale * 5)
    Top    = $RetrieveFilesButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $OpenXmlResultsButtonAdd_Click
    Add_MouseHover = $OpenXmlResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenXmlResultsButton)
Apply-CommonButtonSettings -Button $OpenXmlResultsButton


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpenCsvResultsButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpenCsvResultsButton.ps1"
$OpenCsvResultsButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "View CSV Results"
    Left   = $OpenXmlResultsButton.Left + $OpenXmlResultsButton.Width + $($FormScale * 5)
    Top    = $OpenXmlResultsButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click      = $OpenCsvResultsButtonAdd_Click
    Add_MouseHover = $OpenCsvResultsButtonAdd_MouseHover
}
$MainCenterMainTab.Controls.Add($OpenCsvResultsButton)
Apply-CommonButtonSettings -Button $OpenCsvResultsButton


$TeamChatStartChatServerButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Start Chat Server"
    Left   = $OpenCsvResultsButton.Left + $OpenCsvResultsButton.Width + $($FormScale * 5)
    Top    = $OpenCsvResultsButton.Top
    Width  = $FormScale * 115
    Height = $FormScale * 22
    Add_Click = {
        if (Verify-Action -Title "Team Chat Server" -Question "Do you want to launch the team chat server?`n`nEnsure to only have one instance running to avoid issues.`nThe server is hosted on port TCP/15600.") {
            New-Item -ItemType Directory -Path "$PoShHome\Team Chat Logs\" -ErrorAction SilentlyContinue
            $Datetime = (Get-Date).ToString('yyyy-MM-dd HH.mm.ss')
            Start-Process PowerShell.exe -ArgumentList @("-NoExit & '$Dependencies\code\PoSh-Chat\Start-PoshChatServer.ps1' -EnableLogging '$PoSHHome\Team Chat Logs\team chat ($Datetime).log'")
        }
    }
}
$MainCenterMainTab.Controls.Add($TeamChatStartChatServerButton)
Apply-CommonButtonSettings -Button $TeamChatStartChatServerButton


# The Launch-ChartImageSaveFileDialog function is use by 'build charts and autocharts'
Update-FormProgress "$Dependencies\Code\Charts\Launch-ChartImageSaveFileDialog.ps1"
. "$Dependencies\Code\Charts\Launch-ChartImageSaveFileDialog.ps1"


# Increases the chart size by 4 then saves it to file
Update-FormProgress "$Dependencies\Code\Charts\Save-ChartImage.ps1"
. "$Dependencies\Code\Charts\Save-ChartImage.ps1"


$StatusLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Status:"
    Left   = $RetrieveFilesButton.Left
    Top    = $RetrieveFilesButton.Top + $RetrieveFilesButton.Height + $FormScale * 28
    Width  = $FormScale * 60
    Height = $FormScale * 20
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
$MainCenterMainTab.Controls.Add($StatusLabel)


$StatusListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name   = "StatusListBox"
    Left   = $StatusLabel.Left + $StatusLabel.Width
    Width  = $FormScale * 535
    Top    = $StatusLabel.Top
    Height = $FormScale * 22
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    FormattingEnabled = $True
}
$StatusListBox.Items.Add("Welcome to PoSh-EasyWin!") | Out-Null
$MainCenterMainTab.Controls.Add($StatusListBox)


$ProgressBarEndpointsLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Endpoint:"
    Left   = $StatusLabel.Left
    Top    = $StatusLabel.Top + $StatusLabel.Height
    Width  = $StatusLabel.Width
    Height = $StatusLabel.Height
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainCenterMainTab.Controls.Add($ProgressBarEndpointsLabel)


$script:ProgressBarEndpointsProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Left   = $ProgressBarEndpointsLabel.Left + $ProgressBarEndpointsLabel.Width
    Width = $StatusListBox.Width - ($FormScale * 1)
    Top    = $ProgressBarEndpointsLabel.Top
    Height = $FormScale * 15
    Forecolor = 'LightBlue'
    BackColor = 'white'
    Style     = "Continuous" #"Marque"
    Minimum   = 0
}
$MainCenterMainTab.Controls.Add($script:ProgressBarEndpointsProgressBar)


$ProgressBarQueriesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Task:"
    Left   = $ProgressBarEndpointsLabel.Left
    Top    = $ProgressBarEndpointsLabel.Top + $ProgressBarEndpointsLabel.Height
    Width  = $ProgressBarEndpointsLabel.Width
    Height = $ProgressBarEndpointsLabel.Height
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$MainCenterMainTab.Controls.Add($ProgressBarQueriesLabel)


$script:ProgressBarQueriesProgressBar = New-Object System.Windows.Forms.ProgressBar -Property @{
    Left = $ProgressBarQueriesLabel.Left + $ProgressBarQueriesLabel.Width
    Width = $StatusListBox.Width - ($FormScale * 1)
    Top = $ProgressBarQueriesLabel.Top
    Height = $FormScale * 15
    Forecolor = 'LightGreen'
    BackColor = 'white'
    Style     = "Continuous"
    Minimum   = 0
}
$MainCenterMainTab.Controls.Add($script:ProgressBarQueriesProgressBar)

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWVvLpjr66DlfBZWSBHGgTf69
# PBmgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU5ySoK87dOE77SNWlsUl8jnPQ3KQwDQYJKoZI
# hvcNAQEBBQAEggEAT4cG+atIAWpjJ39QUDMsKCilR0KcqK9do3kCxsMstYhD7P6B
# azKaEuzS3Rrpr1UdXZfIPXMZSmDxTc7pYTKPlwYrEmUBY8qoSVG3wFPtcjoU2G6e
# XPyco1ag/cs7p7wnQg7ovyDNCuHHX4u3EFsiiGZofDTsGMtxqXZasi9xTwxZrNf6
# gGLFj6i/f7thufUsZx39PlKfScq0yT69g1QCDmotqALcegktHx6vT7998joJX3WQ
# FbeTlLHsgaqLd9yvmv2Q0DAdOjTKVBgwqPwHRZFaOuUldB7zRmBV90daX7f+fOvN
# D4X8YCerU9fTr9/EKRHpX8PbZuAkE/+mOggwxA==
# SIG # End signature block
