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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUp9iHJIuCssD6cdsn6UHjb9Uv
# 0lagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUKf9oHWP0VIn1lbuEGmC14WSCLcgwDQYJKoZI
# hvcNAQEBBQAEggEAeHiY0MnPJPx5PrXBp6dsbx3Rw4quMUGpw5LrQUoVcfn0KPr3
# 2zskhCZEG235Pe5852b5+SdEE4S+aj0nim2ccygl3iT/yhsnEDsP3e2/n8R/yHjh
# A6eFG1jySK8tYaSfiwAK5E0n5unCN65nGoZNLuaJ0T/BTSiq8ruB9AN+V7WllL6K
# waDVkLNd4ja6m84PpM2xritzswNgwUEANCFMJo/qiOr6vSucgBdqEvSPWWBMS+gK
# 4qq/HuLxt5v1/i61+B2Z6fAc+y0mH2CvvB0syC2C2dBd4EeI0i5uskL18xHtxIPN
# qz5Pr+xYju6B6SvFmJVGYCD2z9w9V6U/JV5zDg==
# SIG # End signature block
