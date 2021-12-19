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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUm0xTOGPqX7SxZaSJyjMyqPfV
# GnOgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUelG83gAJNVZzdRD+cPuIL7yFN1kwDQYJKoZI
# hvcNAQEBBQAEggEAreLK/eBalXylLkB1HcRpRg3CxYbk+zs46nfQbBXSc36/BlrZ
# KFpKJvtBMFt4BfqHftvkqBSh8qlfy69RiOwBGnmkHv5CNdwfgPdAZ7xwBwqCJJUK
# ZL+YcjFFY240MQVHT8LeaO9Tu3qB9985Q+ca2OT4k/T/diiS7rMpUAz0YyI8o7CR
# Pa5+S4TZ75RZshEJrk9HXWcbNg20nannkGMIOolPx+aGZUd5LICTSB1Bd0dWFvqM
# Ehd+tYJjzkGn46wtjHTuCo+mCqXMbtpbpeqvje+SiolQiszKLEvsuUEnqgvOM1Fc
# w37U74JiAzTDRxDVletlwnpEY5sY1ikoYIF7YQ==
# SIG # End signature block
