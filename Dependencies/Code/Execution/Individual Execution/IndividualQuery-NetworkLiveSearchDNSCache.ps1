$CollectionName = "Network Connection (Live) DNS Cache"
$ExecutionStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

if ($NetworkLiveRegexCheckbox.checked){ $NetworkLiveRegex = $True }
else { $NetworkLiveRegex = $False }

#$NetworkLiveSearchDNSCache = $NetworkLiveSearchDNSCacheRichTextbox.Lines
$NetworkLiveSearchDNSCache = ($NetworkLiveSearchDNSCacheRichTextbox.Text).split("`r`n")

function MonitorJobScriptBlock {
    param(
        $ExecutionStartTime,
        $CollectionName,
        $NetworkLiveSearchDNSCache,
        $NetworkLiveRegex
    )
    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStamp `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Write-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName

        $InvokeCommandSplat = @{
            ScriptBlock  = ${function:Get-DNSCache}
            Argumentlist = @($NetworkLiveSearchDNSCache,$NetworkLiveRegex)
            ComputerName = $TargetComputer
            AsJob        = $True
            JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
        }

        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Set-NewCredential }
            $InvokeCommandSplat += @{Credential = $script:Credential}
        }

        Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
    }
}
Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$NetworkLiveSearchDNSCache,$NetworkLiveRegex)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString = ''
foreach ($item in $NetworkLiveSearchDNSCache) {$SearchString += "$item`n" }

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
Regular Expression:
===========================================================================
$NetworkLiveRegex

===========================================================================
DNS Cache Search Terms:
===========================================================================
$($SearchString.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$NetworkLiveSearchDNSCache,$NetworkLiveRegex) -InputValues $InputValues
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvUsecXZN1lLYAlM7DS91LlKL
# QFWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUtji556qx9HhkS+iCh+CLUSkfyr8wDQYJKoZI
# hvcNAQEBBQAEggEAIOw5f7TY88Y3MzPIlXXp8qbRag+V3H3/w9pehtbkpsPtB5KI
# iE0mjmE1TPg009DetDxetPfFVrLceutDLIsPy6bFbqpbBEcfUfzNV8ojzC48aak3
# yeUpYiTgQLQmd4ZVYxelIa5WL3Nx9d8vdwNqNF/8o7nCc9xhbc2eGvI4MnsMkGC0
# 7khkRiSvniPi29zsnmzsrfa9w6y0eCaIxHERHjhWiE4RXQ5UV3Xu6ifoyqA2T5MP
# gETLlg/0GU1Yf2Th3wmwzXtrEaP2jk83T/gFTjBlqapvfc7QNsvByXnNdeYCUVDX
# Fo0Gh32y2cF6FmafXjukKR2qTCbraOAb1yfclw==
# SIG # End signature block
