function IndividualQuery-ProcessSysmon {
    param(
        [switch]$ProcessSysmonSearchRuleNameCheckbox,
        [switch]$ProcessSysmonSearchUserAccountIdCheckbox,
        [switch]$ProcessSysmonSearchHashesCheckbox,
        [switch]$ProcessSysmonSearchFilePathCheckbox,
        [switch]$ProcessSysmonSearchCommandlineCheckbox,
        [switch]$ProcessSysmonSearchParentFilePathCheckbox,
        [switch]$ProcessSysmonSearchParentCommandlineCheckbox,
        [switch]$ProcessSysmonSearchCompanyProductCheckbox
    )

    function MonitorJobScriptBlock {
        param(
            $CollectionName,
            $ProcessSysmonRegex,
            $ProcessSysmonSearchRuleName,
            $ProcessSysmonSearchUserAccountId,
            $ProcessSysmonSearchHashes,
            $ProcessSysmonSearchFilePath,
            $ProcessSysmonSearchCommandline,
            $ProcessSysmonSearchParentFilePath,
            $ProcessSysmonSearchParentCommandline,
            $ProcessSysmonSearchCompanyProduct
        )

        foreach ($TargetComputer in $script:ComputerList) {
            Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                    -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                    -TargetComputer $TargetComputer
            Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


            $ProcessSysmonScriptBlock = {
                    param(
                        $CollectionName,
                        $ProcessSysmonRegex,
                        $ProcessSysmonSearchRuleName,
                        $ProcessSysmonSearchUserAccountId,
                        $ProcessSysmonSearchHashes,
                        $ProcessSysmonSearchFilePath,
                        $ProcessSysmonSearchCommandline,
                        $ProcessSysmonSearchParentFilePath,
                        $ProcessSysmonSearchParentCommandline,
                        $ProcessSysmonSearchCompanyProduct
                    )
                
                    $SysmonProcessCreationEventLogs = Get-WinEvent -FilterHashtable @{
                        LogName = 'Microsoft-Windows-Sysmon/Operational'
                        Id      = 1
                    }

                    $SysmonProcessCreationEventLogsFormatted = @()
                    Foreach ($event in ($SysmonProcessCreationEventLogs)) {
                        $Message = $event | Select-Object -Expand Message
                        $SysmonProcessCreationEventLogsFormatted += [PSCustomObject]@{
                            'Event'             = ($Message -split "`r`n")[0].TrimEnd(':')
                            'RuleName'          = (($Message -split "`r`n")[1] -split ": ")[1]
                            'UtcTime'           = [datetime](($Message -split "`r`n")[2] -split ": ")[1]
                            'ProcessGuid'       = (($Message -split "`r`n")[3] -split ": ")[1].Replace('{','').Replace('}','')
                            'ProcessId'         = (($Message -split "`r`n")[4] -split ": ")[1]
                            'Image'             = (($Message -split "`r`n")[5] -split ": ")[1]
                            'FileVersion'       = (($Message -split "`r`n")[6] -split ": ")[1]
                            'Description'       = (($Message -split "`r`n")[7] -split ": ")[1]
                            'Product'           = (($Message -split "`r`n")[8] -split ": ")[1]
                            'Company'           = (($Message -split "`r`n")[9] -split ": ")[1]
                            'OriginalFileName'  = (($Message -split "`r`n")[10] -split ": ")[1]
                            'CommandLine'       = (($Message -split "`r`n")[11] -split ": ")[1]
                            'CurrentDirectory'  = (($Message -split "`r`n")[12] -split ": ")[1]
                            'User'              = (($Message -split "`r`n")[13] -split ": ")[1]
                            'LogonGuid'         = (($Message -split "`r`n")[14] -split ": ")[1]
                            'LogonId'           = (($Message -split "`r`n")[15] -split ": ")[1]
                            'TerminalSessionId' = (($Message -split "`r`n")[16] -split ": ")[1]
                            'IntegrityLevel'    = (($Message -split "`r`n")[17] -split ": ")[1]
                            'SHA1Hash'          = (($Message -split "`r`n")[18] -split ": ")[1].split(',')[0].split('=')[1]
                            'MD5Hash'           = (($Message -split "`r`n")[18] -split ": ")[1].split(',')[1].split('=')[1]
                            'SHA256Hash'        = (($Message -split "`r`n")[18] -split ": ")[1].split(',')[2].split('=')[1]
                            'IMPHash'           = (($Message -split "`r`n")[18] -split ": ")[1].split(',')[3].split('=')[1]
                            'Hashes'            = (($Message -split "`r`n")[18] -split ": ")[1]
                            'ParentProcessGuid' = (($Message -split "`r`n")[19] -split ": ")[1]
                            'ParentProcessId'   = (($Message -split "`r`n")[20] -split ": ")[1]
                            'ParentImage'       = (($Message -split "`r`n")[21] -split ": ")[1]
                            'ParentCommandLine' = (($Message -split "`r`n")[22] -split ": ")[1]
                            'ThreadId'          = $event.ThreadId
                            'ComputerName'      = $event.MachineName
                            'MachineName'       = $event.MachineName
                            'UserId'            = $event.UserId
                            'TimeCreated'       = $event.TimeCreated
                        }
                    }
                
                    $ProcessSysmonEventFound = @()
                
                    foreach ($SysmonNetEvent in $SysmonProcessCreationEventLogsFormatted) {
                        if ($ProcessSysmonRegex -eq $true) {
                            if ($ProcessSysmonSearchRuleName)          { foreach ($Name in $ProcessSysmonSearchRuleName) { if (($SysmonNetEvent.RuleName -match $Name) -and ($Name -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchUserAccountId)     { foreach ($User in $ProcessSysmonSearchUserAccountId) { if (($SysmonNetEvent.User -match $User -or $SysmonNetEvent.UserId -match $User) -and ($User -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchHashes)            { foreach ($Hash in $ProcessSysmonSearchHashes) { if (($SysmonNetEvent.MD5Hash -match $Hash -or $SysmonNetEvent.SHA1Hash -match $Hash -or $SysmonNetEvent.SHA256Hash -match $Hash -or $SysmonNetEvent.IMPHash -match $Hash) -and ($Hash -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchFilePath)          { foreach ($Path in $ProcessSysmonSearchFilePath) { if (($SysmonNetEvent.Image -match $Path) -and ($Path -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchCommandline)       { foreach ($CommandLine in $ProcessSysmonSearchCommandline) { if (($SysmonNetEvent.CommandLine -match $CommandLine) -and ($CommandLine -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchParentFilePath)    { foreach ($Path in $ProcessSysmonSearchParentFilePath) { if (($SysmonNetEvent.ParentImage -match $Path) -and ($Path -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchParentCommandline) { foreach ($CommandLine in $ProcessSysmonSearchParentCommandline) { if (($SysmonNetEvent.ParentCommandLine -match $CommandLine) -and ($CommandLine -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchCompanyProduct)    { foreach ($Item in $ProcessSysmonSearchCompanyProduct) { if (($SysmonNetEvent.Company -match $Item -or $SysmonNetEvent.Product -match $Item) -and ($Item -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                        }
                        elseif ($ProcessSysmonRegex -eq $false) {
                            if ($ProcessSysmonSearchRuleName)          { foreach ($Name in $ProcessSysmonSearchRuleName) { if (($SysmonNetEvent.RuleName -eq $Name) -and ($Name -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchUserAccountId)     { foreach ($User in $ProcessSysmonSearchUserAccountId) { if (($SysmonNetEvent.User -eq $User -or $SysmonNetEvent.UserId -eq $User) -and ($User -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchHashes)            { foreach ($Hash in $ProcessSysmonSearchHashes) { if (($SysmonNetEvent.MD5Hash -eq $Hash -or $SysmonNetEvent.SHA1Hash -eq $Hash -or $SysmonNetEvent.SHA256Hash -eq $Hash -or $SysmonNetEvent.IMPHash -eq $Hash) -and ($Hash -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchFilePath)          { foreach ($Path in $ProcessSysmonSearchFilePath) { if (($SysmonNetEvent.Image -eq $Path) -and ($Path -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchCommandline)       { foreach ($CommandLine in $ProcessSysmonSearchCommandline) { if (($SysmonNetEvent.CommandLine -eq $CommandLine) -and ($CommandLine -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchParentFilePath)    { foreach ($Path in $ProcessSysmonSearchParentFilePath) { if (($SysmonNetEvent.ParentImage -eq $Path) -and ($Path -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchParentCommandline) { foreach ($CommandLine in $ProcessSysmonSearchParentCommandline) { if (($SysmonNetEvent.ParentCommandLine -eq $CommandLine) -and ($CommandLine -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                            if ($ProcessSysmonSearchCompanyProduct)    { foreach ($Item in $ProcessSysmonSearchCompanyProduct) { if (($SysmonNetEvent.Company -eq $Item -or $SysmonNetEvent.Product -eq $Item) -and ($Item -ne '')) { $ProcessSysmonEventFound += $SysmonNetEvent } } }
                        }
                    }
                    return $ProcessSysmonEventFound | Select-Object -Property ComputerName, Event, Description, TimeCreated, UtcTime, ProcessId, CommandLine, ParentProcessId, ParentCommandLine, User, UserId, RuleName, SHA1Hash, MD5Hash, SHA256Hash, IMPHash, Company, Product, Image, ParentImage, LogonId, FileVersion, OriginalFileName, MachineName, CurrentDirectory, IntegrityLevel, TerminalSessionId, ThreadId, LogonGuid, ProcessGuid, ParentProcessGuid
                    #, Hashes
            }
            

            $InvokeCommandSplat = @{
                ScriptBlock  = $ProcessSysmonScriptBlock
                ArgumentList = @(
                    $CollectionName,
                    $ProcessSysmonRegex,
                    $ProcessSysmonSearchRuleName,
                    $ProcessSysmonSearchUserAccountId,
                    $ProcessSysmonSearchHashes,
                    $ProcessSysmonSearchFilePath,
                    $ProcessSysmonSearchCommandline,
                    $ProcessSysmonSearchParentFilePath,
                    $ProcessSysmonSearchParentCommandline,
                    $ProcessSysmonSearchCompanyProduct
            )
                ComputerName = $TargetComputer
                AsJob        = $true
                JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
            }
            

            if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Set-NewCredential }
                $InvokeCommandSplat += @{Credential = $script:Credential}
            }
            Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
        }
    }


    if     ($ProcessSysmonSearchRuleNameCheckbox)          {$CollectionName = "Process (Sysmon) Rule Name"}
    elseif ($ProcessSysmonSearchUserAccountIdCheckbox)     {$CollectionName = "Process (Sysmon) User Account, Id"}
    elseif ($ProcessSysmonSearchHashesCheckbox)            {$CollectionName = "Process (Sysmon) Hash"}
    elseif ($ProcessSysmonSearchFilePathCheckbox)          {$CollectionName = "Process (Sysmon) File Path"}
    elseif ($ProcessSysmonSearchCommandlineCheckbox)       {$CollectionName = "Process (Sysmon) Command Line"}
    elseif ($ProcessSysmonSearchParentFilePathCheckbox)    {$CollectionName = "Process (Sysmon) Parent File Path"}
    elseif ($ProcessSysmonSearchParentCommandlineCheckbox) {$CollectionName = "Process (Sysmon) Parent Command Line"}
    elseif ($ProcessSysmonSearchCompanyProductCheckbox)    {$CollectionName = "Process (Sysmon) Company Product"}


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
Regular Expression:
===========================================================================
$($ProcessSysmonRegexCheckbox.checked)

===========================================================================
Search Terms:
===========================================================================

"@


    if   ($ProcessSysmonRegexCheckbox.checked) {$ProcessSysmonRegex = $True}
    else {$ProcessSysmonRegex = $False}


    if ($ProcessSysmonSearchRuleNameCheckbox) {
        $ProcessSysmonSearchRuleName = ($ProcessSysmonSearchRuleNameRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchRuleName -join "`n")
    }
    else {$ProcessSysmonSearchRuleName = $null}


    if ($ProcessSysmonSearchUserAccountIdCheckbox) {
        $ProcessSysmonSearchUserAccountId = $ProcessSysmonSearchUserAccountIdRichTextbox.Lines
        $InputValues += $($ProcessSysmonSearchUserAccountId -join "`n")
    }
    else {$ProcessSysmonSearchUserAccountId = $null}


    if ($ProcessSysmonSearchHashesCheckbox) {
        $ProcessSysmonSearchHashes = ($ProcessSysmonSearchHashesRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchHashes -join "`n")
    }
    else {$ProcessSysmonSearchHashes = $null}


    if ($ProcessSysmonSearchFilePathCheckbox) {
        $ProcessSysmonSearchFilePath = ($ProcessSysmonSearchFilePathRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchFilePath -join "`n")
    }
    else {$ProcessSysmonSearchFilePath = $null}


    if ($ProcessSysmonSearchCommandlineCheckbox) {
        $ProcessSysmonSearchCommandline = ($ProcessSysmonSearchCommandlineRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchCommandline -join "`n")
    }
    else {$ProcessSysmonSearchCommandline = $null}


    if ($ProcessSysmonSearchParentFilePathCheckbox) {
        $ProcessSysmonSearchParentFilePath = ($ProcessSysmonSearchParentFilePathRichTextbox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchParentFilePath -join "`n")
    }
    else {$ProcessSysmonSearchParentFilePath = $null}

    
    if ($ProcessSysmonSearchParentCommandlineCheckbox) {
        $ProcessSysmonSearchParentCommandline = ($ProcessSysmonSearchParentCommandlineRichTextBox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchParentCommandline -join "`n")
    }
    else {$ProcessSysmonSearchParentCommandline = $null}

    
    if ($ProcessSysmonSearchCompanyProductCheckbox) {
        $ProcessSysmonSearchCompanyProduct = ($ProcessSysmonSearchCompanyProductRichTextBox.Text).split("`r`n")
        $InputValues += $($ProcessSysmonSearchCompanyProduct -join "`n")
    }
    else {$ProcessSysmonSearchCompanyProduct = $null}


    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    $InvokeCommandSplat = @{
        ScriptBlock  = ${function:MonitorJobScriptBlock}
        ArgumentList = @($CollectionName,$ProcessSysmonRegex,$ProcessSysmonSearchRuleName,$ProcessSysmonSearchUserAccountId,$ProcessSysmonSearchHashes,$ProcessSysmonSearchFilePath,$ProcessSysmonSearchCommandline,$ProcessSysmonSearchParentFilePath,$ProcessSysmonSearchParentCommandline,$ProcessSysmonSearchCompanyProduct)
    }
    Invoke-Command @InvokeCommandSplat
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($CollectionName,$ProcessSysmonRegex,$ProcessSysmonSearchRuleName,$ProcessSysmonSearchUserAccountId,$ProcessSysmonSearchHashes,$ProcessSysmonSearchFilePath,$ProcessSysmonSearchCommandline,$ProcessSysmonSearchParentFilePath,$ProcessSysmonSearchParentCommandline,$ProcessSysmonSearchCompanyProduct) -InputValues $InputValues


    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


    Update-EndpointNotes
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUraliqcV4OT6Cf4tHuREt9WHc
# sq2gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU7vVBPylQRj/21kd4s4t2YmTNJr4wDQYJKoZI
# hvcNAQEBBQAEggEAQ2rwZWSbx6/fSr5n78m2SiHkgwF8CoLJXLpoF+6uzlmX98sa
# 5H98wqCU+8Uz+teH71Mo0uolWqimzmtYOxgjGub66rHzO/qX+r+BGwM+SMp0GPuq
# /NRRX7Luf7Abgxzh/A7f774XxSE67hJJ7oPLdwyoSdmWAECDl6zEL64i8KDKA8J/
# Tgs/sjKBru/2hV7gJaRYb+2RdF13RrhQ7vEJYICna62VVBCSxVIb/cvuVlDuSuml
# fLtEPhzkgr9ezjHdt8iwA1e/rp7My/kZdF3Nhhis+pY1CXnSxP/SfxQ+kFcNiPgk
# DHlKwft3vRoJPnvzuA/m7qjVceztWdRs0JcVgg==
# SIG # End signature block
