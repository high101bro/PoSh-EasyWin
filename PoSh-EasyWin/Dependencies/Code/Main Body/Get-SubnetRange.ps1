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
