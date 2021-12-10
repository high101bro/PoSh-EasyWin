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
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName
        
        $InvokeCommandSplat = @{
            ScriptBlock  = ${function:Conduct-FileSearch}
            ArgumentList = @($DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth,$GetFileHash,$FileHashSelection)
            ComputerName = $TargetComputer
            AsJob        = $True
            JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
        }

        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
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



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUC/0vDRAPkNX2WMSqDfJbKrg6
# DOqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUXhp8al4ejBWQ9PZPJnMUjLdKUzcwDQYJKoZI
# hvcNAQEBBQAEggEAqfeQPF8cwFMKPrJMmO2PNl+ziDJGf3dMqxyZ+WIoZFqjF7+D
# nA09t1KidhUPr+YCg1J8D36GW9t+QCr9oiyWbmhvj0HoaPUh9Er1W19145xghHDZ
# qIxIyCSU2Tq1l+ILjgC2LCmSxxUEPxUfw+DuNN4y39xnnWkGtW76fMtyDBS7jsPT
# tFZUWQgkJWQOGzXy4YMsN1BNs0Z5HNKfUlUScqnlV387XY8dHjh86qDyFGa5LBiM
# waNSbVUHlAveOoCLF+7wcQiWB6jfyGGg0wBKUbY/3GovNIRvZM+OxavuFlPo/YHS
# 0fz726UH+HMpbS8DotF+W4dT8SrczoWklxpk1A==
# SIG # End signature block
