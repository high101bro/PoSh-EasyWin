$StatisticsRefreshButtonAdd_Click = {
    $StatisticsResults = Get-PoShEasyWinStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults
}


