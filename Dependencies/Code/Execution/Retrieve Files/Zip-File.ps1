# Useful resources
# https://theposhwolf.com/howtos/PowerShell-and-Zip-Files/

$ZipFile = @'
function Zip-File {
    Param (
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline)]
        [string]$Path,

        [Parameter(Mandatory=$true,Position=1)]
        [string]$Destination,

        [Parameter(Mandatory=$false,Position=2)]
        [ValidateSet("Fastest","Optimal","NoCompression")]
        [string]$Compression = "Optimal",

        [Parameter(Mandatory=$false,Position=3)]
        [switch]$TimeStamp,

        [switch]$ADS # Alternate Data Stream
    )
    function Select-CompressionLevel{
        #[Reflection.Assembly]::LoadFile('C:\WINDOWS\System32\zipfldr.dll')
        Add-Type -Assembly System.IO.Compression.FileSystem
        $CompressionToUse = $null
        switch($Compression) {
            "Fastest"       {$CompressionToUse = [System.IO.Compression.CompressionLevel]::Fastest}
            "Optimal"       {$CompressionToUse = [System.IO.Compression.CompressionLevel]::Optimal}
            "NoCompression" {$CompressionToUse = [System.IO.Compression.CompressionLevel]::NoCompression}
            #default {$CompressionToUse = [System.IO.Compression.CompressionLevel]::Fastest}
        }
        return $CompressionToUse
    }

    #Write-Verbose "Starting zip process..."

    #If the target item is a directory, the directory will be directly compressed
    if ((Get-Item $Path).PSIsContainer){
        $Destination = ($Destination + "\" + (Split-Path $Path -Leaf) + ".zip")
        if (Test-Path -Path $Destination) { Remove-Item -Path $Destination -Force -Recurse }
    }
    #If the target item is not a directory, it will copy the item to c:\Windows\Temp
    else {
        if ($ADS) {
            $FileName = [System.IO.Path]::GetFileName($Path)
            $NewFolderName = "c:\Windows\Temp\tmp-" + $FileName
        }
        else {
            $FileName = [System.IO.Path]::GetFileNameWithoutExtension($Path)
            $NewFolderName = "c:\Windows\Temp\tmp-" + $FileName
        }
        New-Item -ItemType Directory -Path $NewFolderName -Force -ErrorAction SilentlyContinue
        Copy-Item -Path $Path $NewFolderName  -Force

        $Path = $NewFolderName
        $Destination = $Destination + "\$FileName.zip"
        if (Test-Path -Path $Destination) { Remove-Item -Path $Destination -Force -Recurse }

    }
    if ($TimeStamp) {
        $TimeInfo         = New-Object System.Globalization.DateTimeFormatInfo
        $CurrentTimestamp = Get-Date -Format $TimeInfo.SortableDateTimePattern
        $CurrentTimestamp = $CurrentTimestamp.Replace(":", "-")
        $Destination      = $Destination.Replace(".zip", ("-" + $CurrentTimestamp + ".zip"))
    }

    $CompressionLevel  = Select-CompressionLevel
    $IncludeBaseFolder = $false

    #[Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" )
    Add-Type -AssemblyName "System.IO.Compression.Filesystem"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($Path, $Destination, $CompressionLevel, $IncludeBaseFolder)

    try {Remove-Item -Path $NewFolderName -Force -Recurse} catch{}

    #Write-Verbose "Zip process complete."
}
'@
Invoke-Expression $ZipFile



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU2e+JAOMD62vU5hwx05honXY3
# hfCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQURzTmjRu1JBz0KkF5waYZHTu8gUUwDQYJKoZI
# hvcNAQEBBQAEggEABs4i3NAqqW3FNbaM/3xvIpxbv8+OOgcpinmX9XbSOPwrOhZ+
# 59gVad1YFmwJGpLHzxtPqeVUSHpuzr76AXDq507wjTHfhmHZJJ3IyGTXos0ky1fs
# lqX74QJaf8yHK+4eTNmqsKK8GA2KGDL4iVEcRtEqplqcCpgqW7B0HelIIsUPcu2N
# umOPCM54OXQfryFob8EJ+qNEmPh38ip4upB9G7uN4TyWP2p4qHkM4eQCxTpJ0O8H
# IzGHKJqnGQ9XbhJ8bCgEFMqGWRJZKi7I5FCUfjeSeX4lgaPUIEHIPNFEoXYVRTen
# vSZhAT1/c0TzVS90B+6Z43olCywFrS7sbfNSPw==
# SIG # End signature block
