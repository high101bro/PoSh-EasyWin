
$ExternalProgramsWinRMRadioButtonAdd_Click = {
    #if ($ExternalProgramsWinRMRadioButton.checked -eq $true {
        $EventLogWinRMRadioButton.checked = $true
    #}
}

$ExternalProgramsWinRMRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "WinRM" -Icon "Info" -Message @'
+  Commands Used: (example)
    $Session = New-PSSession -ComputerName 'Endpoint'
    Invoke-Command {
        param($Path)
        Start-Process -Filepath "$Path\Procmon.exe" -ArgumentList @("/AcceptEULA /BackingFile $Path\ProcMon /RunTime 30 /Quiet")
        Remove-Item -Path "C:\Windows\Temp\Procmon.exe" -Force
    } -Session $Session -ArgumentList $Path
    Copy-Item -Path c:\Windows\Temp\ProcMon.pml -Destination $LocalPath\ProcMon -FromSession $Session -Force
'@
}


