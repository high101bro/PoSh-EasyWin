<#
    .Synopsis
    This is an example script of what you can send to accompany an executable
    You can installed sofware, conduct tasks
    This script is not actually copied to the endpoint(s), rather is being executed by:
        Invoke-Command -FilePath 'C:\Path\Selected\To\Script.ps1' -ComputerName <FromComputerTreeview>
    Note that if you use this method to launch an interactive executable... PoSh-EasyWin will hang as you can not interact with it
#>

# Example code, you can include variables, functions, aliases... pretty much anything normally allowed
$Directory = 'c:\windows\temp'
cd $Directory

function ExampleFunction {
    param($Dir)
    systeminfo | out-file "$Dir\systeminfo.txt"
}
ExampleFunction -Dir $Directory

# Results are saved at the endpoint(s), you can use the 'Retreive Files' button to pull back files if desired
# Files copied or producted on the endpoint(s) have to be manually cleaned up or scripted
get-process | export-csv c:\windows\temp\processes.csv -notype

# You can use cmd.exe's command switch ('/c')
cmd /c netstat > .\netstat.txt

# You can use the call operator ('&')
& c:\windows\system32\notepad.exe

# The -FilePath specified needs to match that of the 'Destination Directory' field
# Keep in mind that if you transfer a whole directory, you need to account for the folder name... in this example: 'User Specified Executable And Script'
if (Test-Path 'c:\windows\temp\User Specified Executable And Script\procmon.exe') {
    # Used if a whole directory was sent over
    Start-Process -Filepath 'c:\windows\temp\User Specified Executable And Script\procmon.exe' -ArgumentList @("/AcceptEULA /BackingFile c:\windows\temp\procmon /RunTime 5 /Quiet")
}
if (Test-Path 'c:\windows\temp\procmon.exe') {
    # Used if just an executable file was sent over
    Start-Process -Filepath 'c:\windows\temp\procmon.exe' -ArgumentList @("/AcceptEULA /BackingFile c:\windows\temp\procmon /RunTime 5 /Quiet")

}





# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUSUGrxHH2rcfVQFw2qL6kZ6t
# C12gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUsnMW43usZnquKVJp1f11yQJQaPIwDQYJKoZI
# hvcNAQEBBQAEggEASVSX9WewPxpqzF5f8yxyDYJ85nQxwFBwSE3rmLtAHBzvW7Eb
# KwSPk/eEZ1UqfJMKQmcsGQs58d3RRSIL3vnTVxc+sM6mNKBLpj1u8smWc3UIALGU
# YMjgeFv5jZvW96rTpDtaOeUi0tKPqSCcw43rA7Svf88gm5ItZnX9dCkVtvJn1ZPc
# OwH8NPgkdg0GpeDYHp7YyiXAQBjKMs9czYBBGEPeNhX4yTci+cNJ8SfmpsrR/bei
# NHfNlrWfhCGQ0dWsoFqjal/GmN0vDILjpZ+ZFi9xnVjP0DZZ1ZUSqzssDpQoBd0y
# IvyKoaAzlvoVrlI3PKfUJy/9mAxN3bqocnIYVA==
# SIG # End signature block
