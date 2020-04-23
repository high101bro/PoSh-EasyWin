$CollectionName = "Event Logs - Event IDs Manual Entry"

$ManualEntry = $EventLogsEventIDsManualEntryTextbox.Lines
#$ManualEntry = ($EventLogsEventIDsManualEntryTextbox.Text).split("`r`n")
$ManualEntry = $ManualEntry -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",""
$ManualEntry = $ManualEntry | Where-Object {$_.trim() -ne ""}

# Variables begins with an open "(
$EventLogsEventIDsManualEntryTextboxFilter = '('

foreach ($EventCode in $ManualEntry) {
    $EventLogsEventIDsManualEntryTextboxFilter += "(EventCode='$EventCode') OR "
}
# Replaces the ' OR ' at the end of the varable with a closing )"
$Filter = $EventLogsEventIDsManualEntryTextboxFilter -replace " OR $",")"
Query-EventLog -CollectionName $CollectionName -Filter $Filter
