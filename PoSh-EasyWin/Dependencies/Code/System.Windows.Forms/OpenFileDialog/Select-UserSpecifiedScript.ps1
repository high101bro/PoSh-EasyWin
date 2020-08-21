function Select-UserSpecifiedScript {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    if (Test-Path "$PoShHome\User Specified Executable And Script") {$ExecAndScriptDir = "$PoShHome\User Specified Executable And Script"}
    else {$ExecAndScriptDir = "$PoShHome"}

    $ExeScriptSelectScriptOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title = "Select Script File"
        Filter = "PowerShell Script (*.ps1)| *.ps1|Batch File (*.bat)| *.bat|Text File (*.txt)| *.txt|All files (*.*)|*.*"
        ShowHelp = $true
        InitialDirectory = $ExecAndScriptDir
    }
    $ExeScriptSelectScriptOpenFileDialog.ShowDialog() | Out-Null
    if ($($ExeScriptSelectScriptOpenFileDialog.filename)) { 
        $script:ExeScriptSelectScriptPath = $ExeScriptSelectScriptOpenFileDialog.filename 

        $ExeScriptSelectScriptTextBox.text = "$(($ExeScriptSelectScriptOpenFileDialog.filename).split('\')[-1])"
        #$Script:ExeScriptSelectScriptName  = $(($ExeScriptSelectScriptOpenFileDialog.filename).split('\')[-1])
    }
}

