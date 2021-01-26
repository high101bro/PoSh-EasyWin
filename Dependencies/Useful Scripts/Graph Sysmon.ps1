$g = New-Graph -Type BidirectionalGraph
Get-WinEvent -FilterHashtable @{
    LogName='Microsoft-Windows-Sysmon/Operational';
    starttime=(Get-date).AddHours(-24)
} | 
Where-Object { $_.id -eq 1 } | 
ForEach-Object { 
    if ( $_.properties[3] ) {
        write-output '-3-----------------'
        Write-Output $_.properties[-3]
        write-output '-2-----------------'
        Write-Output $_.properties[-2]
        write-output '-1-----------------'
        Write-Output $_.properties[-1]
        write-output '0------------------'
        Write-Output $_.properties[0]
        write-output '1------------------'
        Write-Output $_.properties[1]
        write-output '2------------------'
        Write-Output $_.properties[2]
        write-output '3------------------'
        Write-Output $_.properties[3]
        write-output '4------------------'
        Write-Output $_.properties[4]
        write-output '5------------------'
        Write-Output $_.properties[5]
        write-output '6------------------'
        Write-Output $_.properties[6]
#pause
        Add-Edge -From $_.Properties[-2].value -To $_.properties[4].value -Graph $g
#        Add-Edge -From $_.Properties[-2].value -To "$($_.properties[4].value) : $($_.properties[4].value)" -Graph $g
    }
} | out-null

Show-GraphLayout -Graph $g


