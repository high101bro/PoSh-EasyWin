$script:Section3MonitorJobsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Monitor Jobs  "
    Name = "Monitor Jobs Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    AutoScroll = $true
    UseVisualStyleBackColor = $True
    ImageIndex = 2
}
$InformationTabControl.Controls.Add($script:Section3MonitorJobsTab)

$script:AllJobs = $null

# This list will contain all the job ids executed by PoSh-EasyWin
# It's populated by the Monitor-Jobs function
# Used to track which jobs were previously done to separate them from the current onces
$script:PastJobsIDList = @()


$script:Section3MonitorJobsGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Text      = "Monitor Jobs Options"
    Left      = 0
    Top       = 0
    Width     = $FormScale * 745
    Height    = $FormScale * 42
    Font      = New-Object System.Drawing.Font($Font,$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
$script:Section3MonitorJobsTab.Controls.Add($script:Section3MonitorJobsGroupBox)


# This needs to be below: $script:Section3MonitorJobsGroupBox
$script:PreviousJobFormItemsList = @()
$script:MonitorJobsLeftPosition  = $FormScale * 5
$script:MonitorJobsTopPosition   = $script:Section3MonitorJobsGroupBox.Top + $script:Section3MonitorJobsGroupBox.Height


$script:Section3MonitorJobsResizeButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = "^ Maximize Tab"
    Left      = $FormScale * 5
    Top       = $FormScale * 15
    Width     = $FormScale * 116
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font($Font,$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
    Add_Click = {
        if ($this.text -eq     "^ Maximize Tab") { Resize-MonitorJobsTab -Maximize }
        elseif ($this.text -eq "v Minimize Tab") { Resize-MonitorJobsTab -Minimize }
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobsResizeButton)
Apply-CommonButtonSettings -Button $script:Section3MonitorJobsResizeButton


$script:Section3MonitorJobsResizeCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = "Auto-Max"
    Left      = $script:Section3MonitorJobsResizeButton.Left + $script:Section3MonitorJobsResizeButton.Width + ($FormScale * 5)
    Top       = $script:Section3MonitorJobsResizeButton.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
    ForeColor = 'Black'
    Checked   = $true
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobsResizeCheckbox)


$script:Section3MonitorJobShowAllJobsButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'All Jobs'
    Left      = $FormScale * 510
    Top       = $script:Section3MonitorJobsResizeButton.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 8),1,2,1)
    ForeColor = 'Black'
    Add_Click = {
        $PoShEasyWinJobs = Get-Job -Name "PoSh-EasyWin:*"
 
        $CheckIfMonitoring = Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobContinuousCheckbox' -and $_.value -match 'checkState: 1'}
        if ( $CheckIfMonitoring ) {
            if ($PoShEasyWinJobs) {
                $PoShEasyWinJobs | Out-GridView -Title 'PoSh-EasyWin Jobs -- Unable to remove jobs if Monitoring'
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("There are no PoSh-EasyWin jobs currently running.",'PoSh-EasyWin','Info')
            }
        }
        else {
            if ($PoShEasyWinJobs) {
                $PoShEasyWinJobs | Out-GridView -Title 'PoSh-EasyWin Jobs -- Select jobs and click OK to remove them' -PassThru | Stop-Job -PassThru | Remove-Job -Force
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("There are no PoSh-EasyWin jobs currently running.",'PoSh-EasyWin','Info')
            }
        }
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobShowAllJobsButton)
Apply-CommonButtonSettings -Button $script:Section3MonitorJobShowAllJobsButton


$script:Section3MonitorJobRemoveButton = New-Object System.Windows.Forms.Button -Property @{
    Text      = 'Remove All'
    Left      = $FormScale * 590
    Top       = $script:Section3MonitorJobsResizeButton.Top
    Width     = $FormScale * 75
    Height    = $FormScale * 22
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 8),1,2,1)
    Add_Click = {
        $CheckIfMonitoring = Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobContinuousCheckbox' -and $_.value -match 'checkState: 1'}

        if ( $CheckIfMonitoring ) {
            [System.Windows.Forms.MessageBox]::Show("None of the jobs will be removed if any of them are being monitored. Uncheck any of the Monitor checkboxes to use this feature or remove them individually.","PoSh-EasyWin")
        }
        else {
            $RemoveAllJobsVerify = [System.Windows.Forms.MessageBox]::Show("Do you want to stop and remove all jobs?`n`nThis method stops running jobs and removes them from view, to include those jobs 'Monitor' checked. It will not delete the files regardless if their 'keep data' box is not checked.",'PoSh-EasyWin','YesNo','Warning')
            switch ($RemoveAllJobsVerify) {
                'Yes'{
                    Resize-MonitorJobsTab -Minimize

                    Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobPanel'} | Foreach-Object {
                        Invoke-Expression "`$script:Section3MonitorJobsTab.Controls.Remove(`$script:$($_.Name))"
                    }
            
                    $script:TotalJobsToRemoveCount = (Get-Job -name "PoSh-EasyWin: *" | Where-Object {$_.State -match 'Run'}).count
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Monitor Progress Bars Removed - Stopping $script:TotalJobsToRemoveCount Remainingg Jobs...")

                    Get-Job -Name "PoSh-EasyWin:*" | Remove-Job -Force
                    Get-Job -Name "PoSh-EasyWin:*" | Stop-Job -PassThru | Receive-Job -Force | Remove-Job -Force
                
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Monitor Progress Bars Removed - Stopping $script:TotalJobsToRemoveCount Remainingg Jobs - Completed")
            
                    $script:MonitorJobsTopPosition   = $script:Section3MonitorJobsGroupBox.Top + $script:Section3MonitorJobsGroupBox.Height
                }
                'No' {
                    continue
                }
            }
        }
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobRemoveButton)
Apply-CommonButtonSettings -Button $script:Section3MonitorJobRemoveButton
$script:Section3MonitorJobRemoveButton.ForeColor = 'Red'


$script:Section3MonitorJobKeepDataAllCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = 'Keep Data'
    Left      = $script:Section3MonitorJobRemoveButton.Left + $script:Section3MonitorJobRemoveButton.Width + ($FormScale * 5)
    Top       = $script:Section3MonitorJobsResizeButton.Top
    Width     = $FormScale * 70
    Height    = $FormScale * 11
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 8),1,2,1)
    ForeColor = 'Black'
    checked   = $false
    Add_Click = {
        if ($script:Section3MonitorJobKeepDataAllCheckbox.checked -eq $true) {
            $script:Section3MonitorJobKeepDataAllCheckbox.ForeColor = 'Black'
            Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobKeepDataCheckbox'} | Foreach-Object {
                Invoke-Expression "`$script:$($_.Name).checked = `$true"
                Invoke-Expression "`$script:$($_.Name).forecolor = 'black'"
            }
        }
        else {
            $script:Section3MonitorJobKeepDataAllCheckbox.ForeColor = 'Red'
            Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobKeepDataCheckbox'} | Foreach-Object {
                Invoke-Expression "`$script:$($_.Name).checked = `$false"
                Invoke-Expression "`$script:$($_.Name).forecolor = 'red'"
            }    
        } 
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobKeepDataAllCheckbox)



$script:Section3MonitorJobNotifyAllCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text      = 'Notify Me'
    Left      = $script:Section3MonitorJobKeepDataAllCheckbox.Left
    Top       = $script:Section3MonitorJobKeepDataAllCheckbox.Top + $script:Section3MonitorJobKeepDataAllCheckbox.Height + ($FormScale * 1)
    Width     = $FormScale * 70
    Height    = $FormScale * 11
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 8),1,2,1)
    ForeColor = 'Black'
    Checked   = $false
    Add_Click = {
        if ($script:Section3MonitorJobNotifyAllCheckbox.checked -eq $true) {
            $script:Section3MonitorJobNotifyAllCheckbox.ForeColor = 'Blue'
            Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobNotifyCheckbox'} | Foreach-Object {
                Invoke-Expression "`$script:$($_.Name).checked = `$true"
                Invoke-Expression "`$script:$($_.Name).forecolor = 'blue'"
            }
        }
        else {
            $script:Section3MonitorJobNotifyAllCheckbox.ForeColor = 'Black'
            Get-Variable | Where-Object {$_.Name -match 'Section3MonitorJobNotifyCheckbox'} | Foreach-Object {
                Invoke-Expression "`$script:$($_.Name).checked = `$false"
                Invoke-Expression "`$script:$($_.Name).forecolor = 'black'"
            }    
        } 
    }
}
$script:Section3MonitorJobsGroupBox.Controls.Add($script:Section3MonitorJobNotifyAllCheckbox)

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUL+uOcBeRudOT879a6FcXPXRd
# gyegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWubLBHL2hzp/5O/CjClH3kXUJvYwDQYJKoZI
# hvcNAQEBBQAEggEAYQA6zJuB+yFGgtfokelBxxu2IxH9fTGUil1/2wEIWOahgCob
# RTG1L0BUoW8k3AX0kUWabui1SfO8GVUvYHPC/MjATxZc05ywfkm6RkCLzlk6D5ja
# QDYojR3zZw/tuXua6AGuhBXNtf0s9lIgUo6WSgyEFFO34RHlI3SLyBLqtiKeea6Q
# EYJg1lXcthLNFiZhzkO8uAMI59+rg25ACmPhIG2jLOO7EX/PA4xcqdgBwFAUpRe/
# a2+yEI/aT3+RCFbzNh25Ukvl/hSvt1z23vjtcj8UqN5iEr/FK2xLzBCiQwHsrj47
# nIl+8EUVlo5jNZFRY3G1ucBDsGE6iYD+zcacrw==
# SIG # End signature block
