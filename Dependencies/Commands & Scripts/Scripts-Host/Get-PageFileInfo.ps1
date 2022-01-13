
<# 
    .Synopsis 
    Returns info about the page file size of a Windows computer. Defaults to local machine. 

    .Description 
    Returns the pagefile size info in MB. Also returns the PageFilePath, PageFileTotalSize, PagefileCurrentUsage,
    and PageFilePeakusage. Also returns if computer is using a TempPafeFile and if the machine's pagefile is
    managed by O/S (AutoManaged = true) or statically set (AutoManaged = False)

    .Notes 
    NAME: Get-PageFileInfo 
    ORIGINAL AUTHOR: Mike Kanakos 
    MODIFIED BY: high101bro for compatibility with PoSh-EasyWin    
#> 

$PageFileResults = Get-CimInstance -Class Win32_PageFileUsage | Select-Object *
$CompSysResults = Get-CimInstance win32_computersystem -Namespace 'root\cimv2'

$PageFileStats = [PSCustomObject]@{
    FilePath              = $PageFileResults.Description
    AutoManagedPageFile   = $CompSysResults.AutomaticManagedPagefile
    "TotalSize(in MB)"    = $PageFileResults.AllocatedBaseSize
    "CurrentUsage(in MB)" = $PageFileResults.CurrentUsage
    "PeakUsage(in MB)"    = $PageFileResults.PeakUsage
    TempPageFileInUse     = $PageFileResults.TempPageFile
}
$PageFileStats 
















# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyCYkqWLa1WFHecdn2V+AjPvI
# SpSgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUNJV8U9WpRYjL0ENadEmeoYV2x6IwDQYJKoZI
# hvcNAQEBBQAEggEAn5shPY5DL1/6bIwKCIhaXXmfA4tkdjf+PksgiJqGGsAtBj0Z
# AlRs9HYvDSrFjfGnvilMEWnvrCLXdMuFP8nDB7Nb6EEiaYiEK8c2UZ9sAwJxEIXe
# NSywF5ZCVJYKukNr+2GX2Tp48VFW5S169TUybH0RdIdLGx8TUMRF5iogOCkYLF1N
# d8ECIaNbjT3rGxnz0WHnIn5zYH8oiqQh/riyZCuwboXrWhhcwmsSuHC8ai87qGNO
# Qyr+mq/LnDpT4/MZ2Kb+WX82C+68zzc0GvDTasLAdc3fD6hud4G7JVcgSQRNNR7T
# UvCJDoSmmdez/UlnzwdgF6L7FS64Jrjt++QgHw==
# SIG # End signature block
