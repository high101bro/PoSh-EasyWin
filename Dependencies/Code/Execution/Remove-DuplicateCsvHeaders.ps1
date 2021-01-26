function Remove-DuplicateCsvHeaders {
    $count = 1
    $output = @()
    $Contents = Get-Content "$($script:CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    $Header = $Contents | Select-Object -First 1
    foreach ($line in $Contents) {
        if ($line -match $Header -and $count -eq 1) {
            $output = $line + "`r`n"
            $count ++
        }
        elseif ($line -notmatch $Header) {
            $output += $line + "`r`n"
        }
    }
    Remove-Item -Path "$($script:CollectedDataTimeStampDirectory)\$($CollectionName).csv"
    $output | Out-File -FilePath "$($script:CollectedDataTimeStampDirectory)\$($CollectionName).csv"
}

