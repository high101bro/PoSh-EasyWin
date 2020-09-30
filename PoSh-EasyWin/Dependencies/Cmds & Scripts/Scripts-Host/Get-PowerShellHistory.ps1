<#
    .Synopsis
    Gets the PowerShell History of user profiles
#>
#Get-Content ((Get-PSReadLineOption).HistorySavePath)


$Users = Get-ChildItem C:\Users | Where-Object {$_.PSIsContainer -eq $true}

$Results = @()
Foreach ($User in $Users) {
    $UserPowerShellHistoryPath = "$($User.FullName)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (Test-Path $UserPowerShellHistoryPath) {
        $count = 1
        $UserHistory += Get-Content "$UserPowerShellHistoryPath" -ErrorAction Stop | ForEach-Object {"$_ `r`n"}
        foreach ($HistoryEntry in $UserHistory) {
            $Results += [PSCustomObject]@{
                PSComputerName    = "$env:COMPUTERNAME"
                HistoryCount      = "$Count"
                ProfileName       = "$($User.Name)"
                PowerShellHistory = "$HistoryEntry"
                ProfilePath       = "$($User.FullName)"
                HistoryPath       = "$UserPowerShellHistoryPath"
            }
            $Count += 1
        }
    }
    else {
        $Results += [PSCustomObject]@{
            PSComputerName    = "$env:COMPUTERNAME"
            HistoryCount      = "0"
            ProfileName       = "$($User.Name)"
            PowerShellHistory = "There is not PowerShell History for $($User.BaseName)."
            ProfilePath       = "$($User.FullName)"
            HistoryPath       = "$UserPowerShellHistoryPath"
        }
    }
}
$Results



