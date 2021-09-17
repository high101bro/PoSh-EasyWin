# Start-FormTicker.ps1

$script:PoShEasyWinFormTicker = New-Object System.Windows.Forms.Timer -Property @{
    Enabled  = $true
    Interval = 1000
}
$script:PoShEasyWinFormTicker.add_Tick({
    $script:PoShEasyWinStatusBar.Text = "$(Get-Date) - Computers Selected [$($script:ComputerList.Count)], Queries Selected [$($script:SectionQueryCount)]"

    #$PoShEasyWinPSSessions = Get-PSSession
    #$ResultsListBox.Items.Insert(0,$PoShEasyWinPSSessions)
    # Not working, the monitor-jobs script needs to be updated first
    #if ($ResultsFolderAutoTimestampCheckbox.checked) {
    #    $script:CollectionSavedDirectoryTextBox.Text = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
    #}
})
$script:PoShEasyWinFormTicker.Start()
