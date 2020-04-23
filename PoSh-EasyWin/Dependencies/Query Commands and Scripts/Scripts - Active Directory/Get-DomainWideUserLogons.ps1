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