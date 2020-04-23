$CollectionCommandStartTime = Get-Date
$CollectionName = "Registry Search"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value   = 0

$RegistrySearchDirectoryList = ($script:RegistrySearchDirectoryRichTextbox.Text).split("`r`n")
$RegistryKeyNameSearchList   = ($script:RegistryKeyNameSearchRichTextbox.Text).split("`r`n")
$RegistryValueNameSearchList = ($script:RegistryValueNameSearchRichTextbox.Text).split("`r`n")
$RegistryValueDataSearchList = ($script:RegistryValueDataSearchRichTextbox.Text).split("`r`n")

$RegistrySearchDirectory = @()
foreach ($Directory in $RegistrySearchDirectoryList ){ $RegistrySearchDirectory += $Directory | Where {$_ -ne ''} }

$SearchRegistryKeyName = @()
foreach ($KeyName in $RegistryKeyNameSearchList ){ $SearchRegistryKeyName += $KeyName | Where {$_ -ne ''} }

$SearchRegistryValueName = @()
foreach ($ValueName in $RegistryValueNameSearchList ){ $SearchRegistryValueName += $ValueName | Where {$_ -ne ''} }

$SearchRegistryValueData = @()
foreach ($ValueData in $RegistryValueDataSearchList ){ $SearchRegistryValueData += $ValueData | Where {$_ -ne ''} }

$CollectionCommandStartTime = Get-Date



if ($RegistryKeyNameCheckbox.checked)   { 
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName - Key Name")
    $PoShEasyWin.Refresh()

    $OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Registry Search - Key Name"                   
    if ($RegistrySearchRecursiveCheckbox.checked) {
        Invoke-Command -ScriptBlock {
            param($SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryKeyName)
            Invoke-Expression $SearchRegistryFunctionString
            Search-Registry -Path $RegistrySearchDirectory -Recurse -SearchRegex $SearchRegistryKeyName -KeyName -ErrorAction SilentlyContinue
        } -ArgumentList $SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryKeyName -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    else {
        Invoke-Command -ScriptBlock {
            param($SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryKeyName)
            Invoke-Expression $SearchRegistryFunctionString
            Search-Registry -Path $RegistrySearchDirectory -SearchRegex $SearchRegistryKeyName -KeyName -ErrorAction SilentlyContinue
        } -ArgumentList $SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryKeyName -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    $ResultsListBox.Items.RemoveAt(1)
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName - Key Name")
    $PoShEasyWin.Refresh()
}



if ($RegistryValueNameCheckbox.checked) { 
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName - Value Name")
    $PoShEasyWin.Refresh()

    $OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Registry Search - Value Name"
    if ($RegistrySearchRecursiveCheckbox.checked) {
        Invoke-Command -ScriptBlock {
            param($SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryValueName)
            Invoke-Expression $SearchRegistryFunctionString
            Search-Registry -Path $RegistrySearchDirectory -Recurse -SearchRegex $SearchRegistryValueName -ValueName -ErrorAction SilentlyContinue
        } -ArgumentList $SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryValueName -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    else {
        Invoke-Command -ScriptBlock {
            param($SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryValueName)
            Invoke-Expression $SearchRegistryFunctionString
            Search-Registry -Path $RegistrySearchDirectory -SearchRegex $SearchRegistryValueName -ValueName -ErrorAction SilentlyContinue
        } -ArgumentList $SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryValueName -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    $ResultsListBox.Items.RemoveAt(1)
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName - Value Name")
    $PoShEasyWin.Refresh()    
}



if ($RegistryValueDataCheckbox.checked) { 
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName - Value Data")
    $PoShEasyWin.Refresh()

    $OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Registry Search - Value Data"
    if ($RegistrySearchRecursiveCheckbox.checked) {       
        Invoke-Command -ScriptBlock {
            param($SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryValueData)
            Invoke-Expression $SearchRegistryFunctionString
            Search-Registry -Path $RegistrySearchDirectory -Recurse -SearchRegex $SearchRegistryValueData -ValueData -ErrorAction SilentlyContinue
        } -ArgumentList $SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryValueData -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    else {
        Invoke-Command -ScriptBlock {
            param($SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryValueData)
            Invoke-Expression $SearchRegistryFunctionString
            Search-Registry -Path $RegistrySearchDirectory -SearchRegex $SearchRegistryValueData -ValueData -ErrorAction SilentlyContinue
        } -ArgumentList $SearchRegistryFunctionString,$RegistrySearchDirectory,$SearchRegistryValueData -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    $ResultsListBox.Items.RemoveAt(1)
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName - Value Data")
    $PoShEasyWin.Refresh()    
}


$script:ProgressBarQueriesProgressBar.Value   += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500
