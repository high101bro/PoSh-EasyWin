$AllEventLogNames = wevtutil enum-logs
$EventLogDetails = @()
Foreach ($LogName in $AllEventLogNames) {
    $EventLogMetadata = wevtutil get-log $LogName
            
    $EventLogObject = [pscustomobject]@{}
            
    ForEach ($line in $EventLogMetadata){
        $Name  = $line.split(':').trim()[0]
        $Value = $line.split(':').trim()[1]
        if ($Value) {
            $EventLogObject | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
        }
    }
    $EventLogDetails += $EventLogObject
}
$EventLogDetails `
| Select-Object -Property @{n='Name';e={$_.Name}}, @{n='Enabled';e={$_.Enabled}}, @{n='Type';e={$_.Type}}, @{n='OwningPublisher';e={$_.OwningPublisher}}, @{n='Isolation';e={$_.Isolation}}, @{n='LogFileName';e={$_.LogFileName}}, @{n='MaxSize';e={$_.MaxSize}}, @{n='FileMax';e={$_.FileMax}}, @{n='Retention';e={$_.Retention}}, @{n='AutoBackup';e={$_.AutoBackup}} `
| Sort-Object -Property @{e="Enabled";Descending=$True}, @{e="Name";Descending=$False}