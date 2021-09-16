$PowerShellSessionsScriptBlock = { 
    Get-WSManInstance -ResourceURI Shell -Enumerate |
        ForEach-Object {
            $Days    = [int]($_.ShellRunTime.split(".").split('D')[0].trim('P'))    * 24 * 60 * 60
            $Hours   = [int]($_.ShellRunTime.split(".").split('T')[1].split('H')[0]) * 60 * 60
            $Minutes = [int]($_.ShellRunTime.split(".").split('H')[1].split('M')[0]) * 60
            $Seconds = [int]($_.ShellRunTime.split(".").split('M')[1].split('S')[0]) + $Minutes + $Hours + $Days
            $_ | Add-Member -MemberType NoteProperty -Name LogonTime -Value (Get-Date).AddSeconds(-$Seconds) -PassThru
        } |
        Select-Object @{n='PSComputerName';e={$env:Computername}}, ClientIP, Owner, ProcessId, State, ShellRunTime, ShellInactivity, MemoryUsed, ProfileLoaded,
        LogonTime, @{n='CollectionType';e={'PowerShellSessions'}} 
}
