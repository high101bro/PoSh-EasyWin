function Show-Process($Process, [Switch]$Maximize) {
    $sig = '
        [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
        [DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);
    '
    if ($Maximize) { $Mode = 3 } else { $Mode = 4 }
    $type = Add-Type -MemberDefinition $sig -Name WindowAPI -PassThru
    $hwnd = $process.MainWindowHandle
    $null = $type::ShowWindowAsync($hwnd, $Mode)
    $null = $type::SetForegroundWindow($hwnd)
}
<#
# launch Notepad minimized, then make it visible
$notepad = Start-Process notepad -WindowStyle Minimized -PassThru
Start-Sleep -Seconds 2
Show-Process -Process $notepad
# switch back to PowerShell, maximized
Start-Sleep -Seconds 2
Show-Process -Process (Get-Process -Id $PID) -Maximize
# switch back to Notepad, maximized
Start-Sleep -Seconds 2
Show-Process -Process $notepad -Maximize
# switch back to PowerShell, normal window
Start-Sleep -Seconds 2
Show-Process -Process (Get-Process -Id $PID)
#>


