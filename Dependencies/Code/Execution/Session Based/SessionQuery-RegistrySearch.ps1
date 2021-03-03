if     ($RegistryKeyNameCheckbox.checked)   { $CollectionName = "Registry Search - Key Name" }
elseif ($RegistryValueNameCheckbox.checked) { $CollectionName = "Registry Search - Value Name" }
elseif ($RegistryValueDataCheckbox.checked) { $CollectionName = "Registry Search - Value Data" }


$ExecutionStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")


$script:ProgressBarEndpointsProgressBar.Value   = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName"


$RegistrySearchDirectory = @()
foreach ($Directory in $($script:RegistrySearchDirectoryRichTextbox.Text).split("`r`n")){ $RegistrySearchDirectory += $Directory.trim() | Where {$_ -ne ''} }

$SearchRegistryKeyName = @()
foreach ($KeyName in $($script:RegistryKeyNameSearchRichTextbox.Text).split("`r`n")){ $SearchRegistryKeyName += $KeyName.trim() | Where {$_ -ne ''} }

$SearchRegistryValueName = @()
foreach ($ValueName in $($script:RegistryValueNameSearchRichTextbox.Text).split("`r`n")){ $SearchRegistryValueName += $ValueName.trim() | Where {$_ -ne ''} }

$SearchRegistryValueData = @()
foreach ($ValueData in $($script:RegistryValueDataSearchRichTextbox.Text).split("`r`n")){ $SearchRegistryValueData += $ValueData.trim() | Where {$_ -ne ''} }


if ($RegistryKeyNameCheckbox.checked)   {
    $CountCommandQueries++
    if ($RegistrySearchRecursiveCheckbox.checked) {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryKeyName,$true,$false,$false)
    }
    else {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryKeyName,$true,$false,$false)
    }
}
if ($RegistryValueNameCheckbox.checked) {
    $CountCommandQueries++
    if ($RegistrySearchRecursiveCheckbox.checked) {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryValueName,$false,$true,$false)
    }
    else {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryValueName,$false,$true,$false)
    }
}
if ($RegistryValueDataCheckbox.checked) {
    $CountCommandQueries++
    if ($RegistrySearchRecursiveCheckbox.checked) {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$true,$SearchRegistryValueData,$false,$false,$true)
    }
    else {
        $SearchRegistryCommand = @($RegistrySearchDirectory,$false,$SearchRegistryValueData,$false,$false,$true)
    }
}


Invoke-Command -ScriptBlock $script:QueryRegistryFunction `
-ArgumentList $SearchRegistryCommand `
-Session $PSSession `
| Set-Variable SessionData


Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$script:QueryRegistryFunction -ArgumentList `$SearchRegistryCommand -Session `$PSSession"
###$ResultsListBox.Items.Add("$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")


$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force


$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value   += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500


