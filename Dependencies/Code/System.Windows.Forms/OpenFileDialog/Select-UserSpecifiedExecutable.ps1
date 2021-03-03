function Select-UserSpecifiedExecutable {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    if (Test-Path "$PoShHome\User Specified Executable And Script") {$ExecAndScriptDir = "$PoShHome\User Specified Executable And Script"}
    else {$ExecAndScriptDir = "$PoShHome"}

    if ($ExeScriptScriptOnlyCheckbox.checked -eq $False) {
        if ($ExeScriptSelectDirRadioButton.checked) {
            $ExeScriptSelectExecutableFolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog -Property @{
                #RootFolder = $PoShHome
                SelectedPath = $ExecAndScriptDir
                ShowNewFolderButton = $false
            }
            $ExeScriptSelectExecutableFolderBrowserDialog.ShowDialog()

            if ($($ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath)) {
                $script:ExeScriptSelectDirOrFilePath = $ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath

                $ExeScriptSelectExecutableTextBox.text = "$(($ExeScriptSelectExecutableFolderBrowserDialog.SelectedPath).split('\')[-1])"
            }
        }
    }
    if ($ExeScriptSelectFileRadioButton.checked) {
        $ExeScriptSelectExecutableOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title = "Select Executable File"
            Filter = "Executable (*.exe)| *.exe|Windows Installer (*.msi)| *.msi|All files (*.*)|*.*"
            ShowHelp = $true
            InitialDirectory = $ExecAndScriptDir
        }
        $ExeScriptSelectExecutableOpenFileDialog.ShowDialog()

        if ($($ExeScriptSelectExecutableOpenFileDialog.filename)) {
            $script:ExeScriptSelectDirOrFilePath = $ExeScriptSelectExecutableOpenFileDialog.filename

            $ExeScriptSelectExecutableTextBox.text = "$(($ExeScriptSelectExecutableOpenFileDialog.filename).split('\')[-1])"
        }
    }
}



