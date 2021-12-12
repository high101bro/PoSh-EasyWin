if ($RegistryKeyItemPropertyNameCheckbox.checked) { $CollectionName = "Registry Search - Item Property"  }
elseif ($RegistryKeyNameCheckbox.checked)   { $CollectionName = "Registry Search - Key Name" }
elseif ($RegistryValueNameCheckbox.checked) { $CollectionName = "Registry Search - Value Name" }
elseif ($RegistryValueDataCheckbox.checked) { $CollectionName = "Registry Search - Value Data" }

$ExecutionStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


$RegistrySearchDirectory = ($script:RegistrySearchDirectoryRichTextbox.Text).split("`r`n")
$SearchRegistryKeyItemPropertyName = ($script:RegistryKeyItemPropertyNameSearchRichTextbox.Text).split("`r`n")
$SearchRegistryKeyName   = ($script:RegistryKeyNameSearchRichTextbox.Text).split("`r`n")
$SearchRegistryValueName = ($script:RegistryValueNameSearchRichTextbox.Text).split("`r`n")
$SearchRegistryValueData = ($script:RegistryValueDataSearchRichTextbox.Text).split("`r`n")

if ($RegistryKeyItemPropertyNameCheckbox.checked)   {
    $CountCommandQueries++
    # if ($RegistrySearchRecursiveCheckbox.checked) {
    #     $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryKeyName,$true,$false,$false)
    # }
    # else {
    #     $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryKeyName,$true,$false,$false)
    # }
}
if ($RegistryKeyNameCheckbox.checked) {
    $CountCommandQueries++
    if ($RegistrySearchRecursiveCheckbox.checked) {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryKeyName,$true,$false,$false)
    }
    else {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryKeyName,$true,$false,$false)
    }
}
if ($RegistryValueNameCheckbox.checked) {
    $CountCommandQueries++
    if ($RegistrySearchRecursiveCheckbox.checked) {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryValueName,$false,$true,$false)
    }
    else {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryValueName,$false,$true,$false)
    }
}
if ($RegistryValueDataCheckbox.checked) {
    $CountCommandQueries++
    if ($RegistrySearchRecursiveCheckbox.checked) {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryValueData,$false,$false,$true)
    }
    else {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryValueData,$false,$false,$true)
    }
}

function MonitorJobScriptBlock {
    param(
        $ExecutionStartTime,
        $CollectionName,
        $RegistrySearchDirectory,
        $SearchRegistryKeyName,
        $SearchRegistryValueName,
        $SearchRegistryValueData,
        $SearchRegistryCommand,
        $SearchRgistryItemProperty,
        $RegistryKeyItemPropertyNameCheckbox,
        $SearchRegistryKeyItemPropertyName
    )

    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -LogFile $LogFile -Message $CollectionName

        if ($RegistryKeyItemPropertyNameCheckbox.checked) {           
            $InvokeCommandSplat = @{
                ScriptBlock  = {
                    param($RegistrySearchDirectory,$SearchRegistryKeyItemPropertyName)
                    foreach ($Path in $RegistrySearchDirectory){
                        foreach ($Item in $SearchRegistryKeyItemPropertyName) {
                           Get-ItemProperty -Path $Path $Item
                        }
                    }
                }
                ArgumentList = @($RegistrySearchDirectory,$SearchRegistryKeyItemPropertyName)
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $InvokeCommandSplat += @{Credential = $script:Credential}
            }
            
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
        else {
            $InvokeCommandSplat = @{
                ScriptBlock  = $script:QueryRegistryFunction
                ArgumentList = $SearchRegistryCommand
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                $InvokeCommandSplat += @{Credential = $script:Credential}
            }
            
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
    }
}
Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$RegistrySearchDirectory,$SearchRegistryKeyName,$SearchRegistryValueName,$SearchRegistryValueData,$SearchRegistryCommand,$SearchRgistryItemProperty,$RegistryKeyItemPropertyNameCheckbox,$SearchRegistryKeyItemPropertyName)


$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString1 = ''
foreach ($item in $RegistrySearchDirectory) {$SearchString1 += "$item`n"}
$SearchString2 = ''
foreach ($item in $SearchRegistryKeyName) {$SearchString2 += "$item`n"}
$SearchString3 = ''
foreach ($item in $SearchRegistryValueName) {$SearchString3 += "$item`n"}
$SearchString4 = ''
foreach ($item in $SearchRegistryValueData) {$SearchString4 += "$item`n"}
$SearchString5 = ''
foreach ($item in $SearchRegistryKeyItemPropertyName) {$SearchString5 += "$item`n"}

$InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Registry Paths To Search Within:
===========================================================================
$($SearchString1.trim())

===========================================================================
Item Property Name Search Terms:
===========================================================================
$($SearchString5.trim())

===========================================================================
Key Name Search Terms:
===========================================================================
$($SearchString2.trim())

===========================================================================
Value String Search Terms:
===========================================================================
$($SearchString3.trim())

===========================================================================
Value Data Search Terms:
===========================================================================
$($SearchString4.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$RegistrySearchDirectory,$SearchRegistryKeyName,$SearchRegistryValueName,$SearchRegistryValueData,$SearchRegistryCommand,$SearchRgistryItemProperty,$RegistryKeyItemPropertyNameCheckbox,$SearchRegistryKeyItemPropertyName) -InputValues $InputValues
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

Update-EndpointNotes

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJ2xzGDtEmeuqVpwmur2qmgfT
# GkOgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/Qz/ITwZJr8oRKqv49fb2M9f7yUwDQYJKoZI
# hvcNAQEBBQAEggEADnk94fecJ6yi+PgTxFC2jTnFlXvW66OlwAOmnMmJ8o/QuSHa
# UoJiu1Xf+uIAixgTVqZgPppq7GjSm1LD3VixgAH/l/bSuGpSQ9RTBe4BrfaW3A6g
# bzhCV/VR8I5ieIFJxuco6U1414DYbpZyLTggdOrI8Y5nzzhpnrpHOKtZZT5qBE29
# pl23s+NvTOWmWzFudvq4ZkuphnWwHcmhhGyzP+WK37q/mbNU7kyCiQDrWXXI9Njx
# SNEj8NIdvgTThdwAn49Gmfz0IFs3SaPOlHhW0XR0n7BDrev5RzRyESELeotCAzi4
# nXB0XVEZMNJsSoGoD7R4bGZMQ4nrbwl6I/A3Yg==
# SIG # End signature block
