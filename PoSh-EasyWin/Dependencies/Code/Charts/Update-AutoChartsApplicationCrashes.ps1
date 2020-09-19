
function Update-AutoChartsApplicationCrashes {
    param($ComputerNameList)
    $script:ProgressBarFormProgressBar.Value   = 0
    $script:ProgressBarFormProgressBar.Maximum = $script:ComputerList.count

    $script:ProgressBarMessageLabel.text = "Note: Collected results are also saved locally as CSV and XML files."

#    $PullNewDataScriptPath = "$QueryCommandsAndScripts\Scripts-Host\Application Crashes.ps1"

    $ExecutionStartTime = Get-Date
            
    Foreach ($TargetComputer in $ComputerNameList) {
        <#
        if ($AutoChartPullNewDataEnrichedCheckBox.checked) {
            if ($ComputerListProvideCredentialsCheckBox.Checked) {                        
                if (!$script:Credential) { Create-NewCredentials }
                if ($AutoChartProtocolWinRMRadioButton.checked) {
                    $CollectionName = 'Get-ApplicationCrashes - (WinRM) Script'

                    Invoke-Command -FilePath $PullNewDataScriptPath `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                    -Credential $script:Credential
                }
            }
            else {
                if ($AutoChartProtocolWinRMRadioButton.checked) {
                    $CollectionName = 'Get-ApplicationCrashes - (WinRM) Script'

                    Invoke-Command -FilePath $PullNewDataScriptPath `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                }
            }
        }
        else {
        #>
            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                if ($AutoChartProtocolWinRMRadioButton.checked) {
                    $CollectionName = 'Application Crashes - (WinRM)'
                    Invoke-Command -ScriptBlock {Get-EventLog -LogName Application -InstanceId 1000 | Select-Object -First 1000 } `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                    -Credential $script:Credential
                }
                elseif ($AutoChartProtocolRPCRadioButton.checked) {
                    $CollectionName = 'Application Crashes - (RPC)'

                    Start-Job -ScriptBlock {
                        param($TargetComputer,$script:Credential)
                        Get-WmiObject -Class Win32_NTLogEvent -Filter '(EventCode=1000)' -ComputerName $TargetComputer -Credential $script:Credential | Select-Object -First 1000
                    } `
                    -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                    -ArgumentList @($TargetComputer,$script:Credential)
                }
                elseif ($AutoChartProtocolSMBRadioButton.checked) {
                    $CollectionName = 'Application Crashes - (SMB)'

                    New-Item -ItemType Directory "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)" -ErrorAction SilentlyContinue
                    $CurrentTime = Get-Date
                    $Timecount   = $ExecutionStartTime - $CurrentTime
                    $Hour        = [Math]::Truncate($Timecount)
                    $Minute      = ($ExecutionStartTime - $Hour) * 60
                    $Second      = [int](($Minute - ([Math]::Truncate($Minute))) * 60)
                    $Minute      = [Math]::Truncate($Minute)
                    $Timecount   = [datetime]::Parse("$Hour`:$Minute`:$Second")
    
                    $script:ProgressBarMainLabel.text = "Status:
Iterating Through Endpoints
Time Updates As Endpoints Respond
Elasped Time:  $($Timecount -replace '-','')"
                 
                    $Username = $script:Credential.UserName
                    $Password = $script:Credential.GetNetworkCredential().Password

                    & $PsExecPath "\\$TargetComputer" -AcceptEULA -NoBanner -u $UserName -p $Password powershell -command 'Invoke-Command -ScriptBlock {Get-EventLog -LogName Application -InstanceId 1000 | Select-Object -First 1000 | ConvertTo-Csv -NoType' | ConvertFrom-Csv | Export-CSV "$($script:CollectionSavedDirectoryTextBox.text)\Results By Endpoints\$CollectionName\$CollectionName -- $TargetComputer.csv" -NoTypeInformation
                    $script:ProgressBarFormProgressBar.Value += 1
                }
            }
            else {
                if ($AutoChartProtocolWinRMRadioButton.checked) {
                    $CollectionName = 'Application Crashes - (WinRM)'

                    Invoke-Command -ScriptBlock {Get-EventLog -LogName Application -InstanceId 1000 | Select-Object -First 1000 } `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                }
                
                elseif ($AutoChartProtocolRPCRadioButton.checked) {
                    $CollectionName = 'Application Crashes - (RPC)'

                    Start-Job -ScriptBlock {
                        param($TargetComputer)
                        Get-WmiObject -Class Win32_NTLogEvent -Filter '(EventCode=1000)' -ComputerName $TargetComputer | Select-Object -First 1000
                    } `
                    -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                    -ArgumentList @($TargetComputer)
                }
                elseif ($AutoChartProtocolSMBRadioButton.checked) {
                    $CollectionName = 'Application Crashes - (SMB)'

                    New-Item -ItemType Directory "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)" -ErrorAction SilentlyContinue
                    $CurrentTime = Get-Date
                    $Timecount   = $ExecutionStartTime - $CurrentTime
                    $Hour        = [Math]::Truncate($Timecount)
                    $Minute      = ($ExecutionStartTime - $Hour) * 60
                    $Second      = [int](($Minute - ([Math]::Truncate($Minute))) * 60)
                    $Minute      = [Math]::Truncate($Minute)
                    $Timecount   = [datetime]::Parse("$Hour`:$Minute`:$Second")
    
                    $script:ProgressBarMainLabel.text = "Status:
Iterating Through Endpoints
Time Updates As Endpoints Respond
Elasped Time:  $($Timecount -replace '-','')"
                 
                    & $PsExecPath "\\$TargetComputer" -AcceptEULA -NoBanner powershell -command "Invoke-Command -ScriptBlock {Get-EventLog -LogName Application -InstanceId 1000 | Select-Object -First 1000 | ConvertTo-Csv -NoType" | ConvertFrom-Csv | Export-CSV "$($script:CollectionSavedDirectoryTextBox.text)\$CollectionName\$CollectionName -- $TargetComputer.csv" -NoTypeInformation
                    $script:ProgressBarFormProgressBar.Value += 1
                }
            }
        #}
    }

    if ((Test-Path  "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)") -and -not $AutoChartProtocolSMBRadioButton.checked){
        # Removes the individual CSV files
        Remove-Item "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\*" -Force
    }
    else {
        New-Item -ItemType Directory "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)"
    }

    # Removes Compiled CSV file
    Remove-Item "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv" -Force
    
    if (-not $AutoChartProtocolSMBRadioButton.checked) {
        Monitor-Jobs -CollectionName $CollectionName
    }

    if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) { 
        Start-Sleep -Seconds 3
        Generate-NewRollingPassword 
    }
    
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\*.csv" `
                    -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

    Compile-XmlFiles -LocationOfXmlsToCompile   "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\*.xml" `
                    -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).xml"                

    Start-Sleep -Seconds 1
            
    $script:AutoChartDataSourceCsv     = Import-Csv "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"
    $script:AutoChartDataSourceXmlPath = "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).xml"

    $script:AutoChartDataSourceCsvFileName = "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

    $this.close()

}
