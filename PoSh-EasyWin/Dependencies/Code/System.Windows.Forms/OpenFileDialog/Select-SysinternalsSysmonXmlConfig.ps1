function Select-SysinternalsSysmonXmlConfig {
    Add-Type -AssemblyName System.Windows.Forms
        #[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    
    $SysinternalsSysmonOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        Title = "Select Sysmon Configuration XML File"
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