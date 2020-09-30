function Compile-CsvFiles {
    param (
        [string]$LocationOfCSVsToCompile,
        [string]$LocationToSaveCompiledCSV
    )
    Remove-Item -Path "$LocationToSaveCompiledCSV" -Force
    Start-Sleep -Milliseconds 250

    $CompiledCSVs = $null
    Get-ChildItem "$LocationOfCSVsToCompile" | foreach {
        if ((Get-Content $PSItem).Length -eq 0) {
            Remove-Item $PSItem
        }
        else {
            $CompiledCSVs +=  Import-Csv -Path $_
        }
    }
    $CompiledCSVs | Select-Object -Property * -Unique | Export-Csv $LocationToSaveCompiledCSV -NoTypeInformation -Force

    if ($OptionKeepResultsByEndpointsFilesCheckBox.checked -eq $false) {
        if (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\*\*.csv") {
            Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\*" -Recurse -Force
        }
    }
}

# Below is a deprecated technique, the above is much faster with larger files
# The only other key difference in output between the two is that the above produces slightly larger file size as empty fields are represented with double quotes, see below:
#   The above code produces files with: "text","","","","text"
#   The below code produces files with: "text",,,,"text"
<#
function Compile-CsvFiles {
    param (
        [string]$LocationOfCSVsToCompile,
        [string]$LocationToSaveCompiledCSV
    )
    Remove-Item -Path "$LocationToSaveCompiledCSV" -Force
    Start-Sleep -Milliseconds 250

    $GetFirstLine = $true
    Get-ChildItem "$LocationOfCSVsToCompile" | foreach {
        if ((Get-Content $PSItem).Length -eq 0) {
            Remove-Item $PSItem
        }
        else {
            $FilePath = $_
            $Lines = $Lines = Get-Content $FilePath
            $LinesToWrite = switch($GetFirstLine) {
                $true  {$Lines}
                $false {$Lines | Select -Skip 1}
            }
            $GetFirstLine = $false
            Add-Content -Path "$LocationToSaveCompiledCSV" $LinesToWrite -Force
        }
    }
}
#>

<#
$csv1 = Import-Csv -Path ".\csv1.csv"
$csv2 = Import-Csv -Path ".\csv2.csv"

$merged = $csv1 + $csv2

$merged | Select -Property * -Unique

#>

