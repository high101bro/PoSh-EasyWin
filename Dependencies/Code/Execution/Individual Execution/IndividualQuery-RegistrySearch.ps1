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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUk4tN22olUrn/cJm6tE3EDQma
# ovigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUlMO4UWPbfo1RcVlM/HKqNH8L1h0wDQYJKoZI
# hvcNAQEBBQAEggEABqsnxkVxOe5zxM4j7s8hmTEoDWbO82ZBexTeyakBIOyOKRLI
# EpzIDOxRiQRXJ1f2o/pOWlCrMIq7MCOi8MywCZuhzRl0oB7PWfcCNCm73JU2Roco
# Gjt/uoFXxG4GFYLD13sJ90Sex64WojRpflf0bSpz/bCrZPYVdnNYFGNZwnqXAww5
# 3WrxO+NaQ6WUiuLPSCgfjutmrpuSgzsM3wKgOwDU6r9WTQgQ8/zS+zHvfgxXnQW3
# 6qC9pl9iVGBzJoNxrDeE3DrA6JEz4/sS8TGUO5qLNXcznp/98QO/4SCkOP4yJnK5
# q8fbXrNIO+Sx1wQBmgPDEmxOiFvLeL+UB7S3Sg==
# SIG # End signature block
