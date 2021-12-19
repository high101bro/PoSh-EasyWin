<#
.Synopsis
    Get all logged on Users per Computer/OU/Domain

.Description
    Shows all logged on users by computer name or OU. It�s also possible to query all computers in the entire domain... which could take some time. In one test environment it took about 4 seconds per computer on average, so do the math.

    Be aware that the function above uses the quser command that outputs plain text. There are differences between e.g. German servers and English servers. This means, that you�ll get the output shown above only on Englisch operating systems.

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUPUVBTeOV1t6ZwxH7eMP5ZOoY
# wAigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUYsmnnjp/v3nvoVX4nZ9lGNWSs8owDQYJKoZI
# hvcNAQEBBQAEggEATn1y8nLbtRpRqzANhTe1dxRmz/0RLz6bPi4Wg/QP6c2Koqzi
# y7ir4j0LtbcsjRgn+qHSf78+04FDqiiIRKhmWGku62hPJnF7UR/8RbjX9tPer2yv
# +N0ppbBuSM6fEcKul91kd1EesAnIbd7fRw+FDIlTe2FD4ejGutBFb+O2bhNICP1K
# sbN/jgPLqSMLMT4OQMTBudwzG7WvXg+ZpzlN1f0eNHNBrog68+L/B/V3+RoGfRIt
# xiljvq2BpzNtIWDQV2HmtRSFQvk/TEn7bl12MVVnbkYHAAjS0uaFMKb8Sen6QxrW
# 1Tjdl4081G7VRJZPy/PDHIO3izyMkXL8wYKoNw==
# SIG # End signature block
