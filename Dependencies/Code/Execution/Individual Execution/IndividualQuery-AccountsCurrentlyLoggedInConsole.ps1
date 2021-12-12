$ExecutionStartTime = Get-Date
$CollectionName = "Accounts Currently Logged In via Console"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

<# Version 1
Invoke-Command -ScriptBlock {
    Get-WmiObject -Class Win32_Process -EA "Stop" `
    | Foreach-Object {$_.GetOwner().User} `
    | Where-Object {$_ -ne "NETWORK SERVICE" -and $_ -ne "LOCAL SERVICE" -and $_ -ne "SYSTEM"} `
    | Sort-Object -Unique `
    | ForEach-Object { New-Object psobject -Property @{LoggedOn=$_} } `
    | Select-Object PSComputerName,LoggedOn
} -Session $PSSession `
| Set-Variable SessionData -Force
#>
<# Version 2
Invoke-Command -ScriptBlock {
    Get-WmiObject -Class Win32_Process -EA "Stop" `
    | Select-Object @{N='AccountName';E={$_.GetOwner().User}}, SessionID `
    | Where-Object {$_.AccountName -ne "NETWORK SERVICE" -and $_.AccountName -ne "LOCAL SERVICE" -and $_.AccountName -ne "SYSTEM" -and $_.AccountName -ne $null} `
    | Sort-Object -property AccountName -Unique `
    | ForEach-Object { New-Object pscustomobject -Property @{PSComputerName=$env:ComputerName;AccountName=$_.AccountName;SessionID=$_.SessionID} } `
    | Select-Object PSComputerName,AccountName,SessionID
} -Session $PSSession `
| Set-Variable SessionData -Force
#>


<# Version 3 #>

function MonitorJobScriptBlock {
    param(
        $ExecutionStartTime,
        $CollectionName
    )
    $CommandScriptBlock = {
        ## Find all sessions matching the specified username
        $quser = quser | Where-Object {$_ -notmatch 'SESSIONNAME'}

        $sessions = ($quser -split "`r`n").trim()

        foreach ($session in $sessions) {
            try {
                # This checks if the value is an integer, if it is then it'll TRY, if it errors then it'll CATCH
                [int]($session -split '  +')[2] | Out-Null

                [PSCustomObject]@{
                    PSComputerName = $env:COMPUTERNAME
                    UserName       = ($session -split '  +')[0].TrimStart('>')
                    SessionName    = ($session -split '  +')[1]
                    SessionID      = ($session -split '  +')[2]
                    State          = ($session -split '  +')[3]
                    IdleTime       = ($session -split '  +')[4]
                    LogonTime      = ($session -split '  +')[5]
                }
            }
            catch {
                [PSCustomObject]@{
                    PSComputerName = $env:COMPUTERNAME
                    UserName       = ($session -split '  +')[0].TrimStart('>')
                    SessionName    = ''
                    SessionID      = ($session -split '  +')[1]
                    State          = ($session -split '  +')[2]
                    IdleTime       = ($session -split '  +')[3]
                    LogonTime      = ($session -split '  +')[4]
                }
            }
        }
    }


    foreach ($TargetComputer in $script:ComputerList) {

        $InvokeCommandSplat = @{
            ScriptBlock  = $CommandScriptBlock
            ArgumentList = $null
            ComputerName = $TargetComputer
            AsJob        = $True
            JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
        }

        if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
            if (!$script:Credential) { Create-NewCredentials }
            $InvokeCommandSplat += @{Credential = $script:Credential}
        }

        Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
    }
}

Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

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

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName) -SmithFlag 'RetrieveFile' -InputValues $InputValues
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtEmP9KNZBJVuPqcSan85V7qK
# 2ESgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUAZgD3lK4KJhvnjE0aU4R3NsnwdEwDQYJKoZI
# hvcNAQEBBQAEggEAW3J71l2jFZFDdMCEautOAynqqu6yZMeu6xcdZ5v4B9sXsAY9
# ddUwauFKzFiZiew+EJzHdnky8Ysdx/WVO0eUoD0BrZu38YWqMMMuOmkUM9+SrXWW
# 2691ljMJ+wlSalIn0FYVYWwDAbTa2jNRgnzQF+ZXXh69HDzibFm9kti44cWxkgNp
# VYOZLhn9IAf8DkSOpD4ajH2Fh8gksbKrPdjAFK81FbROHvHP33dCrM+/4ljlWdd9
# tiWZazIWkruV/OiEW5KMJzSZCNjpDHTeUiHBIxZunTw5tqtHhuttLdKbmcVMOXSJ
# wskt9cS2Zmzq5l0gRmMzNGBQweJ2s5o0NZwW6w==
# SIG # End signature block
