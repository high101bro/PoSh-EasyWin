$CollectionName = "Event Logs - Event IDs To Monitor"

# Variables begins with an open "(
$EventLogsEventIDsToMonitorCheckListBoxFilter = '('
foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBox.CheckedItems) {
    # Get's just the EventID from the checkbox
    $Checked = $($Checked -split " ")[0]

    $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
}
# Replaces the ' OR ' at the end of the varable with a closing )"
$Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"
Query-EventLog -CollectionName $CollectionName -Filter $Filter
