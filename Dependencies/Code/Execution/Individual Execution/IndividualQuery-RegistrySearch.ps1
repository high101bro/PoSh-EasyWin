$script:QueryRegistryFunction = {
    function Search-Registry {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
            [Alias("PsPath")]
            # Registry path to search
            $Path,
            # Specifies whether or not all subkeys should also be searched
            [switch] $Recurse,
            [Parameter(ParameterSetName="SingleSearchString", Mandatory)]
            # A regular expression that will be checked against key names, value names, and value data (depending on the specified switches)
            $SearchRegex,
            [Parameter(ParameterSetName="SingleSearchString")]
            # When the -SearchRegex parameter is used, this switch means that key names will be tested (if none of the three switches are used, keys will be tested)
            [switch] $KeyName,
            [Parameter(ParameterSetName="SingleSearchString")]
            # When the -SearchRegex parameter is used, this switch means that the value names will be tested (if none of the three switches are used, value names will be tested)
            [switch] $ValueName,
            [Parameter(ParameterSetName="SingleSearchString")]
            # When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value data will be tested)
            [switch] $ValueData
        )

        begin {
            switch ($PSCmdlet.ParameterSetName) {
                SingleSearchString {
                    $NoSwitchesSpecified = -not ($PSBoundParameters.ContainsKey("KeyName") -or $PSBoundParameters.ContainsKey("ValueName") -or $PSBoundParameters.ContainsKey("ValueData"))
                    if ($KeyName   -or $NoSwitchesSpecified) { $KeyNameRegex   = $SearchRegex }
                    if ($ValueName -or $NoSwitchesSpecified) { $ValueNameRegex = $SearchRegex }
                    if ($ValueData -or $NoSwitchesSpecified) { $ValueDataRegex = $SearchRegex }
                }
                MultipleSearchStrings {
                    # No extra work needed
                }
            }
        }

        process {
            $SearchRegexFound = @()
            foreach ($CurrentPath in $Path) {
                Get-ChildItem $CurrentPath -Recurse:$Recurse |
                ForEach-Object {
                    $Key = $_
                    if ($KeyNameRegex) {
                        foreach ($Regex in $KeyNameRegex) {
                            if ($Key.PSChildName -match $Regex) {
                                $SearchRegexFound += [PSCustomObject] @{
                                    SearchTerm = $Regex
                                    Key        = $Key
                                    KeyName    = $Key.PSChildName
                                    Reason     = "KeyName"
                                    ItemProperty = $(Get-ItemProperty $CurrentPath | Out-String)
                                }
                            }
                        }
                    }

                    if ($ValueNameRegex) {
                        foreach ($Regex in $ValueNameRegex) {
                            if ($Key.GetValueNames() -match $Regex) {
                                $SearchRegexFound += [PSCustomObject] @{
                                    SearchTerm = $Regex
                                    Key        = $Key
                                    ValueName  = $Key.GetValueNames()
                                    Reason     = "ValueName"
                                }
                            }
                        }
                    }

                    if ($ValueDataRegex) {
                        foreach ($Regex in $ValueDataRegex) {
                            $ValueDataKey = ($Key.GetValueNames() | % { $Key.GetValue($_) })
                            if ($ValueDataKey -match $Regex) {
                                $SearchRegexFound += [PSCustomObject] @{
                                    SearchTerm = $Regex
                                    Key        = $Key
                                    ValueData  = $ValueDataKey
                                    Reason     = "ValueData"
                                }
                            }
                        }
                    }
                }
            }
            Return $SearchRegexFound
        }
    }

    Search-Registry -Path $args[0] -Recurse:$args[1] -SearchRegex $args[2] -KeyName:$args[3] -ValueName:$args[4] -ValueData:$args[5] -ErrorAction SilentlyContinue
}


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
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStamp `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Write-LogEntry -TargetComputer $TargetComputer -LogFile $PewLogFile -Message $CollectionName

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
                if (!$script:Credential) { Set-NewCredential }
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
                if (!$script:Credential) { Set-NewCredential }
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJMPT9klf4i8EEZIfXXS/qgNE
# UOmgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU2a3HNqs+IJyrq4iDR88OEYMYG7EwDQYJKoZI
# hvcNAQEBBQAEggEAa4VkQ1QdByfGOHwMJk4rod2BYF1UXY1OFkZPurB7+zMSB0DS
# FlpdgYbud/ZndJ+AAB6FDncgYGsfd2xSWwxzOI++2aV4ugKWQknq/NHZNDCpxZRy
# wYXFy132uwx+XAPyux3aFZbgMVeoa1mrAD7SqgSAzEB1yRQBEbYQR89o0aEVnMue
# EhoKP/Ic93arsrAv26a8lPQXBtkHuMJc03V6l6MlpAC+91bQ5NhloSV3olYPN+Tj
# Q2GWh0vpDIn8WRif3Oz8l9DyxcxZnQFZ6yoSP5PLzXu3NnZe6UnRO2Fi9siUvXVS
# MhoXb1FoMQVyX/0LrWWLSTQ9nng+xp73nf8kHw==
# SIG # End signature block
