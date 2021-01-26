$CurrentProcessId = [System.Diagnostics.Process]::GetCurrentProcess().Id
$CollectionDirectory = $script:SystemTrayOpenFolder
$ScriptLocationPath = "$Dependencies\Cmds & Scripts"
$EndpointCommandPath = "$Dependencies\Cmds & Scripts\Commands - Endpoint.csv"
$ActiveDirectoryCommandPath = "$Dependencies\Cmds & Scripts\Commands - Active Directory.csv"

$SystemTrayNotifyIcon = {
    param($CollectionDirectory,$ScriptLocationPath,$EndpointCommandPath,$ActiveDirectoryCommandPath,$CurrentProcessId,$FormAdminCheck,$EasyWinIcon,$Font,$ThisScript,$InitialScriptLoadTime)
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $PoShEasyWinSystemTrayNotifyIcon = New-Object System.Windows.Forms.NotifyIcon -Property @{
        Text        = 'PoSh-EasyWin  ' + '[' + $InitialScriptLoadTime + ']'
        Icon        = $EasyWinIcon
        Visible     = $true
        ContextMenu = New-Object System.Windows.Forms.ContextMenu
        BalloonTipTitle = 'PoSh-EasyWin'
    }

        $SystemTrayCollectedDataMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Collection Folder'
            Add_Click = {
                Start-Process -FilePath "$CollectionDirectory"
            }
        }
        $PoShEasyWinSystemTrayNotifyIcon.contextMenu.MenuItems.Add($SystemTrayCollectedDataMenuItem)


        $SystemTrayEndpointCommandsMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Endpoint Commands'
            Add_Click = {
                Invoke-Item $EndpointCommandPath
                #Import-Csv $EndpointCommandPath | Out-GridView -Title 'Endpoint Commands'
            }
        }
        $SystemTrayEndpointScriptsMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Endpoint Scripts'
            Add_Click = {
                Start-Process -FilePath "$ScriptLocationPath\Scripts-Host"
            }
        }
        $SystemTrayActiveDirectoryCommandsMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Active Directory Commands'
            Add_Click = {
                Invoke-Item $ActiveDirectoryCommandPath
                #Import-Csv $ActiveDirectoryCommandPath | Out-GridView -Title 'Active Directory Commands'
            }
        }
        $SystemTrayActiveDirectoryScriptssMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Active Directory Scripts'
            Add_Click = {
                Start-Process -FilePath "$ScriptLocationPath\Scripts-AD"
            }
        }
        $SystemTrayOpenFilesAndFoldersMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Commands and Scripts'
        }
        
        $PoShEasyWinSystemTrayNotifyIcon.contextMenu.MenuItems.Add($SystemTrayOpenFilesAndFoldersMenuItem)
        $SystemTrayOpenFilesAndFoldersMenuItem.MenuItems.Add($SystemTrayEndpointCommandsMenuItem)
        $SystemTrayOpenFilesAndFoldersMenuItem.MenuItems.Add($SystemTrayEndpointScriptsMenuItem)
        $SystemTrayOpenFilesAndFoldersMenuItem.MenuItems.Add($SystemTrayActiveDirectoryCommandsMenuItem)
        $SystemTrayOpenFilesAndFoldersMenuItem.MenuItems.Add($SystemTrayActiveDirectoryScriptssMenuItem)



        $SystemTrayAbortReloadMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text      = 'Abort / Reload'
            Add_Click = {
                $script:VerifyCloseForm = New-Object System.Windows.Forms.Form -Property @{
                    Text    = 'Abort / Reload'
                    Width   = 280
                    Height  = 109
                    TopMost = $true
                    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    Font    = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    FormBorderStyle = 'Fixed3d'
                    StartPosition   = 'CenterScreen'
                    ControlBox      = $true
                    MaximizeBox     = $false
                    MinimizeBox     = $false
                    showintaskbar   = $true
                    Add_Closing = { $This.dispose() }
                }
                $VerifyCloseLabel = New-Object System.Windows.Forms.Label -Property @{
                    Text   = 'Do you want to Abort / Reload PoSh-EasyWin?'
                    Width  = 280
                    Height = 22
                    Left   = 10
                    Top    = 10
                }
                $script:VerifyCloseForm.Controls.Add($VerifyCloseLabel)


                $VerifyYesButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = 'Yes'
                    Width  = 115
                    Height = 22
                    Left   = 10
                    Top    = $VerifyCloseLabel.Top + $VerifyCloseLabel.Height
                    BackColor = 'LightGray'
                    Add_Click = {
                        Stop-Process -id $CurrentProcessId -Force
                        if ($FormAdminCheck -eq 'True'){
                            try {
                                Start-Process PowerShell.exe -Verb RunAs -ArgumentList $ThisScript
                            }
                            catch {
                                Start-Process PowerShell.exe -ArgumentList @($ThisScript, '-SkipEvelationCheck')
                            }
                        }
                        else {
                            Start-Process PowerShell.exe -ArgumentList @($ThisScript, '-SkipEvelationCheck')
                        }
                        $PoShEasyWinSystemTrayNotifyIcon.Visible = $false
                        $script:VerifyCloseForm.close()
                    }
                }
                $script:VerifyCloseForm.Controls.Add($VerifyYesButton)


                $VerifyNoButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = 'No'
                    Width  = 115
                    Height = 22
                    Left   = $VerifyYesButton.Left + $VerifyYesButton.Width + 10
                    Top    = $VerifyYesButton.Top
                    BackColor = 'LightGray'
                    Add_Click = {
                        $script:VerifyCloseForm.close()
                    }
                }
                $script:VerifyCloseForm.Controls.Add($VerifyNoButton)

                $script:VerifyCloseForm.ShowDialog()
            }
        }
        $PoShEasyWinSystemTrayNotifyIcon.contextMenu.MenuItems.Add($SystemTrayAbortReloadMenuItem)


        $CloseTime = 'Close  [' + $InitialScriptLoadTime + ']'
        $SystemTrayCloseToolMenuItem = New-Object System.Windows.Forms.MenuItem -Property @{
            Text = 'Close Tool'
            add_Click = {
                $script:VerifyCloseForm = New-Object System.Windows.Forms.Form -Property @{
                    Text    = $CloseTime
                    Width   = 250
                    Height  = 109
                    TopMost = $true
                    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    Font    = New-Object System.Drawing.Font("$Font",11,0,0,0)
                    FormBorderStyle =  'Fixed3d'
                    StartPosition   = 'CenterScreen'
                    ControlBox      = $true
                    MaximizeBox     = $false
                    MinimizeBox     = $false
                    showintaskbar   = $true
                    Add_Closing = { $This.dispose() }
                }
                $VerifyCloseLabel = New-Object System.Windows.Forms.Label -Property @{
                    Text   = 'Do you want to close PoSh-EasyWin?'
                    Width  = 250
                    Height = 22
                    Left   = 10
                    Top    = 10
                }
                $script:VerifyCloseForm.Controls.Add($VerifyCloseLabel)


                $VerifyYesButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = 'Yes'
                    Width  = 100
                    Height = 22
                    Left   = 10
                    Top    = $VerifyCloseLabel.Top + $VerifyCloseLabel.Height
                    BackColor = 'LightGray'
                    Add_Click = {
                        Stop-Process -id $CurrentProcessId -Force
                        $PoShEasyWinSystemTrayNotifyIcon.Visible = $false
                        $script:VerifyCloseForm.close()
                    }
                }
                $script:VerifyCloseForm.Controls.Add($VerifyYesButton)


                $VerifyNoButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = 'No'
                    Width  = 100
                    Height = 22
                    Left   = $VerifyYesButton.Left + $VerifyYesButton.Width + 10
                    Top    = $VerifyYesButton.Top
                    BackColor = 'LightGray'
                    Add_Click = {
                        $script:VerifyCloseForm.close()
                    }
                }
                $script:VerifyCloseForm.Controls.Add($VerifyNoButton)


                $script:VerifyCloseForm.ShowDialog()
            }
        }
        $PoShEasyWinSystemTrayNotifyIcon.contextMenu.MenuItems.Add($SystemTrayCloseToolMenuItem)


    ### Make PowerShell Disappear
    #
    #$windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    #$asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
    #$null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
    #
    # End


    # Force garbage collection just to start slightly lower RAM usage.
    [System.GC]::Collect()


    # Create an application context for it to all run within.
    # This helps with responsiveness, especially when clicking Exit... like in my testing: immediately vs 5-10 seconds
    $appContext = New-Object System.Windows.Forms.ApplicationContext
    [void][System.Windows.Forms.Application]::Run($appContext)
}


Start-Process -FilePath powershell.exe -ArgumentList  "-WindowStyle Hidden -Command Invoke-Command {$SystemTrayNotifyIcon} -ArgumentList @('$CollectionDirectory','$ScriptLocationPath','$EndpointCommandPath','$ActiveDirectoryCommandPath',$CurrentProcessId,[bool]'`$$FormAdminCheck','$EasyWinIcon','$Font',$($ThisScript.trim('&')),'$InitialScriptLoadTime')" -PassThru `
| Select-Object -ExpandProperty Id | Set-Variable FormHelperProcessId



