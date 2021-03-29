function Compile-CsvFiles {
    param (
        [string]$LocationOfCSVsToCompile,
        [string]$LocationToSaveCompiledCSV
    )
    Remove-Item -Path "$LocationToSaveCompiledCSV" -Force
    Start-Sleep -Milliseconds 250

    $CompiledCSVs = @()
    Get-ChildItem "$LocationOfCSVsToCompile" | ForEach-Object {
        if ((Get-Content $_).Length -eq 0) {
            # Removes any files that don't contain data
            Remove-Item $_
        }
        else {
            $CompiledCSVs += Import-Csv -Path $_
        }
    }
    $CompiledCSVs | Select-Object -Property * -Unique | Export-Csv $LocationToSaveCompiledCSV -NoTypeInformation -Force

    # # BUG: When the box is unchecked, the results don't compile correctly
    # if ($OptionKeepResultsByEndpointsFilesCheckBox.checked -eq $false) {
    #     if (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\*\*.csv") {
    #         Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\*\*.csv" -Recurse -Force
    #     }
    # }
}

