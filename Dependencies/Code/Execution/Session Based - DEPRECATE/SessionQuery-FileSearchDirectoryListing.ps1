$ExecutionStartTime = Get-Date
$CollectionName = "Directory Listing Query"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Directory Listing"
$DirectoryPath  = $FileSearchDirectoryListingTextbox.Text
$MaximumDepth   = $FileSearchDirectoryListingMaxDepthTextbox.text

Invoke-Command -ScriptBlock {
    param($DirectoryPath,$MaximumDepth,$GetChildItemDepth)
    function Get-DirectoryListing {
        param($DirectoryPath,$MaximumDepth)
        if ([int]$MaximumDepth -gt 0) {
            Invoke-Expression $GetChildItemDepth

            # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
            #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth

            Get-ChildItemDepth -Path $DirectoryPath -Depth $MaximumDepth -Force -ErrorAction SilentlyContinue
        }
        else {
            Get-ChildItem -Path $DirectoryPath -Force -ErrorAction SilentlyContinue
        }
    }
    Get-DirectoryListing -DirectoryPath $DirectoryPath -MaximumDepth $MaximumDepth

} -ArgumentList $DirectoryPath,$MaximumDepth,$GetChildItemDepth -Session $PSSession | Select-Object PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer `
| Set-Variable SessionData
$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
Remove-Variable -Name SessionData -Force

$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value   += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlGNY+uGKjAS+HAQ9+IaTyXf0
# On+gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/YAv9UbbvdOPU6eTekL+tIp/eyAwDQYJKoZI
# hvcNAQEBBQAEggEAlyML9UDQyvx99efp+yd71G63F61fXdvk0LXWUOkPi18r6esl
# C1pZ7mDgGQjMn2IPjXv8JqLkvZ1SRazOTrHGcVpgehyTgI+qDC+TbXp4b2CJRqG+
# ejf1diiwtPJKgzOjKe4Z/Z24vECsC+oQUX+LgWWCdM132qfaNPGIQi89hwJLaCbR
# HtOh/Up3dBTzwv4HU7TAtYRMfLIIRzHawE73um5hkDlILMQNnicc+lZO6syYfgq/
# 7DzqlWAo2gH+uJiF+fMXcUbqtquQALYsekQQ+lZvnpw41gunadZjEX1hs55CQOlf
# 5Lo+vohkgE2E5nUsfcMNdCilVNu2ngQ+JBGWiA==
# SIG # End signature block
