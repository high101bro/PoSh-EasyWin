function Execute-TextToSpeach {
    if ($OptionTextToSpeachCheckBox.Checked -eq $true) {
        Add-Type -AssemblyName System.speech
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
        Start-Sleep -Seconds 1

        # TTS for Query Count
        if ($QueryCount -eq 1) {$TTSQuerySingularPlural = "query"}
        else {$TTSQuerySingularPlural = "queries"}

        # TTS for TargetComputer Count
        if ($script:ComputerList.Count -eq 1) {$TTSTargetComputerSingularPlural = "host"}
        else {$TTSTargetComputerSingularPlural = "hosts"}

        # Say Message
        if (($QueryCount -eq 0) -and ($script:ComputerList.Count -eq 0)) {$speak.Speak("You need to select at least one query and target host.")}
        else {
            if ($QueryCount -eq 0) {$speak.Speak("You need to select at least one query.")}
            if ($script:ComputerList.Count -eq 0) {$speak.Speak("You need to select at least one target host.")}
            else {$speak.Speak("PoSh-EasyWin has completed $($QueryCount) $($TTSQuerySingularPlural) against $($script:ComputerList.Count) $($TTSTargetComputerSingularPlural).")}
        }
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfbUpHBDRhbihpTRl+0N+u7gy
# GGGgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWmOSbkZ+3rnubE9McUB+IfTxZ+IwDQYJKoZI
# hvcNAQEBBQAEggEAC9tBOlb5Ag3E9lWm4o2fSdJ1lkY67HLs5KYhF9iFivvCCfpe
# ngNJVJSk+NINW1ugC+rNPL6WV/ITQfomaaoI70DFlmcgpiBBWenjZFFCcdcxMAp3
# /3qlRRBetDcfarq07eUiZkhfvy+xrZshnZwKArc2QWTsrGlB+SVwGXwqtd2Gr6X1
# V5DMSnGX9NjHk3b5cS2KVC9fxzurCvUzv68ZhmUjHPQ6EvzXCnIAFn6ROtK05SH5
# KA34Ql374iBkocVfofbKq04+AXq29KlmrMKyKzMycRNXOA06DOmJCNb4sue6QvjM
# oS0RDG8ibZvgjQd/I/Vuyl7Tm9zxmu7QWcB/lw==
# SIG # End signature block
