$CollectionName = "Alternate Data Streams"
$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

$DirectoriesToSearch = $FileSearchAlternateDataStreamDirectoryRichTextbox.Lines
$MaximumDepth        = $FileSearchAlternateDataStreamMaxDepthTextbox.text



Update-FormProgress "Search-AlternateDataStream"
function Search-AlternateDataStream {
    param(
        $DirectoriesToSearch,
        $MaximumDepth
    )
    if ([int]$MaximumDepth -gt 0) {
        #Invoke-Expression $GetChildItemDepth
        Function Get-ChildItemDepth {
            Param(
                [String[]]$Path     = $PWD,
                [String]$Filter     = "*",
                [Byte]$Depth        = 255,
                [Byte]$CurrentDepth = 0
            )
            $CurrentDepth++
            Get-ChildItem $Path -Force | ForEach-Object {
                $_ | Where-Object { $_.Name -Like $Filter }
                If ($_.PsIsContainer) {
                    If ($CurrentDepth -le $Depth) {
                        # Callback to this function
                        Get-ChildItemDepth -Path $_.FullName -Filter $Filter -Depth $Depth -CurrentDepth $CurrentDepth
                    }
                }
            }
        }

        # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
        #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth

        $AllFiles = Get-ChildItemDepth -Path $DirectoriesToSearch -Depth $MaximumDepth
    }
    else {
        $AllFiles = Get-ChildItem -Path $DirectoriesToSearch -Force -ErrorAction SilentlyContinue
    }

    $AdsFound = $AllFiles | ForEach-Object { Get-Item $_.FullName -Force -Stream * -ErrorAction SilentlyContinue } | Where-Object stream -ne ':$DATA'
    foreach ($Ads in $AdsFound) {
        $AdsData = Get-Content -Path "$($Ads.FileName)" -Stream "$($Ads.Stream)"
        $Ads | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $($Env:ComputerName)
        #too much... $Ads | Add-Member -MemberType NoteProperty -Name StreamData -Value $AdsData
        $Ads | Add-Member -MemberType NoteProperty -Name StreamDataSample -Value $(($AdsData | Out-String)[0..1000] -join "")
        if     (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=0')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 0] Local Machine Zone: The most trusted zone for content that exists on the local computer." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=1')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 1] Local Intranet Zone: For content located on an organizationâ€™s intranet." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=2')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 2] Trusted Sites Zone: For content located on Web sites that are considered more reputable or trustworthy than other sites on the Internet." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=3')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 3] Internet Zone: For Web sites on the Internet that do not belong to another zone." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=4')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 4] Restricted Sites Zone: For Web sites that contain potentially-unsafe content." }
        else {$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "N/A"}
        $Ads | Add-Member -MemberType NoteProperty -Name FileSize -Value $(
            if     ($Ads.Length -gt 1000000000) { "$([Math]::Round($($Ads.Length / 1gb),2)) GB" }
            elseif ($Ads.Length -gt 1000000)    { "$([Math]::Round($($Ads.Length / 1mb),2)) MB" }
            elseif ($Ads.Length -gt 1000)       { "$([Math]::Round($($Ads.Length / 1kb),2)) KB" }
            elseif ($Ads.Length -le 1000)       { "$($Ads.Length) Bytes" }
        )
    }
    $AdsFound
}


function MonitorJobScriptBlock {
    param(
        $ExecutionStartTime,
        $CollectionName,
        $DirectoriesToSearch,
        $MaximumDepth
    )
    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStamp `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Write-LogEntry -TargetComputer $TargetComputer  -LogFile $PewLogFile -Message $CollectionName

        $InvokeCommandSplat = @{
            ScriptBlock  = ${function:Search-AlternateDataStream}
            ArgumentList = @($DirectoriesToSearch,$MaximumDepth)
            ComputerName = $TargetComputer
            AsJob        = $True
            JobName      = "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
        }

        if ( $script:ComputerListProvideCredentialsCheckBox.Checked ) {
            if (!$script:Credential) { Set-NewCredential }
            $InvokeCommandSplat += @{Credential = $script:Credential}
        }

        Invoke-Command @InvokeCommandSplat | Select-Object PSComputerName, *
    }
}
Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$DirectoriesToSearch,$MaximumDepth)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString = ''
foreach ($item in $DirectoriesToSearch) {$SearchString += "$item`n" }

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
Recursive Depth:
===========================================================================
$MaximumDepth

===========================================================================
Directories To Search:
===========================================================================
$($SearchString.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$DirectoriesToSearch,$MaximumDepth) -SmithFlag 'RetrieveADS' -InputValues $InputValues
}

elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName -SaveProperties @"
@('PSComputerName', 'FileName', 'Stream', 'StreamDataSample', 'ZoneId' , 'Length')
"@
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


$FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.BackColor = 'LightGreen'

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

Update-EndpointNotes










# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvnDpZEGdQXXqH5L7aNFt76xJ
# eSigggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/84acThQZL3G5e4i7XhfsyHpdREwDQYJKoZI
# hvcNAQEBBQAEggEAYJcwnld5ne87N/y6OROCW0xcFJMIy5c0cC5HvoDB9SXICHdB
# ad4pnQHAD8o7G+T+2MCYbGCjOpEHbHslvRsvLNVdwGtDObyqvXjMiaVf27SjZbne
# 3v0CL3vBUmEWKqBK88snEjSpj3fm+SqeqkdYwmJjfyxFDKqdwVjBkEnL4PsS3kwP
# l4H1c7S1XfT/TmSNQ/2fgYmPrZ+WAXWRpaqXm5y+B4rbZA9SRnFguKklAIf97Ohk
# /TwvIvLGYSO1aXkJTEMfuVoC6SbTCc+YVW8AqxwvAJeLeywDp5fD/9ZZS8cA/kmX
# 0JRJa+F5OdL6ZwWUw9NKRxz35TGJaxHL8fKQ7Q==
# SIG # End signature block
