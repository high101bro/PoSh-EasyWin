function script:Open-XmlResultsInShell {
    param(
        $ViewImportResults,
        $FileName,
        $SavePath
    )
    #Start-Process  'PowerShell' -ArgumentList '-NoExit',{$Results = Import-Clixml 'C:\Firewall Status - (WinRM) PoSh - Win81-07.xml';Write-Host -f White "$('='*100)";Write-Host -f Yellow '  The results available as XML data within the variable: ' -NoNewline;Write-Host -f Red '$Results ';Write-Host '';Write-Host -f Yellow '  You can manipulate the ' -NoNewline;Write-Host -f Red '$Results ' -NoNewline;Write-Host -f Yellow 'data via command line, a few examples are:';Write-Host -f White "`t" '$Results';Write-Host -f White "`t" '$Results | Out-GridView';Write-Host -f White "`t" '$Results | Select-Object -Property Name';Write-Host -f White "`t" '$Results | Get-Member';Write-Host -f White "$('='*100)";Write-Host""},{$(Set-Location c:\ -ErrorAction SilentlyContinue)}
    New-Item -Type Directory 'c:\Windows\Temp\PoSh-EasyWin' -Force -ErrorAction SilentlyContinue

    $Command = @"
    Start-Process 'PowerShell' -ArgumentList '-NoExit',
    '-ExecutionPolicy Bypass',
        { `$ErrorActionPreference = 'SilentlyContinue'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow 'Generate Property Statistics? For larger files this may take some time: ' -NoNewLine;},
        { `$script:YesNo = `$null; function Read-KeyOrTimeout {Param([int]`$seconds=5,[string]`$prompt='[Y/n]',[string]`$default = 'Y'); `$startTime=Get-Date; `$timeOut = New-TimeSpan -Seconds `$seconds; Write-Host `$prompt; while (-not `$host.ui.RawUI.KeyAvailable) {`$currentTime = Get-Date; if (`$currentTime -gt `$startTime + `$timeOut) {Break}}; if (`$host.ui.RawUI.KeyAvailable) {[string]`$response = (`$host.ui.RawUI.ReadKey('IncludeKeyDown,NoEcho')).character} else {`$response = `$default};`$script:YesNo = `$response;}; Read-KeyOrTimeOut; },

        { switch (`$YesNo) {Y {`$Answer=`$true}; n {`$Answer=`$false}; Default {`$Answer=`$true}};},
        { `$Message = 'Importing selcted file...'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow "`$Message" -NoNewLine; },

        { `$Results = Import-CliXml '$ViewImportResults'; },
        { foreach (`$i in (0..(40-(`$Message.length)))) {Write-Host ' '-NoNewLine}; },
        { Write-Host -f Green '  [Complete]'; },
        { Write-Host ' '; },

        { `$Message = 'Generating Variables and Functions...'; },
        { Write-Host -f Yellow "`$Message" -NoNewLine; },
        { `$script:ComputerList        = `$Results | Select-Object PSComputerName -Unique; },
        { `$ComputerCount       = @(`$Results | Select-Object PSComputerName -Unique).count; },
        { `$TotalObjectCount    = @(`$Results).count; },
        { `$PropertyList          = (`$Results[0] | Get-Member | Where-Object MemberType -Match Property).Name; },
        { foreach (`$i in (0..(40-(`$Message.length)))) {Write-Host ' '-NoNewLine}; },
        { Write-Host -f Green '  [Complete]'; },
        { Write-Host ' '; },

        { if (`$Answer -eq `$true) {`$Message = 'Processing Select Results...'}; },
        { if (`$Answer -eq `$true) {Write-Host -f Yellow "`$Message"}; },
        { if (`$Answer -eq `$true) {`$PropertyUniqueCount = @()} else {`$PropertyUniqueCount = 'These statistics were not generated...'}; },
        { if (`$Answer -eq `$true) {foreach (`$p in `$PropertyList) { Write-Host "``t`$p" -NoNewLine; foreach (`$i in (0..(33-(`$p.length)))) {Write-Host ' '-NoNewLine} ;`$PropertyUniqueCount += [pscustomobject]@{Name = "`$p";Value = (`$Results.`$p | Select -unique).count}; Write-host -f Green '[Complete]'  }} ; },
        { Write-Host ' '; },

        { function View-Results {`$Results | Out-GridView -Title 'PoSh-EasyWin - View Results'}; },
        { function Open-ResultsDirectory {`Invoke-Item `$SavePath}; },

        { New-PSDrive -Name 'PoSh-EasyWin' -PSProvider FileSystem -Root 'C:\Windows\Temp' -ErrorAction SilentlyContinue | Out-Null; Set-Location PoSh-EasyWin:\; },
        { `$host.UI.RawUI.WindowTitle = 'PoSh-EasyWin: Raw Data Manipulation in Terminal'; },

        { Clear-Host; },

        { Write-Host -f White        "$('='*100)"; },
        { Write-Host ' '; },

        { Write-Host -f Yellow       '  The selected results are available as object data within the variable: ' -NoNewline; },
        { Write-Host -f Red          '`$Results'; },
        { Write-Host -f White "``t"   '\`"$FileName\`"'; },
        { Write-Host ' '; },

        { `$SavePath = '$SavePath'; },
        { Write-Host -f Yellow       '  Data can be saved to the same location selected using the variable: ' -NoNewline; },
        { Write-Host -f Cyan         '`$SavePath'; },
        { Write-Host -f White "``t"   '\`"$SavePath\`"'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow       '  You can manipulate the ' -NoNewline; },
        { Write-Host -f Red          '`$Results ' -NoNewline; },
        { Write-Host -f Yellow 'data via command line, a few examples are:'; },

        { Write-Host -f Red    "``t" '`$Results'; },

        { Write-Host -f Red    "``t" '`$Results ' -NoNewLine; },
        { Write-Host -f White        '| Get-Member'; },

        { Write-Host -f Red    "``t" '`$Results ' -NoNewLine; },
        { Write-Host -f White        '| Select-Object -Property PSComputerName -Unique'; },

        { Write-Host -f Red    "``t" '`$Results ' -NoNewLine; },
        { Write-Host -f White        '| Out-GridView -PassThru | Export-Csv \`"' -NoNewLine; },
        { Write-Host -f Cyan         '`$SavePath' -NoNewLine; },
        { Write-Host -f White        '`\Shell Output.csv\`" -NoTypeInfo'; },

        { Write-Host -f Red    "``t" '`$Results ' -NoNewLine; },
        { Write-Host -f White        '| ? {`$_.name -match \`"win\`"} | Select PSComputerName, Name | Sort Name | ft -auto'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow       '  Below are some useful variables generated from the results imported:'; },
        { Write-Host -f Green  "``t" '`$script:ComputerList'"``t``t"'`$PropertyList'"``t``t"'`$TotalObjectCount'; },
        { Write-Host -f Green  "``t" '`$ComputerCount'"``t"'`$PropertyUniqueCount'; },
        { Write-Host ' '; },

        { Write-Host -f Yellow       '  The functions have been created for use:'; },
        { Write-Host -f Magenta "``t" '`View-Results'"``t``t"'Open-ResultsDirectory'; },
        { Write-Host ' '; },

        { Write-Host -f White        "$('='*100)"; },
        { Write-Host""; },

        { `$ErrorActionPreference = 'Continue'; }
"@
    Invoke-Expression $Command

    #Start-Sleep 1
    #Remove-Item C:\Windows\Temp\PoSh-EasyWin -Force -ErrorAction SilentlyContinue

}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlzhXRFSogfd+YAIFYilhq6Cw
# X5egggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUGxL06n5uLprXmICePnaSt7P6GLEwDQYJKoZI
# hvcNAQEBBQAEggEAQcULZ/bcAbzCd9/0rGewfWAvpdVw6E6m6qQTdGHiTsfIMPG9
# tpB73wbUMI7Nbs541EcQ5u4KVmMFm8FGdgm5We36nFwnhYPUd8ngiQSqoyPZRN4w
# vkn5iyMBMgMMs5y3OY+NVVKf+Fo4gZJ2th8TbNyZ2E1QxFVVX8mexO5O227HaW90
# yRCiB9C80qzz2ttLAeRhF4yCjifNtdMu0/qVF3W80W73PY9Rnu0J3Pe9rwJ726S8
# 7fbp3JDWqp+8YHcvd+C0aLCWbUfz0dicz/ZhKgG7JS/UP2k93Yku00u4qvgdxiUv
# Wi5jA2Pr7l7OrIsRwSF8Ty0nffnvXBssZ18L5w==
# SIG # End signature block
