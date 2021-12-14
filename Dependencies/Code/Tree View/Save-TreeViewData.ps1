Function Save-TreeViewData {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        [switch]$SaveAllChecked,
        [switch]$SaveScan,
        [switch]$SkipTextFieldSave,
        [string[]]$Ports,
        [string[]]$Endpoints
    )
    if ($Accounts) {
        $AccountsTreeNodeSaveData = @()
        Foreach($Account in $script:AccountsTreeViewData) {
            $AccountsTreeNodeSaveDataTemp = New-Object PSObject -Property @{ Name = $Account.Name}
            $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Enabled -Value $Account.Enabled -Force
            $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name CanonicalName   -Value $Account.CanonicalName -Force

            # If the node is selected, it will save the values you enter
            if ($Account.Name -eq $script:Section3AccountDataNameTextBox.Text -and -not $SkipTextFieldSave) {
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $Section3AccountDataLockedOutTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $Section3AccountDataSmartCardLogonRequiredTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                -Value $Section3AccountDataCreatedTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified               -Value $Section3AccountDataModifiedTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $Section3AccountDataLastLogonDateTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $Section3AccountDataLastBadPasswordAttemptTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $Section3AccountDataBadLogonCountTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $Section3AccountDataPasswordExpiredTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $Section3AccountDataPasswordNeverExpiresTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $Section3AccountDataPasswordNotRequiredTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $Section3AccountDataMemberOfComboBox.Items -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                    -Value $Section3AccountDataSIDTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $Section3AccountDataScriptPathTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $Section3AccountDataHomeDriveTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                  -Value $script:Section3AccountDataNotesRichTextBox.text -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex             -Value $Account.ImageIndex -Force

                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $Account.LockedOut -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $Account.SmartCardLogonRequired -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                -Value $Account.Created -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified               -Value $Account.Modified -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $Account.LastLogonDate -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $Account.LastBadPasswordAttempt -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $Account.BadLogonCount -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $Account.PasswordExpired -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $Account.PasswordNeverExpires -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $Account.PasswordNotRequired -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $Account.MemberOf -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                    -Value $Account.SID -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $Account.ScriptPath -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $Account.HomeDrive -Force
                # $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                  -Value $Account.Notes -Force
            }
            # Else, if the node is not selected, it will retain what was saved
            else {
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut              -Value $Account.LockedOut -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SmartCardLogonRequired -Value $Account.SmartCardLogonRequired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                -Value $Account.Created -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified               -Value $Account.Modified -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate          -Value $Account.LastLogonDate -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastBadPasswordAttempt -Value $Account.LastBadPasswordAttempt -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name BadLogonCount          -Value $Account.BadLogonCount -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordExpired        -Value $Account.PasswordExpired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNeverExpires   -Value $Account.PasswordNeverExpires -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PasswordNotRequired    -Value $Account.PasswordNotRequired -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf               -Value $(($Account | Select-Object -ExpandProperty MemberOf) -join "`n") -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                    -Value $Account.SID -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ScriptPath             -Value $Account.ScriptPath -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomeDrive              -Value $Account.HomeDrive -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                  -Value $Account.Notes -Force
                $AccountsTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex             -Value $Account.ImageIndex -Force
            }
            $AccountsTreeNodeSaveData += $AccountsTreeNodeSaveDataTemp
        }
        $script:AccountsTreeViewData  = $AccountsTreeNodeSaveData
        $AccountsTreeNodeSaveDataTemp = $null
        $AccountsTreeNodeSaveData     = $null
 
        # Saves the TreeView Data to File
        $script:AccountsTreeViewData | Export-Csv $script:AccountsTreeNodeFileSave -NoTypeInformation -Force
    }


    if ($Endpoint) {
        $ComputerTreeNodeSaveData = @()
        Foreach($Computer in $script:ComputerTreeViewData) {
            $ComputerTreeNodeSaveDataTemp = New-Object PSObject -Property @{ Name = $Computer.Name}
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystem                 -Value $Computer.OperatingSystem -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name CanonicalName                   -Value $Computer.CanonicalName -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystemHotfix           -Value $Computer.OperatingSystemHotfix -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name OperatingSystemServicePack      -Value $Computer.OperatingSystemServicePack -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Enabled                         -Value $Computer.Enabled -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LockedOut                       -Value $Computer.LockedOut -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LogonCount                      -Value $Computer.LogonCount -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Created                         -Value $Computer.Created -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Modified                        -Value $Computer.Modified -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name LastLogonDate                   -Value $Computer.LastLogonDate -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address                     -Value $Computer.IPv4Address -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress                      -Value $Computer.MACAddress -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MemberOf                        -Value $Computer.MemberOf -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name isCriticalSystemObject          -Value $Computer.isCriticalSystemObject -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name HomedirRequired                 -Value $Computer.HomedirRequired -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Location                        -Value $Computer.Location -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ProtectedFromAccidentalDeletion -Value $Computer.ProtectedFromAccidentalDeletion -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name TrustedForDelegation            -Value $Computer.TrustedForDelegation -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name SID                             -Value $Computer.SID -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan                        -Value $Computer.PortScan -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes                           -Value $Computer.Notes -Force
            $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex                      -Value $Computer.ImageIndex -Force

            if ($SaveScan){
                # If the node is selected, it will save the values you enter
                if ($Computer.Name -in $Endpoints) {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value "$($Ports -join',')" -Force
                }
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
            elseif ($SkipTextFieldSave) {
                # Just a basic save of the $Script:ComputerTreeViewData
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
            ### Those that are checked, used in the context menu
            elseif ($SaveAllChecked) {
                # If the node is selected, it will save the values you enter
                if ($Computer.Name -in $script:ComputerTreeViewSelected) {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Section3HostDataIPTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Section3HostDataMACTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value $Computer.PortScan -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Section3HostDataNotesRichTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex  -Value $Computer.ImageIndex -Force
                }
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
            ### Saves just that selected
            else {
                # If the node is selected, it will save the values you enter
                if ($Computer.Name -eq $script:Section3HostDataNameTextBox.Text) {
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name IPv4Address -Value $Section3HostDataIPTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name MACAddress  -Value $Section3HostDataMACTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name PortScan    -Value $Computer.PortScan -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name Notes       -Value $Section3HostDataNotesRichTextBox.Text -Force
                    $ComputerTreeNodeSaveDataTemp | Add-Member -MemberType NoteProperty -Name ImageIndex  -Value $Computer.ImageIndex -Force
                }
                $ComputerTreeNodeSaveData += $ComputerTreeNodeSaveDataTemp
            }
        }
        $script:ComputerTreeViewData  = $ComputerTreeNodeSaveData
        $ComputerTreeNodeSaveDataTemp = $null
        $ComputerTreeNodeSaveData     = $null

        $script:Section3HostDataNotesSaveCheck = $Section3HostDataNotesRichTextBox.Text

        # Saves the TreeView Data to File
        $script:ComputerTreeViewData | Export-Csv $script:EndpointTreeNodeFileSave -NoTypeInformation -Force
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiiqGWsam54pFNBXeCPHnOaXf
# 53CgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUm1efUpHcCcQOugLSbk0mkUpVvFgwDQYJKoZI
# hvcNAQEBBQAEggEAoWQK+H0csYaJayTSWTiGUjR0NSpFDnlm3/cp+ZSotYyyp7Ae
# 9PD0ewKgROsy864+xZxR8KBMF/ARGtezLAHiKxFbpiRTiwp4gZJdatVRrWJ+O7qi
# pLIvOGW2Zs0Iklgq2Ks2INomImiW9C7IEOrliLObE6rDwfSjs8mmARi7xPXJq1Kh
# BUao0oQboxif1WSS8L8rq5QuuStl6RUyT76rpAe1HykNPgnG6SAWy08+o+nCVlL8
# QOxwe1LlobBM+m2JpoGEw5AZuNgsQJMKlCs3A4noYOVpHhp1ERxBMUaPjjfRojHB
# ezLv26zsx6bNh/+d9Dyfv31CYLnpzT2AG0tr+g==
# SIG # End signature block
