$SysinternalsProcmonButtonAdd_Click = {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsProcmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title    = "Open ProcMon File"
        Filter   = "ProcMon Log File (*.pml)| *.pml|All files (*.*)|*.*"
        ShowHelp = $true
    }
    if (Test-Path -Path "$script:IndividualHostResults\Procmon") {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$script:IndividualHostResults\$($SysinternalsProcessMonitorCheckbox.Text)"
        $SysinternalsProcmonOpenFileDialog.ShowDialog()
    }
    else {
        $SysinternalsProcmonOpenFileDialog.InitialDirectory = "$CollectedDataDirectory"
        $SysinternalsProcmonOpenFileDialog.ShowDialog()
    }
    if ($($SysinternalsProcmonOpenFileDialog.filename)) {
        Start-Process "$ExternalPrograms\Procmon.exe" -ArgumentList "`"$($SysinternalsProcmonOpenFileDialog.filename)`""
    }
    #Returns button to default color if it was turned green after task completion
    CommonButtonSettings -Button $SysinternalsProcmonButton
}


