$SysinternalsAutorunsButtonAdd_Click = {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsAutorunsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title    = "Open Autoruns File"
        Filter   = "Autoruns File (*.arn)| *.arn|All files (*.*)|*.*"
        ShowHelp = $true
    }
    if (Test-Path -Path "$script:IndividualHostResults\Autoruns") {
        $SysinternalsAutorunsOpenFileDialog.InitialDirectory = "$script:IndividualHostResults\$($SysinternalsAutorunsCheckbox.Text)"
        $SysinternalsAutorunsOpenFileDialog.ShowDialog() | Out-Null
    }
    else {
        $SysinternalsAutorunsOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"
        $SysinternalsAutorunsOpenFileDialog.ShowDialog() | Out-Null
    }
    if ($($SysinternalsAutorunsOpenFileDialog.filename)) {
        Start-Process "$ExternalPrograms\Autoruns.exe" -ArgumentList "`"$($SysinternalsAutorunsOpenFileDialog.filename)`""
    }
    #Returns button to default color if it was turned green after task completion
    CommonButtonSettings -Button $SysinternalsAutorunsButton
}


