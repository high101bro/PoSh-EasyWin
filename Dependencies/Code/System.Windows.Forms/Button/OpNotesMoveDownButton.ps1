$OpNotesMoveDownButtonAdd_Click = {
    if(($OpNotesListBox.Items).Count -ne (($OpNotesListBox.SelectedIndices)[-1] + 1) ) {
        $OpNotesListBox.BeginUpdate()
        $OpNotesToMove = @()
        $SelectedItemPositions = @()
        $SelectedItemIndices = $($OpNotesListBox.SelectedIndices)

        $BufferLine = $null
        #Checks if the lines are contiguous, if they are not it will not move the lines
        foreach ($line in $SelectedItemIndices) {
            if (($BufferLine - $line) -ne -1 -and $BufferLine -ne $null) {
                $OpNotesListBox.EndUpdate()
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Error: OpNotes")
                #Removed For Testing#$ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add('Error: You can only move contiguous lines up or down.')
                [system.media.systemsounds]::Exclamation.play()
                #[console]::beep(500,100)
                return
            }
            $BufferLine = [int]$line
        }
        #Adds lines to variable to be moved and removes each line
        while($OpNotesListBox.SelectedItems) {
            $SelectedItemPositions += $OpNotesListBox.SelectedIndex
            $OpNotesToMove         += $OpNotesListBox.SelectedItems[0]
            $OpNotesListBox.Items.Remove($OpNotesListBox.SelectedItems[0])
        }
        #Reverses Array order... [array]::reverse($OpNotesToMove) was not working
        if ($a.Length -gt 999) {$OpNotesToMove = $OpNotesToMove[-1..-10000]}
        else {$OpNotesToMove = $OpNotesToMove[-1..-1000]}

        #Adds lines to their new location
        foreach ($note in $OpNotesToMove) { $OpNotesListBox.items.insert($SelectedItemPositions[0] +1,$note)
        }
        $OpNotesListBox.EndUpdate()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Success: OpNotes Action")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Moved OpNote lines down.")
        $ResultsListBox.Items.Add('Opnotes have been saved.')
        Save-OpNotes

        #the index location of the line
        $IndexCount = $SelectedItemIndices.count
        foreach ($Index in $SelectedItemIndices) { $OpNotesListBox.SetSelected(($Index + 1),$true) }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        #[console]::beep(500,100)
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoQ3Wgd6rIVVIjI2B4kpMce09
# vyugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU6mCJAq3ceSxugzVUxTK97p81HiQwDQYJKoZI
# hvcNAQEBBQAEggEAg+fUJMwtdvhpO7jBSsKBJTQkmi9kwcoi58DVBtffTAdI9aAC
# UqFz7/7H4qZogKwyeJIcaDdv3n/qFdrcQ2zlkk0+dbuFtUgARzjM7ODuW51ZchVg
# 5fzR+1h+D77JmKnzxphNixTc5taXMQHEpH5AADovoj2PswvGw8FRHAjnOtRvWAgH
# RiFrQD3t9mMd0oOf6yTWcrWhyL/cbnYX2OlwIpgeIduood8TjhR6pj+lzV9Ebpe2
# zQ9ZMbRBElgDgx9IarlI2XjHamcAhH4spSLDH7E1LByuhl1kFhrL3CKlGhutDk77
# lggxbEUs3KHE74tizsEHg6l7Vxs8Ybtq8L/Glw==
# SIG # End signature block
