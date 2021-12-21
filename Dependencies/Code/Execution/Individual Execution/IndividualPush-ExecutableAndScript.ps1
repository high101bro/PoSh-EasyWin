$ExecutionStartTime = Get-Date
$CollectionName = "Executable and Script"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$TargetFolder                 = [string]($script:ExeScriptDestinationDirectoryTextBox.text).substring(3).trim('\')
$ExeScriptSelectDirOrFilePath = $script:ExeScriptSelectDirOrFilePath
$ExeScriptSelectScriptPath    = $script:ExeScriptSelectScriptPath
$AdminShare                   = 'c$'


$ExeScriptSelectScript = Get-Content $ExeScriptSelectScriptPath -Raw

foreach ($TargetComputer in $script:ComputerList) {
    if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Set-NewCredential }

        Start-Job -ScriptBlock {
            param($ExeScriptSelectScript,$ExeScriptScriptOnlyCheckbox,$ExeScriptSelectDirRadioButton,$ExeScriptSelectFileRadioButton,$ExeScriptSelectDirOrFilePath,$TargetComputer,$AdminShare,$TargetFolder,$script:Credential)
    
            # In case a $TargetComputer is an IP Address and not a Hostname
            $TargetComputerDrive = $TargetComputer -replace '.','-'

            New-PSDrive -Name $TargetComputerDrive `
            -PSProvider FileSystem `
            -Root "\\$TargetComputer\$AdminShare\$TargetFolder" `
            -Credential $script:Credential | Out-Null

            if ($ExeScriptScriptOnlyCheckbox.checked -eq $false) {
                if ($ExeScriptSelectDirRadioButton.checked -eq $true) {
                    Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "$($TargetComputerDrive):" -Recurse -Force | Out-Null
                }
                elseif ($ExeScriptSelectFileRadioButton.checked -eq $true) {
                    Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "$($TargetComputerDrive):" -Force | Out-Null
                }
            }
            Start-Sleep 1 | Out-Null
        
            Invoke-Command -ScriptBlock {
                param($ExeScriptSelectScript)
                Invoke-Expression -Command $ExeScriptSelectScript
            } `
            -ArgumentList @($ExeScriptSelectScript) `
            -ComputerName $TargetComputer `
            -Credential $script:Credential

            Remove-PSDrive -Name $TargetComputerDrive | Out-Null

        } `
        -ArgumentList @($ExeScriptSelectScript,$ExeScriptScriptOnlyCheckbox,$ExeScriptSelectDirRadioButton,$ExeScriptSelectFileRadioButton,$ExeScriptSelectDirOrFilePath,$TargetComputer,$AdminShare,$TargetFolder,$script:Credential) `
        -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:ExecutableAndScript} -ArgumentList @(`$ExeScriptSelectScript,`$ExeScriptScriptOnlyCheckbox,`$ExeScriptSelectDirRadioButton,`$ExeScriptSelectFileRadioButton,`$ExeScriptSelectDirOrFilePath,`$TargetComputer,`$AdminShare,`$TargetFolder) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
    }
    else {
        Start-Job -ScriptBlock {
            param($ExeScriptSelectScript,$ExeScriptScriptOnlyCheckbox,$ExeScriptSelectDirRadioButton,$ExeScriptSelectFileRadioButton,$ExeScriptSelectDirOrFilePath,$TargetComputer,$AdminShare,$TargetFolder)

            # In case a $TargetComputer is an IP Address and not a Hostname
            $TargetComputerDrive = $TargetComputer -replace '.','-'

            New-PSDrive -Name $TargetComputerDrive `
            -PSProvider FileSystem `
            -Root "\\$TargetComputer\$AdminShare\$TargetFolder" | Out-Null

            if ($ExeScriptScriptOnlyCheckbox.checked -eq $false) {
                if ($ExeScriptSelectDirRadioButton.checked -eq $true) {
                    Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "$($TargetComputerDrive):" -Recurse -Force | Out-Null
                }
                elseif ($ExeScriptSelectFileRadioButton.checked -eq $true) {
                    Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "$($TargetComputerDrive):" -Force | Out-Null
                }
            }
            Start-Sleep 1 | Out-Null
        
            Invoke-Command -ScriptBlock {
                param($ExeScriptSelectScript)
                Invoke-Expression -Command $ExeScriptSelectScript
            } `
            -ArgumentList @($ExeScriptSelectScript) `
            -ComputerName $TargetComputer

            Remove-PSDrive -Name $TargetComputerDrive | Out-Null
        } `
        -ArgumentList @($ExeScriptSelectScript,$ExeScriptScriptOnlyCheckbox,$ExeScriptSelectDirRadioButton,$ExeScriptSelectFileRadioButton,$ExeScriptSelectDirOrFilePath,$TargetComputer,$AdminShare,$TargetFolder) `
        -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:ExecutableAndScript} -ArgumentList @(`$ExeScriptSelectScript,`$ExeScriptScriptOnlyCheckbox,`$ExeScriptSelectDirRadioButton,`$ExeScriptSelectFileRadioButton,`$ExeScriptSelectDirOrFilePath,`$TargetComputer,`$AdminShare,`$TargetFolder) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
    }
}

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

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
Target Folder:
===========================================================================
$TargetFolder

===========================================================================
Directory / File Path
===========================================================================
$ExeScriptSelectDirOrFilePath

===========================================================================
Script Path:
===========================================================================
$ExeScriptSelectScriptPath

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -InputValues $InputValues
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


<# DEPRECATED
foreach ($TargetComputer in $script:ComputerList) {
    if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Set-NewCredential }
        $Session = New-PSSession -ComputerName $TargetComputer -Name $TargetComputer -Credential $script:Credential
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] New-PSSession -ComputerName $TargetComputer -Credential `$script:Credential"
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Creating Session with $TargetComputer")
        }
    else {
        $Session = New-PSSession -ComputerName $TargetComputer -Name $TargetComputer
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Creating Session with $TargetComputer"
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Creating Session with $TargetComputer")
    }


    if ($ExeScriptScriptOnlyCheckbox.checked -eq $false) {
        if ($ExeScriptSelectDirRadioButton.checked){
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Copying the directory '$($ExeScriptSelectExecutableTextBox.Text)' and its contents to:"
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copying the directory '$($ExeScriptSelectExecutableTextBox.Text)' and its contents to:")
            $PoShEasyWin.Refresh()
        }
        elseif ($ExeScriptSelectFileRadioButton.checked){
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Copying the file '$($ExeScriptSelectExecutableTextBox.Text)' to:"
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copying the file '$($ExeScriptSelectExecutableTextBox.Text)' to:")
            $PoShEasyWin.Refresh()
        }


        try {
            if ($ExeScriptSelectDirRadioButton.checked -eq $true) {
                Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Recurse -Force -ErrorAction Stop

                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Recurse -Force -ErrorAction Stop"
            }
            elseif ($ExeScriptSelectFileRadioButton.checked -eq $true) {
                Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop

                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $ExeScriptSelectDirOrFilePath -Destination "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop"
            }
            $PoShEasyWin.Refresh()

            $script:ProgressBarEndpointsProgressBar.Value += 1
            $PoShEasyWin.Refresh()
        }
        catch {
            $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy Error:  $($_.Exception)")
            Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
            $PoShEasyWin.Refresh()
            break
        }
    }
    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Executing the '$($ExeScriptSelectScriptTextBox.text)' script on:")
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Executing the '$($ExeScriptSelectScriptTextBox.text)' script on:"
    $PoShEasyWin.Refresh()

    $script:ProgressBarEndpointsProgressBar.Value = 0

    try {
        try {
            Invoke-Command -FilePath $ExeScriptSelectScriptPath -Session $Session
        }
        catch{}
        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Invoke-Command -FilePath $ExeScriptSelectScriptPath -Session $Session"
        $PoShEasyWin.Refresh()
    }
    catch {
        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Execution Error:  $($_.Exception)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Execution Error: $($_.Exception)"
        $PoShEasyWin.Refresh()
        break
    }
    $script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count

    Get-PSSession -Name $TargetComputer | Remove-PSSession
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Removing Session with $TargetComputer"
    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Removing Session with $TargetComputer")
}
DEPRECATED #>
$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$PoShEasyWin.Refresh()
Start-Sleep -match 500

Update-EndpointNotes



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXziUZNU6UPQ945PhJC569emo
# 88KgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUvHOdpUSl66A/ChPNlFJnXdH1FLkwDQYJKoZI
# hvcNAQEBBQAEggEABrTGL6O3RCja7nw+AFfs+C+r5iF/x/LN0rng7pAUnqvz/l5G
# VYfaC8mRnFuwE9U54PmrcK+diyn8MJmV4+xuU71QYSoBuDiczoSIu3yVB5SCXU+N
# rfDVN/E7glP330QNYheNAaInwMWzodnENRjC3iKEw5HhcE2F7M9S5OuB8EDiJZGk
# RDnOMt212IUvpcUC8VcjX+LvXIj6d73vq0KtwtrksTzNjzU5ZTf+N7c4K668r9KL
# RcE1R31umZsCtHz0K+0DBjUrgZ8NftB84hlvCqink36RAthE7ZHUawfQoo7BBD5O
# jkd9PJWoiZbEs4p/tzvtttY4ksa7ze9ThVtnWw==
# SIG # End signature block
