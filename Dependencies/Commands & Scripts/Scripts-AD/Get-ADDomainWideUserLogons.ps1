<#
.Synopsis
    Get all logged on Users per Computer/OU/Domain

.Description
    Shows all logged on users by computer name or OU. It’s also possible to query all computers in the entire domain... which could take some time. In one test environment it took about 4 seconds per computer on average, so do the math.

    Be aware that the function above uses the quser command that outputs plain text. There are differences between e.g. German servers and English servers. This means, that you’ll get the output shown above only on Englisch operating systems.

    You can make this a permament by creating a directory in C:\Program Files\Windows PowerShell\Modules and save the code as a .psm1 file. Make sure that the file name and folder name match.

.Example

    Get who is logged a single computer.

        Get-UserLogon -Computer client01

.Example
    Get who is logged into an OU worth of endpoints.

        Get-UserLogon -OU 'ou=Workstations,dc=sid-500,dc=com'

.Example
    Get who is logged into the entire domain.

        Get-UserLogon -All
#>

function Get-UserLogon {
    [CmdletBinding()]
    param (
        [Parameter ()]
        [String]$ComputerName,
        [Parameter ()]
        [String]$OU,
        [Parameter ()]
        [Switch]$All
    )
    $ErrorActionPreference="SilentlyContinue"
    $result=@()

    If ($ComputerName) {
        Invoke-Command -ComputerName $ComputerName -ScriptBlock {quser} | Select-Object -Skip 1 | Foreach-Object {
            $b=$_.trim() -replace '\s+',' ' -replace '>','' -split '\s'
            If ($b[2] -like 'Disc*') {
                $array= ([ordered]@{
                    'User' = $b[0]
                    'Computer' = $ComputerName
                    'Date' = $b[4]
                    'Time' = $b[5..6] -join ' '
                })
                $result+=New-Object -TypeName PSCustomObject -Property $array
            }
            else {
                $array= ([ordered]@{
                    'User' = $b[0]
                    'Computer' = $ComputerName
                    'Date' = $b[5]
                    'Time' = $b[6..7] -join ' '
                })
                $result+=New-Object -TypeName PSCustomObject -Property $array
            }
        }
    }

    If ($OU) {
        $comp  = Get-ADComputer -Filter {(enabled -eq "true")} -SearchBase "$OU" -Properties operatingsystem
        $count = $comp.count
        If ($count -gt 20) {
            Write-Warning "Search $count computers. This may take some time ... About 4 seconds for each computer"
        }
        foreach ($u in $comp) {
            Invoke-Command -ComputerName $u.Name -ScriptBlock {quser} | Select-Object -Skip 1 | ForEach-Object {
                $a=$_.trim() -replace '\s+',' ' -replace '>','' -split '\s'
                If ($a[2] -like '*Disc*') {

                    $array= ([ordered]@{
                        'User' = $a[0]
                        'Computer' = $u.Name
                        'Date' = $a[4]
                        'Time' = $a[5..6] -join ' '
                    })
                    $result+=New-Object -TypeName PSCustomObject -Property $array
                }
                else {
                    $array= ([ordered]@{
                        'User' = $a[0]
                        'Computer' = $u.Name
                        'Date' = $a[5]
                        'Time' = $a[6..7] -join ' '
                    })
                    $result+=New-Object -TypeName PSCustomObject -Property $array
                }
            }
        }
    }

    If ($All) {
        $comp  = Get-ADComputer -Filter {(enabled -eq "true")} -Properties operatingsystem
        $count = $comp.count
        If ($count -gt 20) {
            Write-Warning "Search $count computers. This may take some time ... About 4 seconds for each computer ..."
        }
        foreach ($u in $comp) {
            Invoke-Command -ComputerName $u.Name -ScriptBlock {quser} | Select-Object -Skip 1 | ForEach-Object {
                $a=$_.trim() -replace '\s+',' ' -replace '>','' -split '\s'
                If ($a[2] -like '*Disc*') {
                    $array= ([ordered]@{
                        'User' = $a[0]
                        'Computer' = $u.Name
                        'Date' = $a[4]
                        'Time' = $a[5..6] -join ' '
                    })
                    $result+=New-Object -TypeName PSCustomObject -Property $array
                }
                else {
                    $array= ([ordered]@{
                        'User' = $a[0]
                        'Computer' = $u.Name
                        'Date' = $a[5]
                        'Time' = $a[6..7] -join ' '
                    })
                    $result+=New-Object -TypeName PSCustomObject -Property $array
                }
            }
        }
    }
    Write-Output $result
}
Get-UserLogon -All


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNJectAi9Myb9datp/gSCc/3g
# XzSgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQURO9/McsHxH9IIu3JuA3Tgh3MOSgwDQYJKoZI
# hvcNAQEBBQAEggEAv03FwIelc+xG1V2aGTLYJ3iv0vKUeBhoRcPcTCy/7dxvIJJ0
# lSQ81SIFxN+ABdPB341kDYrojiC0+t4CbX8P3SRv0PkkYSMYu0qQcO7oAz7yjp1W
# GGaS/D2PXUKvsusYGdoHV5UgzNm3o7l/KdM+upN6zY4bWEc41YORiuRpe/q1YQ9e
# 9H2ckUp9cGaG3yIrrJ+Y+ANzVSqLPbvweHsUWq8iMlqKd54ZgUYBsMFNz4jfdGTV
# gW8NC9ZH0lGanrzSEdMj7nAV/vEaaF3PGfzQ1mtTKhvRcxp7JnrhjVxSPO4O81Lq
# r4w/o2OcI0/G7pMky3Mos+CuzoCazl65zp7a2A==
# SIG # End signature block
