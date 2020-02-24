function Query-Registry {
    $CollectionName = "Search Registry"
    $CollectionCommandStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

    # The Search-Registry function is placed into a variable a '$QueryRegistryFunctionInput' that is used as the argument for -InitializationScript for Start-Job
    # When the Start-Job is executed with the -InitializationScript, it passes in the variable and makes the Search-Registry function available in the job
    $QueryRegistryFunctionInput = {
        function Search-Registry {  
            [CmdletBinding()] 
            param( 
                [Parameter(Mandatory, Position=0, ValueFromPipelineByPropertyName)] 
                [Alias("PsPath")] 
                # Registry path to search 
                [string[]] $Path, 
                # Specifies whether or not all subkeys should also be searched 
                [switch] $Recurse, 
                [Parameter(ParameterSetName="SingleSearchString", Mandatory)]
                # A regular expression that will be checked against key names, value names, and value data (depending on the specified switches) 
                [string[]] $SearchRegex, 
                [Parameter(ParameterSetName="SingleSearchString")] 
                # When the -SearchRegex parameter is used, this switch means that key names will be tested (if none of the three switches are used, keys will be tested) 
                [switch] $KeyName, 
                [Parameter(ParameterSetName="SingleSearchString")] 
                # When the -SearchRegex parameter is used, this switch means that the value names will be tested (if none of the three switches are used, value names will be tested) 
                [switch] $ValueName, 
                [Parameter(ParameterSetName="SingleSearchString")] 
                # When the -SearchRegex parameter is used, this switch means that the value data will be tested (if none of the three switches are used, value data will be tested) 
                [switch] $ValueData, 
                [Parameter(ParameterSetName="MultipleSearchStrings")] 
                # Specifies a regex that will be checked against key names only 
                [string[]] $KeyNameRegex, 
                [Parameter(ParameterSetName="MultipleSearchStrings")] 
                # Specifies a regex that will be checked against value names only 
                [string[]] $ValueNameRegex, 
                [Parameter(ParameterSetName="MultipleSearchStrings")] 
                # Specifies a regex that will be checked against value data only 
                [string[]] $ValueDataRegex 
            ) 
        
            begin { 
                switch ($PSCmdlet.ParameterSetName) { 
                    SingleSearchString { 
                        $NoSwitchesSpecified = -not ($PSBoundParameters.ContainsKey("KeyName") -or $PSBoundParameters.ContainsKey("ValueName") -or $PSBoundParameters.ContainsKey("ValueData")) 
                        if ($KeyName   -or $NoSwitchesSpecified) { $KeyNameRegex   = $SearchRegex } 
                        if ($ValueName -or $NoSwitchesSpecified) { $ValueNameRegex = $SearchRegex } 
                        if ($ValueData -or $NoSwitchesSpecified) { $ValueDataRegex = $SearchRegex } 
                    } 
                    MultipleSearchStrings { 
                        # No extra work needed 
                    } 
                } 
            } 
        
            process { 
                $SearchRegexFound = @()
                foreach ($CurrentPath in $Path) { 
                    Get-ChildItem $CurrentPath -Recurse:$Recurse |  
                    ForEach-Object { 
                        $Key = $_ 
                        if ($KeyNameRegex) { 
                            foreach ($Regex in $KeyNameRegex) { 
                                if ($Key.PSChildName -match $Regex) {  
                                    $SearchRegexFound += [PSCustomObject] @{ 
                                        SearchTerm = $Regex
                                        Key        = $Key
                                        KeyName    = $Key.PSChildName
                                        Reason     = "KeyName" 
                                    } 
                                }
                            }  
                        } 
    
                        if ($ValueNameRegex) {  
                            foreach ($Regex in $ValueNameRegex) { 
                                if ($Key.GetValueNames() -match $Regex) {  
                                    $SearchRegexFound += [PSCustomObject] @{ 
                                        SearchTerm = $Regex
                                        Key        = $Key 
                                        ValueName  = $Key.GetValueNames()
                                        Reason     = "ValueName" 
                                    } 
                                }  
                            }
                        } 
    
                        if ($ValueDataRegex) {  
                            foreach ($Regex in $ValueDataRegex) { 
                                $ValueDataKey = ($Key.GetValueNames() | % { $Key.GetValue($_) })
                                if ($ValueDataKey -match $Regex) {  
                                    $SearchRegexFound += [PSCustomObject] @{ 
                                        SearchTerm = $Regex
                                        Key        = $Key 
                                        ValueData  = $ValueDataKey
                                        Reason     = "ValueData"
                                    } 
                                } 
                            }                            
                        }
                    } 
                } 
                Return $SearchRegexFound
            } 
        } 
    }
    


    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName,
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
        $RegistryRegistryDirectory = @()
        foreach ($Directory in $($script:RegistryRegistryDirectoryTextbox.Text).split("`r`n")){ $RegistryRegistryDirectory += $Directory | Where {$_ -ne ''} }

        $SearchRegistryKeyName = @()
        foreach ($KeyName in $($script:RegistryKeyNameSearchTextbox.Text).split("`r`n")){ $SearchRegistryKeyName += $KeyName | Where {$_ -ne ''} }

        $SearchRegistryValueName = @()
        foreach ($ValueName in $($script:RegistryValueNameSearchTextbox.Text).split("`r`n")){ $SearchRegistryValueName += $ValueName | Where {$_ -ne ''} }

        $SearchRegistryValueData = @()
        foreach ($ValueData in $($script:RegistryValueDataSearchTextbox.Text).split("`r`n")){ $SearchRegistryValueData += $ValueData | Where {$_ -ne ''} }

        if ($RegistryKeyNameCheckbox.checked)   { 
            $CountCommandQueries++
            if ($RegistryRegistryRecursiveCheckbox.checked) {
                $SearchRegistryCommand = "Search-Registry -Path `$RegistryRegistryDirectory -Recurse -SearchRegex `$SearchRegistryKeyName -KeyName -ErrorAction SilentlyContinue"
            }
            else {
                $SearchRegistryCommand = "Search-Registry -Path `$RegistryRegistryDirectory -SearchRegex `$SearchRegistryKeyName -KeyName -ErrorAction SilentlyContinue"
            }
        }
        if ($RegistryValueNameCheckbox.checked) { 
            $CountCommandQueries++
            if ($RegistryRegistryRecursiveCheckbox.checked) {
                $SearchRegistryCommand = "Search-Registry -Path `$RegistryRegistryDirectory -Recurse -SearchRegex `$SearchRegistryValueName -ValueName -ErrorAction SilentlyContinue"
            }
            else {
                $SearchRegistryCommand = "Search-Registry -Path `$RegistryRegistryDirectory -SearchRegex `$SearchRegistryValueName -ValueName -ErrorAction SilentlyContinue"
            }
        }
        if ($RegistryValueDataCheckbox.checked) { 
            $CountCommandQueries++
            if ($RegistryRegistryRecursiveCheckbox.checked) {
                $SearchRegistryCommand = "Search-Registry -Path `$RegistryRegistryDirectory -Recurse -SearchRegex `$SearchRegistryValueData -ValueData -ErrorAction SilentlyContinue"
            }
            else {
                $SearchRegistryCommand = "Search-Registry -Path `$RegistryRegistryDirectory -SearchRegex `$SearchRegistryValueData -ValueData -ErrorAction SilentlyContinue"
            }
        }

$QueryJob = @"
      Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
        param(`$TargetComputer, `$RegistryRegistryDirectory, `$SearchRegistryKeyName, `$SearchRegistryValueName, `$SearchRegistryValueData, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
        [System.Threading.Thread]::CurrentThread.Priority = 'High'
          ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

          `$SearchRegistryFoundList = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
              param(`$TargetComputer, `$RegistryRegistryDirectory, `$SearchRegistryKeyName, `$SearchRegistryValueName, `$SearchRegistryValueData)

              # This variable is from the dot source Search-Registry.ps1 and contains the the functiont that searches registry
              $QueryRegistryFunctionInput

"@
$QueryJob += @"
              $SearchRegistryCommand

"@
$QueryJob += @"
            } -ArgumentList @(`$TargetComputer, `$RegistryRegistryDirectory, `$SearchRegistryKeyName, `$SearchRegistryValueName, `$SearchRegistryValueData)
      `$SearchRegistryFoundList | Where-Object key -ne '' | Select-Object -Property @{Name='PSComputerName';Expression={`$(`$TargetComputer)}}, * | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation
    } -ArgumentList @(`$TargetComputer, `$RegistryRegistryDirectory, `$SearchRegistryKeyName, `$SearchRegistryValueName, `$SearchRegistryValueData, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)

"@
    Invoke-Expression -Command $QueryJob
    }
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
}
