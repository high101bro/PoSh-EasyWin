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
# vyugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU6mCJAq3ceSxugzVUxTK97p81HiQwDQYJKoZI
# hvcNAQEBBQAEggEAP/v1XB4MNByyFljuJ7bS2eTgNm7x1T0aZAaHk7eO375kXCTB
# GbDYw4pkvY7LJBVUyYs9z2j/aNqbVvPTOUYQHD1P2t1nPdAyr8g1QWGViLx94fns
# dxPC3uEr0OJ6krsEV5A3FGkMgAJy1fz22jKH7ARjHeFz/v+sfU80HiAR0StcOkzx
# 1G+K+QaPyurdMggTNzjEU+ZKZ+yvMfOyrWk5hGvZjYciSAjfDC1ZtWSeWP+Y9xfv
# 8D/RJsLCe3yN6oN03jxcOMHfnaEIU3Yuqbyu67KVrYAvzMjTG0h7wX6CCEuH3xCN
# SIBKfsCgvv/vITexkzFlHsKdI+Ot/szJVMiwmQ==
# SIG # End signature block
