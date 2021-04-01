$StatisticsRefreshButtonAdd_Click = {
    $StatisticsResults = Get-PoShEasyWinStatistics
    $PoshEasyWinStatistics.text = $StatisticsResults
}


