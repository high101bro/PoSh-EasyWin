if ($RegistryRegistryCheckbox.checked)                       { $CountCommandQueries++ ; Query-Registry }
if ($FileSearchDirectoryListingCheckbox.Checked)             { $CountCommandQueries++ ; Query-DirectoryListing }
if ($FileSearchFileSearchCheckbox.Checked)                   { $CountCommandQueries++ ; Query-FilenameAndFileHash }
if ($FileSearchAlternateDataStreamCheckbox.Checked)          { $CountCommandQueries++ ; Query-AlternateDataStream } 
if ($SysinternalsSysmonCheckbox.Checked)                     { $CountCommandQueries++ ; Push-SysinternalsSysmon -SysmonXMLPath $script:SysmonXMLPath -SysmonXMLName $script:SysmonXMLName }
if ($SysinternalsAutorunsCheckbox.Checked)                   { $CountCommandQueries++ ; Push-SysinternalsAutoruns }
if ($SysinternalsProcessMonitorCheckbox.Checked)             { $CountCommandQueries++ ; Push-SysinternalsProcessMonitor -SysinternalsProcessMonitorTime $SysinternalsProcessMonitorTimeComboBox.Text }        
if ($EventLogsEventIDsManualEntryCheckbox.Checked)           { $CountCommandQueries++ ; EventLogsEventCodeManualEntryCommand }
if ($EventLogsEventIDsIndividualSelectionCheckbox.Checked)   { $CountCommandQueries++ ; EventLogsEventCodeIndividualSelectionCommand }
if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked) { $CountCommandQueries++ ; Query-NetworkConnectionRemoteIPAddress }
if ($NetworkConnectionSearchRemotePortCheckbox.checked)      { $CountCommandQueries++ ; Query-NetworkConnectionRemotePort }
if ($NetworkConnectionSearchProcessCheckbox.checked)         { $CountCommandQueries++ ; Query-NetworkConnectionProcess }
if ($NetworkConnectionSearchDNSCacheCheckbox.checked)        { $CountCommandQueries++ ; Query-NetworkConnectionSearchDNSCache }
if ($EventLogsQuickPickSelectionCheckbox.Checked) {
    foreach ($Query in $script:EventLogQueries) {
        if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
            $CountCommandQueries++
            Query-EventLog -CollectionName $Query.Name -Filter $Query.Filter
        }
    }
}