function Compile-XmlFiles {
    param (
        [string]$LocationOfXMLsToCompile,
        [string]$LocationToSaveCompiledXML
    )
    Remove-Item -Path "$LocationToSaveCompiledXML" -Force
    Start-Sleep -Milliseconds 250

    $XmlFiles = Get-ChildItem "$LocationOfXMLsToCompile"
    $XmlFiles | Where-Object { (Get-Content $PSItem).Length -eq 0 } | Remove-Item -Force

    Import-CliXml $XmlFiles | Export-CliXml $LocationToSaveCompiledXML

    if ($OptionKeepResultsByEndpointsFilesCheckBox.checked -eq $false) {
        if (Test-Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\*\*.xml") {
            Remove-Item -Path "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\*" -Recurse -Force
        }
    }
}


