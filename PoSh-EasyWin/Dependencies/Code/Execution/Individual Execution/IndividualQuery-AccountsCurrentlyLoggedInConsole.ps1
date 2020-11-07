$ExecutionStartTime = Get-Date
$CollectionName = "Accounts Currently Logged In via Console"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

<# Version 1
Invoke-Command -ScriptBlock {
    Get-WmiObject -Class Win32_Process -EA "Stop" `
    | Foreach-Object {$_.GetOwner().User} `
    | Where-Object {$_ -ne "NETWORK SERVICE" -and $_ -ne "LOCAL SERVICE" -and $_ -ne "SYSTEM"} `
    | Sort-Object -Unique `
    | ForEach-Object { New-Object psobject -Property @{LoggedOn=$_} } `
    | Select-Object PSComputerName,LoggedOn
} -Session $PSSession `
| Set-Variable SessionData -Force
#>
<# Version 2
Invoke-Command -ScriptBlock {
    Get-WmiObject -Class Win32_Process -EA "Stop" `
    | Select-Object @{N='AccountName';E={$_.GetOwner().User}}, SessionID `
    | Where-Object {$_.AccountName -ne "NETWORK SERVICE" -and $_.AccountName -ne "LOCAL SERVICE" -and $_.AccountName -ne "SYSTEM" -and $_.AccountName -ne $null} `
    | Sort-Object -property AccountName -Unique `
    | ForEach-Object { New-Object pscustomobject -Property @{PSComputerName=$env:ComputerName;AccountName=$_.AccountName;SessionID=$_.SessionID} } `
    | Select-Object PSComputerName,AccountName,SessionID
} -Session $PSSession `
| Set-Variable SessionData -Force
#>


<# Version 3 #>
$scriptBlock = {
    ## Find all sessions matching the specified username
    $quser = quser | Where-Object {$_ -notmatch 'SESSIONNAME'}

    $sessions = ($quser -split "`r`n").trim()

    foreach ($session in $sessions) {
        try {
            # This checks if the value is an integer, if it is then it'll TRY, if it errors then it'll CATCH
            [int]($session -split '  +')[2] | Out-Null

            [PSCustomObject]@{
                PSComputerName = $env:COMPUTERNAME
                UserName       = ($session -split '  +')[0].TrimStart('>')
                SessionName    = ($session -split '  +')[1]
                SessionID      = ($session -split '  +')[2]
                State          = ($session -split '  +')[3]
                IdleTime       = ($session -split '  +')[4]
                LogonTime      = ($session -split '  +')[5]
            }
        }
        catch {
            [PSCustomObject]@{
                PSComputerName = $env:COMPUTERNAME
                UserName       = ($session -split '  +')[0].TrimStart('>')
                SessionName    = ''
                SessionID      = ($session -split '  +')[1]
                State          = ($session -split '  +')[2]
                IdleTime       = ($session -split '  +')[3]
                LogonTime      = ($session -split '  +')[4]
            }
        }
    }
}


foreach ($TargetComputer in $script:ComputerList) {
    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }

        Invoke-Command -ScriptBlock $scriptBlock `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential `
        | Select-Object PSComputerName, *

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$scriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
    }
    else {
        Invoke-Command -ScriptBlock $scriptBlock `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        | Select-Object PSComputerName, *

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$scriptBlock -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
    }
}
Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")



