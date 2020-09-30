
$CurrentProcessId = [System.Diagnostics.Process]::GetCurrentProcess().Id


$CloseWindow = {
    param($CurrentProcessId,$FormAdminCheck,$EasyWinIcon,$Font,$ThisScript)
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $ReloadForm = New-Object System.Windows.Forms.Form -Property @{
        Text    = 'PoSh-EasyWin'
        Width   = 105
        Height  = 109
        Left    = 0
        Top     = 0
        TopMost = $false
        Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Font    = New-Object System.Drawing.Font("$Font",11,0,0,0)
        # StartPosition = 'CenterScreen'
        ControlBox      = $false
        MaximizeBox     = $false
        MinimizeBox     = $true
        ShowIcon        = $true
        FormBorderStyle = 'Fixed3d'
        showintaskbar   = $true
        Add_Closing = { $This.dispose() }
    }
    function FormButtonSettings {
        param($button)
        $Button.ForeColor = 'Black'
        $Button.Flatstyle = 'Flat'
        $Button.UseVisualStyleBackColor = $true
        #$Button.FlatAppearance.BorderSize        = 1
        #$Button.BackColor = 'LightGray'
        $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
        $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
        $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray
    }

    $MinimizeButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Top Most = No'
        Width  = 116
        Height = 22
        Left   = 0
        Top    = 0
        Add_Click = {
            if ($ReloadForm.TopMost -eq $true) {
                $ReloadForm.TopMost  = $false
                $MinimizeButton.Text = 'Top Most: No'
            }
            elseif ($ReloadForm.TopMost -eq $false){
                $ReloadForm.TopMost  = $true
                $MinimizeButton.Text = 'Top Most: Yes'
            }
        }
    }
    $ReloadForm.Controls.Add($MinimizeButton)
    FormButtonSettings -Button $MinimizeButton


    $ReloadButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Abort / Reload'
        Width  = 116
        Height = 22
        Left   = 0
        Top    = $MinimizeButton.Top + $MinimizeButton.Height
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
                Add_Click = {
                    Stop-Process -id $CurrentProcessId -Force
                    $script:VerifyCloseForm.close()
                    $ReloadForm.close()
                }
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
                    $script:VerifyCloseForm.close()
                    $ReloadForm.close()
                }
            }
            $script:VerifyCloseForm.Controls.Add($VerifyYesButton)
            FormButtonSettings $VerifyYesButton


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
            FormButtonSettings $VerifyNoButton

            $script:VerifyCloseForm.ShowDialog()
        }
    }
    $ReloadForm.Controls.Add($ReloadButton)
    FormButtonSettings -Button $ReloadButton


    $ExitGuiButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Exit'
        Width  = 116
        Height = 22
        Left   = 0
        Top    = $ReloadButton.Top + $ReloadButton.Height
        Add_Click = {
            $script:VerifyCloseForm = New-Object System.Windows.Forms.Form -Property @{
                Text    = 'Close'
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
                Add_Click = {
                    Stop-Process -id $CurrentProcessId -Force
                    $script:VerifyCloseForm.close()
                    $ReloadForm.close()
                }
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
                    $script:VerifyCloseForm.close()
                    $ReloadForm.close()
                }
            }
            $script:VerifyCloseForm.Controls.Add($VerifyYesButton)
            FormButtonSettings $VerifyYesButton


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
            FormButtonSettings $VerifyNoButton

            $script:VerifyCloseForm.ShowDialog()
        }
    }
    $ReloadForm.Controls.Add($ExitGuiButton)
    FormButtonSettings -Button $ExitGuiButton

    <# Future feature... need to work on a error with user32.dll
        $WindowAction = '[DllImport("user32.dll",EntryPoint="ShowWindow")] private static extern bool ShowWindow(int handle, int state);'
        Add-Type -Name Action -MemberDefinition $WindowAction -Namespace Window

        # Minimizes current window
        #[Window.Action]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 2);

        # Close Window
        #[Window.Action]::ShowWindow((Get-Process -id 5308).MainWindowHandle, 0)

        # Forefront Window
        #[Window.Action]::ShowWindow((Get-Process -id 5308).MainWindowHandle, 1)

        # Minimize Window
        #[Window.Action]::ShowWindow((Get-Process -id 5308).MainWindowHandle, 2)

        # Maximize Window
        [Window.Action]::ShowWindow((Get-Process -id 5308).MainWindowHandle, 3)

        # Restore Window
        #[Window.Action]::ShowWindow((Get-Process -id 5308).MainWindowHandle, 4)

        # Checks if it exists
        #[Window.Action]::ShowWindow((Get-Process -id 5308).MainWindowHandle, 5)
    # >

    $ReloadForm.ShowDialog()
}

Start-Process -FilePath powershell.exe -ArgumentList  "-WindowStyle Hidden  -Command Invoke-Command {$CloseWindow} -ArgumentList @($CurrentProcessId,[bool]'`$$FormAdminCheck','$EasyWinIcon','$Font',$($ThisScript.trim('&')))" -PassThru `
| Select-Object -ExpandProperty Id | Set-Variable FormHelperProcessId
#>



