
function Update-AutoChartsActiveDirectoryUserAccounts {
    param($ServerToQuery)
    $script:ProgressBarFormProgressBar.Value   = 0
    $script:ProgressBarFormProgressBar.Maximum = $script:ComputerList.count

    $script:ProgressBarMessageLabel.text = "Note: Collected results are also saved locally as CSV and XML files."

    #$PullNewDataScriptPath = "$QueryCommandsAndScripts\Scripts-Host\Get-ActiveDirectoryUserAccountsEnriched.ps1"

    $ExecutionStartTime = Get-Date

        <#
        if ($AutoChartPullNewDataEnrichedCheckBox.checked) {
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                if ($AutoChartProtocolWinRMRadioButton.checked) {
                    $CollectionName = 'Get-ActiveDirectoryUserAccountsEnriched - (WinRM) Script'

                    Invoke-Command -FilePath $PullNewDataScriptPath `
                    -ComputerName $ServerToQuery `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($ServerToQuery)" `
                    -Credential $script:Credential
                }
            }
            else {
                if ($AutoChartProtocolWinRMRadioButton.checked) {
                    $CollectionName = 'Get-ActiveDirectoryUserAccountsEnriched - (WinRM) Script'

                    Invoke-Command -FilePath $PullNewDataScriptPath `
                    -ComputerName $ServerToQuery `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($ServerToQuery)"
                }
            }
        }
        else {
        #>
            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                if ($AutoChartProtocolWinRMRadioButton.checked) {
                    $CollectionName = 'Active Directory User Accounts - (WinRM)'

                    Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties Created, Modified, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, BadLogonCount, AccountExpirationDate, Enabled, LockedOut, SmartcardLogonRequired, PasswordNeverExpires, PasswordNotRequired } `
                    -ComputerName $ServerToQuery `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($ServerToQuery)" `
                    -Credential $script:Credential
                }
                elseif ($AutoChartProtocolRPCRadioButton.checked) {
                    $CollectionName = 'Active Directory User Accounts - (RPC)'

                    Start-Job -ScriptBlock {
                        param($ServerToQuery,$script:Credential)
                        Get-WmiObject -Class Win32_UserAccount -ComputerName $ServerToQuery -Credential $script:Credential | Select-Object *
                    } `
                    -Name "PoSh-EasyWin: $($CollectionName) -- $($ServerToQuery)" `
                    -ArgumentList @($ServerToQuery,$script:Credential)
                }
                elseif ($AutoChartProtocolSMBRadioButton.checked) {
                    $CollectionName = 'Active Directory User Accounts - (SMB)'

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

                    & $PsExecPath "\\$ServerToQuery" -AcceptEULA -NoBanner -u $UserName -p $Password powershell -command "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties Created, Modified, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, BadLogonCount, AccountExpirationDate, Enabled, LockedOut, SmartcardLogonRequired, PasswordNeverExpires, PasswordNotRequired } | ConvertTo-Csv -NoType" | ConvertFrom-Csv | Export-CSV "$($script:CollectionSavedDirectoryTextBox.text)\Results By Endpoints\$CollectionName\$CollectionName -- $ServerToQuery.csv" -NoTypeInformation
                    $script:ProgressBarFormProgressBar.Value += 1
                }
            }
            else {
                if ($AutoChartProtocolWinRMRadioButton.checked) {
                    $CollectionName = 'Active Directory User Accounts - (WinRM)'

                    Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties Created, Modified, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, BadLogonCount, AccountExpirationDate, Enabled, LockedOut, SmartcardLogonRequired, PasswordNeverExpires, PasswordNotRequired } `
                    -ComputerName $ServerToQuery `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($ServerToQuery)"
                }
                elseif ($AutoChartProtocolRPCRadioButton.checked) {
                    $CollectionName = 'Active Directory User Accounts - (RPC)'

                    Start-Job -ScriptBlock {
                        param($ServerToQuery)
                        Get-WmiObject -Class Win32_UserAccount -ComputerName $ServerToQuery | Select-Object *
                    } `
                    -Name "PoSh-EasyWin: $($CollectionName) -- $($ServerToQuery)" `
                    -ArgumentList @($ServerToQuery)
                }
                elseif ($AutoChartProtocolSMBRadioButton.checked) {
                    $CollectionName = 'Active Directory User Accounts - (SMB)'

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

                    & $PsExecPath "\\$ServerToQuery" -AcceptEULA -NoBanner powershell -command "Invoke-Command -ScriptBlock { Get-ADUser -Filter * -Properties Created, Modified, LastLogonDate, LastBadPasswordAttempt, PasswordLastSet, BadLogonCount, AccountExpirationDate, Enabled, LockedOut, SmartcardLogonRequired, PasswordNeverExpires, PasswordNotRequired } | ConvertTo-Csv -NoType" | ConvertFrom-Csv | Export-CSV "$($script:CollectionSavedDirectoryTextBox.text)\$CollectionName\$CollectionName -- $ServerToQuery.csv" -NoTypeInformation
                    $script:ProgressBarFormProgressBar.Value += 1
                }
            }
        #}

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

    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
        Start-Sleep -Seconds 3
        Generate-NewRollingPassword
    }

    Compile-CsvFiles -LocationOfCSVsToCompile   "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\*.csv" `
                    -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

    Compile-XmlFiles -LocationOfXmlsToCompile   "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\*.xml" `
                    -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).xml"

    $script:AutoChartDataSourceCsv     = Import-Csv "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"
    $script:AutoChartDataSourceXmlPath = "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).xml"

    $script:AutoChartDataSourceCsvFileName = "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

    $this.close()
}


