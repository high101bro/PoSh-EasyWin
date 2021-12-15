$CurrentProcessId = [System.Diagnostics.Process]::GetCurrentProcess().Id
$CollectionDirectory = $script:SystemTrayOpenFolder
$ScriptLocationPath = "$Dependencies\Commands & Scripts"
$EndpointCommandPath = "$Dependencies\Commands & Scripts\Commands - Endpoint.csv"
$ActiveDirectoryCommandPath = "$Dependencies\Commands & Scripts\Commands - Active Directory.csv"

$SystemTrayNotifyIcon = {
    param($CollectionDirectory,$ScriptLocationPath,$EndpointCommandPath,$ActiveDirectoryCommandPath,$CurrentProcessId,$FormAdminCheck,$script:EasyWinIcon,$Font,$ThisScript,$InitialScriptLoadTime)
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $PoShEasyWinSystemTrayNotifyIcon = New-Object System.Windows.Forms.NotifyIcon -Property @{
        Text        = 'PoSh-EasyWin  ' + '[' + $InitialScriptLoadTime + ']'
        Icon        = $script:EasyWinIcon
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
            Text      = 'Restart Tool'
            Add_Click = {
                $script:VerifyCloseForm = New-Object System.Windows.Forms.Form -Property @{
                    Text    = 'Restart Tool'
                    Width   = 280
                    Height  = 109
                    TopMost = $true
                    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
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
                    Text   = 'Do you want to restart PoSh-EasyWin?'
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
                    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$script:EasyWinIcon")
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


Start-Process -FilePath powershell.exe -ArgumentList  "-WindowStyle Hidden -Command Invoke-Command {$SystemTrayNotifyIcon} -ArgumentList @('$CollectionDirectory','$ScriptLocationPath','$EndpointCommandPath','$ActiveDirectoryCommandPath',$CurrentProcessId,[bool]'`$$FormAdminCheck','$script:EasyWinIcon','$Font',$($ThisScript.trim('&')),'$InitialScriptLoadTime')" -PassThru `
| Select-Object -ExpandProperty Id | Set-Variable FormHelperProcessId




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdtHzVgxUqqMnwhhttO0KhRO1
# +XqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwJFiewdTgamlduQ8DwGGyv8jB+IwDQYJKoZI
# hvcNAQEBBQAEggEARLVSw5NTvWkZ2zfwmtsKrecnfWYXXBWbx42fEBrP2Q6L879Z
# Xxgs43JMRx7UHEgzL7n2OAkW6XVl+Z+qtrqhWb017dFcPmH+jeNVJwhywiet5yL6
# h3dZVKUSCSkNR6+zSEm9IaqAtbXMj6hsRIqBD/+LIgdpmnjJ0ySp6aS1GF5rdpEx
# TO+2bKFvNBsGBSmT1geh52IBYG1imSK/x7Usjms94jRTvZWejvJ75IoTbYxHyRVi
# n41nIrfrriOoapkcw1F9mC46XbeOZ9sBEU0OxPFgw2GHe+Q02tiEG3uSYeakp1Lb
# Dr+UdUikhxrzaQ9q1aUfCK6am1wUB/VjgcxgIQ==
# SIG # End signature block
