# Ex: Get-SubnetRange -IP 192.168.1.0 -Netmask /24
# Ex: Get-SubnetRange -IP 192.168.1.128 -Netmask 255.255.255.128
Function Get-SubnetRange {
    Param(
        [string]
        $IP,
        [string]
        $netmask
    )
    Begin {
        $IPs = New-Object System.Collections.ArrayList

        # Get the network address of a given lan segment
        # Ex: Get-NetworkAddress -IP 192.168.1.36 -mask 255.255.255.0
        Function Get-NetworkAddress {
            Param (
                [string]$IP,
                [string]$Mask,
                [switch]$Binary
            )
            Begin { $NetAdd = $null }
            Process {
                $BinaryIP = ConvertTo-BinaryIP $IP
                $BinaryMask = ConvertTo-BinaryIP $Mask
                0..34 | %{
                    $IPBit = $BinaryIP.Substring($_,1)
                    $MaskBit = $BinaryMask.Substring($_,1)
                    IF ($IPBit -eq '1' -and $MaskBit -eq '1') {
                        $NetAdd = $NetAdd + "1"
                    }
                    elseif ($IPBit -eq ".") { $NetAdd = $NetAdd +'.'}
                    else { $NetAdd = $NetAdd + "0" }
                }
                if ($Binary) { return $NetAdd }
                else { return ConvertFrom-BinaryIP $NetAdd }
            }
        }

        # Convert an IP address to binary
        # Ex: ConvertTo-BinaryIP -IP 192.168.1.1
        Function ConvertTo-BinaryIP {
            Param ( [string]$IP )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = $null
                    0..7|% {
                        if (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                            $octet = $octet - [math]::pow(2,(7-$_))
                            [string]$strout = $strout + "1"
                        }
                        else { [string]$strout = $strout + "0" }
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }

        # Convert from Binary to an IP address
        # Convertfrom-BinaryIP -IP 11000000.10101000.00000001.00000001
        Function ConvertFrom-BinaryIP {
            Param ( [string]$IP )
            Process {
                $out = @()
                Foreach ($octet in $IP.split('.')) {
                    $strout = 0
                    0..7|% {
                        $bit = $octet.Substring(($_),1)
                        IF ($bit -eq 1) { $strout = $strout + [math]::pow(2,(7-$_)) }
                    }
                    $out += $strout
                }
                return [string]::join('.',$out)
            }
        }

        # Convert from a netmask to the masklength
        # Ex: ConvertTo-MaskLength -Mask 255.255.255.0
        Function ConvertTo-MaskLength {
            Param ( [string]$mask )
            Process {
                $out = 0
                Foreach ($octet in $Mask.split('.')) {
                    $strout = 0
                    0..7|% {
                        IF (($octet - [math]::pow(2,(7-$_)))-ge 0) {
                            $octet = $octet - [math]::pow(2,(7-$_))
                            $out++
                        }
                    }
                }
                return $out
            }
        }

        # Convert from masklength to a netmask
        # Ex: ConvertFrom-MaskLength -Mask /24
        # Ex: ConvertFrom-MaskLength -Mask 24
        Function ConvertFrom-MaskLength {
            Param ( [int]$mask )
            Process {
                $out = @()
                [int]$wholeOctet = ($mask - ($mask % 8))/8
                if ($wholeOctet -gt 0) { 1..$($wholeOctet) | % { $out += "255" } }
                $subnet = ($mask - ($wholeOctet * 8))
                if ($subnet -gt 0) {
                    $octet = 0
                    0..($subnet - 1) | % { $octet = $octet + [math]::pow(2,(7-$_)) }
                    $out += $octet
                }
                for ($i=$out.count;$i -lt 4; $I++) { $out += 0 }
                return [string]::join('.',$out)
            }
        }

        # Given an Ip and subnet, return every IP in that lan segment
        # Ex: Get-IPRange -IP 192.168.1.36 -Mask 255.255.255.0
        # Ex: Get-IPRange -IP 192.168.5.55 -Mask /23
        Function Get-IPRange {
            Param (
                [string]$IP,
                [string]$netmask
            )
            Process {
                iF ($netMask.length -le 3) {
                    $masklength = $netmask.replace('/','')
                    $Subnet = ConvertFrom-MaskLength $masklength
                }
                else {
                    $Subnet = $netmask
                    $masklength = ConvertTo-MaskLength -Mask $netmask
                }
                $network = Get-NetworkAddress -IP $IP -Mask $Subnet

                [int]$FirstOctet,[int]$SecondOctet,[int]$ThirdOctet,[int]$FourthOctet = $network.split('.')
                $TotalIPs = ([math]::pow(2,(32-$masklength)) -2)
                $blocks = ($TotalIPs - ($TotalIPs % 256))/256
                if ($Blocks -gt 0) {
                    1..$blocks | %{
                        0..255 |%{
                            if ($FourthOctet -eq 255) {
                                If ($ThirdOctet -eq 255) {
                                    If ($SecondOctet -eq 255) {
                                        $FirstOctet++
                                        $secondOctet = 0
                                    }
                                    else {
                                        $SecondOctet++
                                        $ThirdOctet = 0
                                    }
                                }
                                else {
                                    $FourthOctet = 0
                                    $ThirdOctet++
                                }
                            }
                            else {
                                $FourthOctet++
                            }
                            Write-Output ("{0}.{1}.{2}.{3}" -f `
                            $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
                        }
                    }
                }
                $sBlock = $TotalIPs - ($blocks * 256)
                if ($sBlock -gt 0) {
                    1..$SBlock | %{
                        if ($FourthOctet -eq 255) {
                            If ($ThirdOctet -eq 255) {
                                If ($SecondOctet -eq 255) {
                                    $FirstOctet++
                                    $secondOctet = 0
                                }
                                else {
                                    $SecondOctet++
                                    $ThirdOctet = 0
                                }
                            }
                            else {
                                $FourthOctet = 0
                                $ThirdOctet++
                            }
                        }
                        else {
                            $FourthOctet++
                        }
                        Write-Output ("{0}.{1}.{2}.{3}" -f `
                        $FirstOctet,$SecondOctet,$ThirdOctet,$FourthOctet)
                    }
                }
            }
        }
    }
    Process {
        # Get every ip in scope
        Get-IPRange $IP $netmask | ForEach-Object { [void]$IPs.Add($_) }
        $Script:IPList = $IPs
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUS96783eErHP7KEWhrI1/bBw7
# h22gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwsG4ZKB4Y2Z40waW9fO20H2l+9YwDQYJKoZI
# hvcNAQEBBQAEggEAlE/VZ/fAvRqBgxN3EWwJxp4CNYOxSa4KWIbGb8wmxVG+NqWt
# dcfOV1zUnRNfbJo9yxVO21rf/CVcVMVXYGa6qIr/GeVKSqyKMQ259xsWoO1IY1eF
# SeqSY5vEtsZJ3NVWY5Jyb/bwRpiTBlK1X0n8uJDgjLAv/kNOFQEGU+sPk4v954Hq
# 48h1yTiHxWFgEeq9uRDEY0gc6Nca59YjTsvsJkI9C01dJUl9x8sBnbQZW+Qdmy0H
# 45nllElElH76pdIpR8fYiXfa9hQBBWzi04HTVW/6/PYyEjYuNKI6ScSLp0gz19Gq
# NdJQI1MGLGlJjBIWiOyjr/Yt9SMoylaJd7uxfw==
# SIG # End signature block
