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
# EV6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUyWDm+LWwWKH3IYsrUV9e5BeKT8QwDQYJKoZI
# hvcNAQEBBQAEggEArHZbXmx+3z7TldBeicfuo7VD4Q/Ddjd6mEfabU8JvPJIkdV6
# w3MkkorkszypkNLWNFufGSs5g2UNSNivHk0J1JDPtx3Vgv5rh+IbKKet2hloVdLf
# R5w1yd31+QAp4+FN1b4p4xqAWfdHItZ4dlJ5jGg2TCuK3LxkXIsNVBJTgQeeobVv
# w8uKfDXMdPfUkXZIe8NaPMPG0NgbQ6Q2vMMQmZjSREQJ2uBiZTPX0fFl2MLB6NEb
# IW8xQK1VR0VEp2Y5QFveCriwV6lGMLmcwGjztTSbiHa5Z7sC65L2/QPLrccrrT14
# rE9/8A6O9U2ul10vLAVW4JEFW28Gj0BGnr4cPQ==
# SIG # End signature block
