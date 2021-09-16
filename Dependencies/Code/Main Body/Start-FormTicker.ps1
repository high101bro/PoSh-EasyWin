$script:PoShEasyWinStatusBar = New-Object System.Windows.Forms.StatusBar
$PoShEasyWin.Controls.Add($script:PoShEasyWinStatusBar)

$script:PoShEasyWinFormTicker = New-Object System.Windows.Forms.Timer -Property @{
    Enabled  = $true
    Interval = 250
}
$script:PoShEasyWinFormTicker.add_Tick({
    $script:PoShEasyWinStatusBar.Text = "$(Get-Date) - Computers Selected [$($script:ComputerList.Count)], Queries Selected [$($script:SectionQueryCount)]"
    
    # Not working, the monitor-jobs script needs to be updated first
    #if ($ResultsFolderAutoTimestampCheckbox.checked) {
    #    $script:CollectionSavedDirectoryTextBox.Text = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
    #}
})
$script:PoShEasyWinFormTicker.Start()
