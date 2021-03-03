if     ($RegistryKeyNameCheckbox.checked)   { $CollectionName = "Registry Search - Key Name" }
elseif ($RegistryValueNameCheckbox.checked) { $CollectionName = "Registry Search - Value Name" }
elseif ($RegistryValueDataCheckbox.checked) { $CollectionName = "Registry Search - Value Data" }

$ExecutionStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


$RegistrySearchDirectory = ($script:RegistrySearchDirectoryRichTextbox.Text).split("`r`n")
$SearchRegistryKeyName   = ($script:RegistryKeyNameSearchRichTextbox.Text).split("`r`n")
$SearchRegistryValueName = ($script:RegistryValueNameSearchRichTextbox.Text).split("`r`n")
$SearchRegistryValueData = ($script:RegistryValueDataSearchRichTextbox.Text).split("`r`n")

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

function MonitorJobScriptBlock {
    param(
        $ExecutionStartTime,
        $CollectionName,
        $RegistrySearchDirectory,
        $SearchRegistryKeyName,
        $SearchRegistryValueName,
        $SearchRegistryValueData,
        $SearchRegistryCommand
    )
    
    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -LogFile $LogFile -Message $CollectionName


        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
            Invoke-Command -ScriptBlock $script:QueryRegistryFunction `
            -ArgumentList $SearchRegistryCommand `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
            -Credential $script:Credential

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$script:QueryRegistryFunction -ArgumentList `$SearchRegistryCommand  -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
            $ResultsListBox.Items.Add("$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName -- $TargetComputer")
        }
        else {
            Invoke-Command -ScriptBlock $script:QueryRegistryFunction `
            -ArgumentList $SearchRegistryCommand `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `$script:QueryRegistryFunction -ArgumentList `$SearchRegistryCommand  -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)''"
            $ResultsListBox.Items.Add("$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName -- $TargetComputer")
        }
    }
}
Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$RegistrySearchDirectory,$SearchRegistryKeyName,$SearchRegistryValueName,$SearchRegistryValueData,$SearchRegistryCommand)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString1 = ''
foreach ($item in $RegistrySearchDirectory) {$SearchString1 += "$item`n"}
$SearchString2 = ''
foreach ($item in $SearchRegistryKeyName) {$SearchString2 += "$item`n"}
$SearchString3 = ''
foreach ($item in $SearchRegistryValueName) {$SearchString3 += "$item`n"}
$SearchString4 = ''
foreach ($item in $SearchRegistryValueData) {$SearchString4 += "$item`n"}

$InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
Registry Paths To Search Within:
===========================================================================
$($SearchString1.trim())

===========================================================================
Key Name Search Terms:
===========================================================================
$($SearchString2.trim())

===========================================================================
Value String Search Terms:
===========================================================================
$($SearchString3.trim())

===========================================================================
Value Data Search Terms:
===========================================================================
$($SearchString4.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$RegistrySearchDirectory,$SearchRegistryKeyName,$SearchRegistryValueName,$SearchRegistryValueData,$SearchRegistryCommand) -InputValues $InputValues
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


