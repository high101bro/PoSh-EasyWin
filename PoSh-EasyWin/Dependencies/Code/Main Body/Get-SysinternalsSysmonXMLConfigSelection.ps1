function Get-SysinternalsSysmonXMLConfigSelection {
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $SysinternalsSysmonOpenFileDialog.Title = "Select Sysmon Configuration XML File"
    $SysinternalsSysmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Filter = "XML Files (*.xml)| *.xml|All files (*.*)|*.*"
        ShowHelp = $true
        InitialDirectory = "$Dependencies\Sysmon Config Files"
    }
    $SysinternalsSysmonOpenFileDialog.ShowDialog() | Out-Null
    if ($($SysinternalsSysmonOpenFileDialog.filename)) { 
        $script:SysmonXMLPath = $SysinternalsSysmonOpenFileDialog.filename 

        $SysinternalsSysmonConfigTextBox.text = "Config: $(($SysinternalsSysmonOpenFileDialog.filename).split('\')[-1])"
        $Script:SysmonXMLName = $(($SysinternalsSysmonOpenFileDialog.filename).split('\')[-1])
    }
}