<#
.SYNOPSIS
Gets the hash value of a file or string

.DESCRIPTION
Gets the hash value of a file or string
It uses System.Security.Cryptography.HashAlgorithm (http://msdn.microsoft.com/en-us/library/system.security.cryptography.hashalgorithm.aspx)
and FileStream Class (http://msdn.microsoft.com/en-us/library/system.io.filestream.aspx)
Based on: http://blog.brianhartsock.com/2008/12/13/using-powershell-for-md5-checksums/ and some ideas on Microsoft Online Help

Be aware, to avoid confusions, that if you use the pipeline, the behaviour is the same as using -Text, not -File

.PARAMETER File
File to get the hash from.

.PARAMETER Text
Text string to get the hash from

.PARAMETER Algorithm
Type of hash algorithm to use. Default is SHA1

.EXAMPLE
C:\PS> Get-Hash "hello_world.txt"
Gets the SHA1 from myFile.txt file. When there's no explicit parameter, it uses -File

.EXAMPLE
Get-Hash -File "C:\temp\hello_world.txt"
Gets the SHA1 from myFile.txt file

.EXAMPLE
C:\PS> Get-Hash -Algorithm "MD5" -Text "Hello Wold!"
Gets the MD5 from a string

.EXAMPLE
C:\PS> "Hello Wold!" | Get-Hash
We can pass a string throught the pipeline

.EXAMPLE
Get-Content "c:\temp\hello_world.txt" | Get-Hash
It gets the string from Get-Content

.EXAMPLE
Get-ChildItem "C:\temp\*.txt" | %{ Write-Output "File: $($_)   has this hash: $(Get-Hash $_)" }
This is a more complex example gets the hash of all "*.tmp" files

.NOTES
DBA daily stuff (http://dbadailystuff.com) by Josep Martínez Vilà
Licensed under a Creative Commons Attribution 3.0 Unported License

.LINK
Original post: https://dbadailystuff.com/2013/03/11/get-hash-a-powershell-hash-function/
#>

function Get-Hash {
    Param
    (
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="set1")]
        [String]
        $text,
        [parameter(Position=0, Mandatory=$true, 
        ValueFromPipeline=$false, ParameterSetName="set2")]
        [String]
        $file = "",
        [parameter(Mandatory=$false, ValueFromPipeline=$false)]
        [ValidateSet("MD5", "SHA", "SHA1", "SHA-256", "SHA-384", "SHA-512")]
        [String]
        $algorithm = "SHA1"
    )
    Begin
    {
        $hashAlgorithm = [System.Security.Cryptography.HashAlgorithm]::Create($algorithm)
    }
    Process
    {
        $md5StringBuilder = New-Object System.Text.StringBuilder 50
        $ue = New-Object System.Text.UTF8Encoding

        if ($file){
            try {
                if (!(Test-Path -literalpath $file)){
                    throw "Test-Path returned false."
                }
            }
            catch {
                throw "Get-Hash - File not found or without permisions: [$file]. $_"
            }
            try {
                [System.IO.FileStream]$fileStream = [System.IO.File]::Open($file, [System.IO.FileMode]::Open);
                $hashAlgorithm.ComputeHash($fileStream) | 
                    % { [void] $md5StringBuilder.Append($_.ToString("x2")) }
            }
            catch {
                throw "Get-Hash - Error reading or hashing the file: [$file]"
            }
            finally {
                $fileStream.Close()
                $fileStream.Dispose()
            }
        }
        else {
            $hashAlgorithm.ComputeHash($ue.GetBytes($text)) | 
                % { [void] $md5StringBuilder.Append($_.ToString("x2")) }
        }

        return $md5StringBuilder.ToString()
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3S5efT1Q7Q0yamRoswZXN7eJ
# Z82gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDomq+8xbnyjbWelnPUJdgKsvi3gwDQYJKoZI
# hvcNAQEBBQAEggEANFz72WKkfPzEFjgGrZi6LQVN/DPhP38MJ58N0R5jsANUryMY
# ScwCf+Fq7j30cgNWYdTfV9VOZPbU39qyDHIRF+Y0xOnfEGdlKZ6p4RzhxM6rywsW
# LfxApLN6vVZfB+SVmmU3sGsDnaF3EPalCc+PDLR6XPJdyu11vOiMsaUak1wb1U7U
# yJxMwde5D16kbrZxcAURFyKilFTdTl7/6hJWfFQzkF6YupwWVR5tFX30Id/mOKhG
# /f2l7a/qQ11cMQH8yIJ53snBTBBMFoMEfNAO82giFPVIxtXkaomXn2XlqeAqZUaX
# uVXPDzwtUWjZdF2628TilPTEJNNDQp8w35ZVLw==
# SIG # End signature block
