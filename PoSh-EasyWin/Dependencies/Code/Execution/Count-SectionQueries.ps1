Function Count-SectionQueries {
    $script:SectionQueryCount = 0
 
    if ($RegistrySearchCheckbox.checked)                            { $script:SectionQueryCount++ }
    if ($FileSearchDirectoryListingCheckbox.Checked)                { $script:SectionQueryCount++ }
    if ($FileSearchFileSearchCheckbox.Checked)                      { $script:SectionQueryCount++ }
    if ($FileSearchAlternateDataStreamCheckbox.Checked)             { $script:SectionQueryCount++ } 
    if ($SysinternalsSysmonCheckbox.Checked)                        { $script:SectionQueryCount++ }
    if ($SysinternalsAutorunsCheckbox.Checked)                      { $script:SectionQueryCount++ }
    if ($SysinternalsProcessMonitorCheckbox.Checked)                { $script:SectionQueryCount++ }
    if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked) { $script:SectionQueryCount++ }
    if ($EventLogsEventIDsManualEntryCheckbox.Checked)              { $script:SectionQueryCount++ }
    if ($EventLogsEventIDsToMonitorCheckbox.Checked)                { $script:SectionQueryCount++ }
    if ($NetworkEndpointPacketCaptureCheckBox.Checked)              { $script:SectionQueryCount++ }
    if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked)    { $script:SectionQueryCount++ }
    if ($NetworkConnectionSearchRemotePortCheckbox.checked)         { $script:SectionQueryCount++ }
    if ($NetworkConnectionSearchLocalPortCheckbox.checked)          { $script:SectionQueryCount++ }
    if ($NetworkConnectionSearchProcessCheckbox.checked)            { $script:SectionQueryCount++ }
    if ($NetworkConnectionSearchDNSCacheCheckbox.checked)           { $script:SectionQueryCount++ }

    if ($EventLogsQuickPickSelectionCheckbox.Checked) {
        foreach ($Query in $script:EventLogQueries) {
            if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                $script:SectionQueryCount++
            }
        }
    }
}