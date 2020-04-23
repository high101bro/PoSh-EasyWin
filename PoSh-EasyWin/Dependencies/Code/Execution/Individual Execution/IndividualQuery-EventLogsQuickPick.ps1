foreach ($Query in $script:EventLogQueries) {
    if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
        Query-EventLog -CollectionName $Query.Name -Filter $Query.Filter
    }
}
