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
# 53CgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUm1efUpHcCcQOugLSbk0mkUpVvFgwDQYJKoZI
# hvcNAQEBBQAEggEAcr+FjeF4WJUZPqxvcPGAfYs2pFSS2SBGWkicZJ3FmaJ/P9ic
# LxnjSh+Nab+QlkRPKgGD11JifFomzASvZBk0aLKxfQK2RmyDADPyP4vEq5jb5m0J
# DEztiJF8mflL6r3oN2ylxG0uBJE963QZLx04Lbi/XWpotaCwu1hf9LxnuLRLFysB
# suXgYqVE5VqohHCXEBOOaq7NLV1SHKlGK8l5kuH71W+jo8ftRBNnaKIXe1zQwmDV
# Lsl07SlVL9Cc9EZ7p9/ZhpjQIEgzIRjI0+iab+p3UVeUeaAt/vhethyp0e8nuqDk
# eNAvzu16LEAO4zE1Xq9p2bs0KSpknYU05R/kGw==
# SIG # End signature block
