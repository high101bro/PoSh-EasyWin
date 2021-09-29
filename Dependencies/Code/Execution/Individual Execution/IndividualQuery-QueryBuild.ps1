
function IndividualQuery-QueryBuild {
    param(
        [switch]$UseComputerName,
        [switch]$UseSession
    )

    $CollectionName = ($script:CustomQueryScriptBlockTextbox.text -split ' ')[0]
    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

    #$OutputFilePath      = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName"

    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        $InvokeSplatting = @{
            ScriptBlock = {
                param($script:ShowCommandQueryBuild)
                Invoke-Expression -Command $script:ShowCommandQueryBuild
            }
            ArgumentList = $script:ShowCommandQueryBuild
            AsJob        = $true
            JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            ErrorAction = 'Stop'
        }

        if ($UseComputerName) {
            $InvokeSplatting += @{ 
                ComputerName = $TargetComputer
            }
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                $InvokeSplatting += @{
                    Credential = $script:Credential
                }
            }
        }
        elseif ($UseSession) {                                
            $InvokeSplatting += @{ 
                Session = $($PoShEasyWinPSSessions | Where-Object {$_.ComputerName -eq $TargetComputer -and $_.State -match 'Open'} ) 
                # Credentials are used when intially creating the PSSession
            }    
        }

        Invoke-Command @InvokeSplatting
        $InvokeSplatting | ogv
        Create-LogEntry -LogFile $LogFile -Message "$InvokeSplatting"
    }

    $EndpointString = ''
    foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
    $SearchString = ''
    #foreach ($item in $NetworkConnectionSearchDNSCache) {$SearchString += "$item`n" }

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
Command
===========================================================================
$($SearchString.trim())

"@

    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -InputValues $InputValues
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $CollectionName
        Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }


    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
}

