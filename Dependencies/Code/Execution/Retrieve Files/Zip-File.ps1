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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdPYqhiKyh6EWL/PlU71tm2EC
# xNSgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUvKHIsdugRcAjkKHzCq14Is0hqn0wDQYJKoZI
# hvcNAQEBBQAEggEAOc+AOFrR2wQJLxBxr4hBWGnknCCdA4Ud2pkEBHQf0S6ZR4Aq
# JA0Wdy/8eOMPX8Lc84fIuK+l/mUuOH1FAzQyZWOwmP1L0mBWbNqYTx7Z/mfk02i9
# P1gibGrX6F74cD0ck8y9nB2KQrMg3TycKA+swVjGqvFDf+5caEah5h6zJG8HI2cP
# 4qaXGNpCbWxsKomhdfV95R4TANrRJFNsVjbNzJL12rCFXMiaDnMlG5qHze+dukQg
# 93DR1Pyr4HlEBGugtXfOLWM5TxJxCc8pqKZsd/AOGhmdvdYZiRdmnlqY3JrCwI4w
# qu7D0sPxCO+7uQDuydhSyxuhAfFtrBZEwkI9zA==
# SIG # End signature block
