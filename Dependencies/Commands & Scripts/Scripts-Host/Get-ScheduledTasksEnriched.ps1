$ScheduledTasks = Get-ScheduledTask `
| Select-Object -Property State, Actions, Author, Date, Description, Documentation, Principal, SecurityDescriptor, Settings, Source, TaskName, TaskPath, Triggers, URI, Version, PSComputerName


foreach ($Task in $ScheduledTasks) {
    $Task | Add-Member -MemberType NoteProperty -Name Settings -Value $($Task.Settings | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name SettingsIdleSettings -Value $($Task.Settings.IdleSettings | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name SettingsNetworkSettings -Value $($Task.Settings.NetworkSettings | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name Principal -Value $($Task.Principal | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name Actions -Value $($Task.Actions | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name TriggersCount -Value $Task.Triggers.Count -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name Triggers -Value $($Task.Triggers | Out-String).trim(' ').trim("`r`n") -Force -PassThru `
          | Add-Member -MemberType NoteProperty -Name TriggersRepetition -Value $($Task.Triggers.Repetition | Out-String).trim(' ').trim("`r`n") -Force
}

$ScheduledTasks


