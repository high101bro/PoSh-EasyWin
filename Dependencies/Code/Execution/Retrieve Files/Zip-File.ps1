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
# hfCgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQURzTmjRu1JBz0KkF5waYZHTu8gUUwDQYJKoZI
# hvcNAQEBBQAEggEAqC+6U2dhkCPJe2uZa44i6cC5CRA1ke1ZuolXcfkfcmHWVrTb
# GV2DcpfAvjvo/Umy0E3CzcldTECSG2cW+AAFls2i2J0wL3qSMUj2WEmP6fpNQoHC
# KMBw+a4L/uCOrqejoTwPnR2bj8mA/hmz/AwgmdRS7Bhel4/tn5IqMIiX6QXL2myS
# Brw4NsJWskuhC3a3Vpx2ae95IFkPRzdd2qw6kpDlfuMfvD+BvwCvk8TZzdiBDJoO
# Ka9TjHl2yzHuFP+7g9SymbER6HYXYDYMp+oGzQfS7MOTy12VQgQxjtwgB5pdQ6nV
# eDjn97dVEE6ch8vEh7zOxvs7YEwata/G/kKaWQ==
# SIG # End signature block
