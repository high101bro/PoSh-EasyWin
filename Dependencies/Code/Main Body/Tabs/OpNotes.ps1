
$Section1OpNotesTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "OpNotes  "
    UseVisualStyleBackColor = $True
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ImageIndex = 4
}
$MainLeftTabControl.Controls.Add($Section1OpNotesTab)

$OpNotesInputTextBoxWidth  = 450
$OpNotesInputTextBoxHeight = 22
$OpNotesButtonWidth        = 100
$OpNotesButtonHeight       = 22
$OpNotesMainTextBoxWidth   = 450
$OpNotesMainTextBoxHeight  = 440
$OpNotesRightPositionStart = 0
$OpNotesRightPosition      = 0
$OpNotesRightPositionShift = $OpNotesButtonWidth + 10
$OpNotesDownPosition       = 7
$OpNotesDownPositionShift  = 22

# The purpose to allow saving of Opnotes automatcially
Update-FormProgress "$Dependencies\Code\Main Body\Save-OpNotes.ps1"
. "$Dependencies\Code\Main Body\Save-OpNotes.ps1"

# This function is called when pressing enter in the text box or click add
Update-FormProgress "$Dependencies\Code\Main Body\OpNoteTextBoxEntry.ps1"
. "$Dependencies\Code\Main Body\OpNoteTextBoxEntry.ps1"


$OpNotesLabel = New-Object System.Windows.Forms.Label -Property @{
    Text      = "Enter Your Operator Notes (OpNotes) - Auto-Timestamp:"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesInputTextBoxWidth
                  Height = $FormScale * $OpNotesInputTextBoxHeight }
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 13),1,2,1)
    ForeColor = "Blue"
}
$Section1OpNotesTab.Controls.Add($OpNotesLabel)

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\OpNotesInputTextBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\TextBox\OpNotesInputTextBox.ps1"
$OpNotesInputTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesInputTextBoxWidth
                  Height = $FormScale * $OpNotesInputTextBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    Add_KeyDown = $OpNotesInputTextBoxAdd_KeyDown
}
$Section1OpNotesTab.Controls.Add($OpNotesInputTextBox)

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpNotesAddButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesAddButton.ps1"
$OpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Add"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesAddButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesAddButton)
Apply-CommonButtonSettings -Button $OpNotesAddButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpNotesSelectAllButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesSelectAllButton.ps1"
$OpNotesSelectAllButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Select All"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesSelectAllButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesSelectAllButton)
Apply-CommonButtonSettings -Button $OpNotesSelectAllButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpNotesOpenOpNotesButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesOpenOpNotesButton.ps1"
$OpNotesOpenOpNotesButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open OpNotes"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesOpenOpNotesButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesOpenOpNotesButton)
Apply-CommonButtonSettings -Button $OpNotesOpenOpNotesButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveUpButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveUpButton.ps1"
$OpNotesMoveUpButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Up'
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesMoveUpButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesMoveUpButton)
Apply-CommonButtonSettings -Button $OpNotesMoveUpButton

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)
$OpNotesRightPosition = $OpNotesRightPositionStart


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpNotesRemoveButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesRemoveButton.ps1"
$OpNotesRemoveButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Remove'
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesRemoveButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesRemoveButton)
Apply-CommonButtonSettings -Button $OpNotesRemoveButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpNotesCreateReportButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesCreateReportButton.ps1"
$OpNotesCreateReportButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Create Report"
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesCreateReportButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesCreateReportButton)
Apply-CommonButtonSettings -Button $OpNotesCreateReportButton

$OpNotesRightPosition += $OpNotesRightPositionShift


$OpNotesOpenReportsButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Open Reports"
        Location = @{ X = $FormScale * $OpNotesRightPosition
                      Y = $FormScale * $OpNotesDownPosition }
        Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                      Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = { Invoke-Item -Path "$PoShHome\Reports" }
}
$Section1OpNotesTab.Controls.Add($OpNotesOpenReportsButton)
Apply-CommonButtonSettings -Button $OpNotesOpenReportsButton

$OpNotesRightPosition += $OpNotesRightPositionShift


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveDownButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\OpNotesMoveDownButton.ps1"
$OpNotesMoveDownButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = 'Move Down'
    Location = @{ X = $FormScale * $OpNotesRightPosition
                  Y = $FormScale * $OpNotesDownPosition }
    Size     = @{ Width  = $FormScale * $OpNotesButtonWidth
                  Height = $FormScale * $OpNotesButtonHeight }
    Add_Click = $OpNotesMoveDownButtonAdd_Click
}
$Section1OpNotesTab.Controls.Add($OpNotesMoveDownButton)
Apply-CommonButtonSettings -Button $OpNotesMoveDownButton

$OpNotesDownPosition += $OpNotesDownPositionShift + $($FormScale + 5)


Update-FormProgress "$Dependencies\Code\System.Windows.Forms\ListBox\OpNotesListBox.ps1"
. "$Dependencies\Code\System.Windows.Forms\ListBox\OpNotesListBox.ps1"
$OpNotesListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name     = "OpNotesListBox"
    Location = @{ X = $FormScale * $OpNotesRightPositionStart
                  Y = $FormScale * $OpNotesDownPosition + 5 }
    Size     = @{ Width  = $FormScale * $OpNotesMainTextBoxWidth
                  Height = $FormScale * $OpNotesMainTextBoxHeight }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $false
    #Add_MouseEnter = $OpNotesListBoxAdd_MouseEnter
    #Add_MouseLeave = $OpNotesListBoxAdd_MouseLeave

}
$Section1OpNotesTab.Controls.Add($OpNotesListBox)

# Obtains the OpNotes to be viewed and manipulated later
$OpNotesFileContents = Get-Content "$OpNotesFile"

# Checks to see if OpNotes.txt exists and loads it
$OpNotesFileContents = Get-Content "$OpNotesFile"
if (Test-Path -Path $OpNotesFile) {
    $OpNotesListBox.Items.Clear()
    foreach ($OpNotesEntry in $OpNotesFileContents){ $OpNotesListBox.Items.Add("$OpNotesEntry") }
}
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5Sw1NKUT749Gd520RrPb1q+E
# JyOgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUPyMluejaXuTPf/Ve+yGDHr2BC/gwDQYJKoZI
# hvcNAQEBBQAEggEAZGNn4noGpa9nCXE4ZiWXnWnrVlSltYg48BNCmVFtDyx5w0g5
# tbrYOzH9ZyKg40bppDgTDggFx3G9ghabLIa7sNbFMG7ptp7DvZhOXxaqDnMdx6SH
# Vz8QyhmeTONebMgS+lWb+lRA9Yfp+r839ZFn31K0CCzKfjF3kNOhfSS/jCS3dBTc
# jdqTT3YLwjUU/hhQWdHrUriVEJAUIKcbiWN6oICgYhbiVkG/Fx3//0VZisDcPqaQ
# +8J8d1KA7vEy1EicVtkFJBoPjZXrxN3ybLVmqmF1TrX5k/4icleizdubviJqM5KB
# PZgqtmP5w4DBRyOENtsn3CeoNzChKt9qeX56AA==
# SIG # End signature block
