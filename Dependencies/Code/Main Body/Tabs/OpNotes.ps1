
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdZsL0apaWIg1vyFxlXUYq2/A
# ZKWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU5kxrATtUTMxP4X1X7PD2+45rjWwwDQYJKoZI
# hvcNAQEBBQAEggEAvCC7Ai7CVdY0Gs7xu6NYljM4XbkHroQ3J5cZ1ZB0G/XoCy/y
# 2sD7j/ofYOjOINozUK9lsNEpn1XzoQcl5VvwIFUpNfy3cN99svz9M+XPE0W1JrpI
# tadsHpemXxyNhwwC/Kmh6/Q/n/u9YRQr5gbt8OMQRBvja08AtK55Zwr/tp4eX+7q
# vJSPXqkgcTDProBs1d+sKgxyAqvMQeooXdCHdC1WjpSLROBvnUnu9seDpZgQTly8
# b2zLEHIB6Iu3KnvDqyzAQameykaec8EJ0Y1AuB07FPGy22G8KBnkcq7QHpeNE9WZ
# /e7O6+7D3qzegcregZ75AVfjYR1/MGdDzMj1wg==
# SIG # End signature block
