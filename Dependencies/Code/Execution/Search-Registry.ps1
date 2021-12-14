# This function is created within a string variable as it is used with an an agrument for Invoke-Command
# It is initialized below with an Invoke-Expression
$SearchRegistryFunctionString = @'
    function Search-Registry {
        [CmdletBinding()]
        param(
            [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)]
            [Alias("PsPath")]
            # Registry path to search
            [string[]] $Path,
            # Specifies whether or not all subkeys should also be searched
            [switch] $Recurse,
            [Parameter(ParameterSetName="SingleSearchString", Mandatory)]
            # A regular expression that will be checked against key names, value names, and value data (depending on the specified switches)
            [string[]] $SearchRegex,
            [Parameter(ParameterSetName="SingleSearchString")]
            # When the -SearchRegex parameter is used, this switch means that key names will be tested (if none of the three switches are used, keys will be tested)
            [switch] $KeyName,
            [Parameter(ParameterSetName="SingleSearchString")]
            # When the -SearchRegex parameter is used, this switch means that the value names will be tested (if none of the three switches are used, value names will be tested)
            [switch] $ValueName,
            [Parameter(ParameterSetName="SingleSearchString")]
            # When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value data will be tested)
            [switch] $ValueData,
            [Parameter(ParameterSetName="MultipleSearchStrings")]
            # Specifies a regex that will be checked against key names only
            [string[]] $KeyNameRegex,
            [Parameter(ParameterSetName="MultipleSearchStrings")]
            # Specifies a regex that will be checked against value names only
            [string[]] $ValueNameRegex,
            [Parameter(ParameterSetName="MultipleSearchStrings")]
            # Specifies a regex that will be checked against value data only
            [string[]] $ValueDataRegex
        )

        begin {
            switch ($PSCmdlet.ParameterSetName) {
                SingleSearchString {
                    $NoSwitchesSpecified = -not ($PSBoundParameters.ContainsKey("KeyName") -or $PSBoundParameters.ContainsKey("ValueName") -or $PSBoundParameters.ContainsKey("ValueData"))
                    if ($KeyName   -or $NoSwitchesSpecified) { $KeyNameRegex   = $SearchRegex }
                    if ($ValueName -or $NoSwitchesSpecified) { $ValueNameRegex = $SearchRegex }
                    if ($ValueData -or $NoSwitchesSpecified) { $ValueDataRegex = $SearchRegex }
                }
                MultipleSearchStrings {
                    # No extra work needed
                }
            }
        }

        process {
            $SearchRegexFound = @()
            foreach ($CurrentPath in $Path) {
                Get-ChildItem $CurrentPath -Recurse:$Recurse |
                ForEach-Object {
                    $Key = $_
                    if ($KeyNameRegex) {
                        foreach ($Regex in $KeyNameRegex) {
                            if ($Key.PSChildName -match $Regex) {
                                $SearchRegexFound += [PSCustomObject] @{
                                    SearchTerm = $Regex
                                    Key        = $Key
                                    KeyName    = $Key.PSChildName
                                    Reason     = "KeyName"
                                }
                            }
                        }
                    }

                    if ($ValueNameRegex) {
                        foreach ($Regex in $ValueNameRegex) {
                            if ($Key.GetValueNames() -match $Regex) {
                                $SearchRegexFound += [PSCustomObject] @{
                                    SearchTerm = $Regex
                                    Key        = $Key
                                    ValueName  = $Key.GetValueNames()
                                    Reason     = "ValueName"
                                }
                            }
                        }
                    }

                    if ($ValueDataRegex) {
                        foreach ($Regex in $ValueDataRegex) {
                            $ValueDataKey = ($Key.GetValueNames() | % { $Key.GetValue($_) })
                            if ($ValueDataKey -match $Regex) {
                                $SearchRegexFound += [PSCustomObject] @{
                                    SearchTerm = $Regex
                                    Key        = $Key
                                    ValueData  = $ValueDataKey
                                    Reason     = "ValueData"
                                }
                            }
                        }
                    }
                }
            }
            Return $SearchRegexFound
        }
    }
'@
Invoke-Expression -Command $SearchRegistryFunctionString


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYAijwzukyyQ27clpklMLH2kU
# EV6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUyWDm+LWwWKH3IYsrUV9e5BeKT8QwDQYJKoZI
# hvcNAQEBBQAEggEAQ9Kzm0tZY+z6RpxDXGVI/lb2OTr/zFPUv3TC3JiOHGsvm3u0
# a6yfrqaN+Buo7+ZOrzR9HD3Oziy8uD3A6zC0XPN2DDbmG40lSajGdMg/7uQFWv6T
# dU21shWY4UQvkwEqmwJeB3Q2FeOoXkd3WN+6ioaCB3TcvEXkKZGsPPUi6cOvLbpb
# m5KMoKnW+PZS741LHh8tNwS+hL3w3fZqkc7DKFCK8IrAXW4CgkF6+Ca0D3uLmwcN
# K25UGPSce1dcL3BSOw8ZoKEEiCBOOyzpOHLtpakpPKVbC/pigPKvF/JejHr9Xc2y
# ZgI8iPefVOox2Gnb1AIVbIduiEtF8uYxTqih6A==
# SIG # End signature block
