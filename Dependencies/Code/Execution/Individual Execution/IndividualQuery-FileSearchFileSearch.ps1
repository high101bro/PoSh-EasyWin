$ExecutionStartTime = Get-Date
if     ($FileSearchSelectFileHashComboBox.Text -eq 'Filename') {$CollectionName = "File Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'MD5')      {$CollectionName = "MD5 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'SHA1')     {$CollectionName = "SHA1 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'SHA256')   {$CollectionName = "SHA256 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'SHA384')   {$CollectionName = "SHA384 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'SHA512')   {$CollectionName = "SHA512 Hash Search"}
elseif ($FileSearchSelectFileHashComboBox.Text -eq 'RIPEMD160'){$CollectionName = "RIPEMD160 Hash Search"}
else   {$CollectionName = "Search"}

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

$FileHashSelection   = $FileSearchSelectFileHashComboBox.Text
$DirectoriesToSearch = ($FileSearchFileSearchDirectoryRichTextbox.Text).split("`r`n")
$FilesToSearch       = ($FileSearchFileSearchFileRichTextbox.Text).split("`r`n")
$MaximumDepth        = $FileSearchFileSearchMaxDepthTextbox.text

function MonitorJobScriptBlock {
    param(
        $ExecutionStartTime,
        $CollectionName,
        $FileHashSelection,
        $DirectoriesToSearch,
        $FilesToSearch,
        $MaximumDepth
    )
    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStamp `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Write-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName

        $InvokeCommandSplat = @{
            ScriptBlock  = ${function:Conduct-FileSearch}
            ArgumentList = @($DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth,$GetFileHash,$FileHashSelection)
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

Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$FileHashSelection,$DirectoriesToSearch,$FilesToSearch,$MaximumDepth)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString1 = ''
foreach ($item in $DirectoriesToSearch) {$SearchString1 += "$item`n" }
$SearchString2 = ''
foreach ($item in $FilesToSearch) {$SearchString2 += "$item`n" }

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
Recursive Depth:
===========================================================================
$MaximumDepth

===========================================================================
Selection Type:
===========================================================================
$FileHashSelection

===========================================================================
Directories To Search:
===========================================================================
$($SearchString1.trim())

===========================================================================
Files to Search:
===========================================================================
$($SearchString2.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$FileHashSelection,$DirectoriesToSearch,$FilesToSearch,$MaximumDepth) -SmithFlag 'RetrieveFile' -InputValues $InputValues
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+U6X/y5VQOIieLkmdqHKwoSz
# gKGgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUxp1ieI5z+ucKjiJCKVaGiYKpy8gwDQYJKoZI
# hvcNAQEBBQAEggEAdupDW0XV4WM8TIJcsG2yOL9HPYVRLKPSRl76MvHzcISGdFN7
# EpoVef9RnR5pO7Ju3JwcCiLwvNq0jZZo1osRSjkIPiRlgtAWfetSmx0gRHZXUSCw
# O1mwP/UW/ynEm2C0zvkBIYrIIQElNssmAV+ZsMpjUrg5w6V7O2C0vT040en1eSVj
# UacE6p97A3CtTMVKSJBux7Qk6GUJKMxFzuZchThe2/js7LGgO5KOZn4mVFaUmHiz
# umxQRmPMsFEIKTNpse1dpUTkR3FLqyZ8Z+ZjZLuY98TiYh8A/fUwaZrX50xOqIG/
# LHg0stXsSvlfNUdal+jR8s87d8u+DYtEj7t/0A==
# SIG # End signature block
