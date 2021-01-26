param(
    $ComputerName,
    $Count=20,
    $FilePath,
    [array]$Search,
    [datetime]$StartTime=((get-date).adddays(-2)),
    [datetime]$EndTime=(get-date),
    [switch]$file,
    [switch]$Network,
    [switch]$Process,
    [switch]$all,
    [switch]$GetOldest
)
 
if ($Process){
#Process creation and termination
$eventID = @(1,2,5,10)
}
if ($Network){
#Network Connections
$eventID = @(3,8)
}
if ($File){
#Network Connections
$eventID = @(11,15)
}
if ($all){$eventID = 1..15}
if ((!$file) -and (!$network) -and (!$process)){$eventID = 1..15}
#allow running of query without search terms
if ($search -eq $Null){$Search = ""}
Foreach ($SearchTerm in $Search){
try{


$HashTable = @{
            logname="Microsoft-Windows-Sysmon/Operational";
            StartTime=$StartTime;
            EndTime=$EndTime;
            ID=$EventID
            }

if ($FilePath){$HashTable.Remove("logname");$HashTable.add("Path",$FilePath)}
if ($search){$HashTable.Add("Data",$SearchTerm)}


if ($ComputerName) {
if ((Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) -ne $true){"$computername unreachable at this time";continue;}

        if (!$GetOldest){
        $Events  = (Get-WinEvent -FilterHashtable $HashTable -MaxEvents $Count -ComputerName $ComputerName -ErrorAction stop)
            }
            else {
            $HashTable.Remove("startime");
            $HashTable.Remove("endtime");
            $Events  = (Get-WinEvent -FilterHashtable $HashTable -MaxEvents 1 -ComputerName $ComputerName -ErrorAction stop -Oldest)}
}
#For directly loaded evtx files 
else {
    if (!$GetOldest){$Events  = (Get-WinEvent -FilterHashtable $HashTable -MaxEvents $Count -ErrorAction stop)}
    else {
            $HashTable.Remove("startime");
            $HashTable.Remove("endtime");
        (Get-WinEvent -FilterHashtable $HashTable -MaxEvents 1  -ErrorAction stop -Oldest)
        }
    }
    
}
            catch [exception]{
            
           if (($_.Exception) -match "No events were found"){
                if($search.count -gt 1){continue}
           Echo "no results for specified time frame"
           }
           if (($_.Exception) -match "There is not an event log "){Echo "SysMon is not Installed"}
           else {$_.exception}
            }

        



Foreach ($sample in $Events){
    $Flow = $sample.message.Split("`n")
#Table Builder
    $SystemEvent = New-Object Psobject -Property @{Name=($flow[0].replace(':',''))}
    $EndNumber = ($Flow.Length - 1)
Foreach ($Item in $flow[-1..$EndNumber]){
    $HashPair = $Item.Split(":",2)
    $SystemEvent | add-member -MemberType NoteProperty -name $HashPair[0]  -value $HashPair[1] -Force
    }

$SystemEvent
}
}

