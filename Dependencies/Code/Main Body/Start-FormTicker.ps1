# Start-FormTicker.ps1

$script:PoShEasyWinFormTicker = New-Object System.Windows.Forms.Timer -Property @{
    Enabled  = $true
    Interval = 250
}

$PoShEasyWinSessionTracker = @{}

$script:PoShEasyWinFormTicker.add_Tick({
    $script:PoShEasyWinStatusBar.Text = "$(Get-Date) - Computers Selected [$($script:ComputerList.Count)], Queries Selected [$($script:SectionQueryCount)], Open PSSessions [$(($script:PoShEasyWinPSSessions | Where-object {$_.State -match 'Open'}).count)]"

    # if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Beta Testing') {
        $PoShEasyWinPSSessionsOpenComputerList = ($script:PoShEasyWinPSSessions | Where-object {$_.State -match 'Open'}).ComputerName

        $script:PoShEasyWinPSSessions | ForEach-Object {
            if ($_.State -match 'Broke' -and ($_.Endtime -eq $null -or $_.Endtime -eq '')) {
                $_ | Add-Member -MemberType NoteProperty -Name Endtime -Value $(Get-Date) -Force -PassThru `
                   | Add-Member -MemberType NoteProperty -Name Duration -Value $(New-TimeSpan -Start $_.StartTime -End $(Get-Date)) -Force -PassThru
            }
        }

        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.Nodes) {
                        if ($Entry.text -in $PoShEasyWinSessionTracker.keys) {
                            $Entry.ImageIndex = $PoShEasyWinSessionTracker[$Entry.text]
                            $Entry.Forecolor = 'Red'
                            $PoShEasyWinSessionTracker.Remove($Entry.text)
                        }
                        elseif ($Entry.text -in $PoShEasyWinPSSessionsOpenComputerList) {
                            $PoShEasyWinSessionTracker[$Entry.text] = $Entry.ImageIndex
                            $Entry.ImageIndex = 3
                            $Entry.Forecolor = 'Red'
                        }
                        else {
                            $Entry.Forecolor = 'Black'
                        }
                    }
                }
            }
        }
    # }

    # Not working, the monitor-jobs script needs to be updated first
    #if ($ResultsFolderAutoTimestampCheckbox.checked) {
    #    $script:CollectionSavedDirectoryTextBox.Text = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
    #}
})
$script:PoShEasyWinFormTicker.Start()
