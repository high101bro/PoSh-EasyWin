function script:Invoke-PSWriteHTMLEndpointSnapshot {
    param(
        $InputData = $null,
        [switch]$MenuPrompt
    )
    if ($MenuPrompt) { script:Launch-NetworkConnectionGUI }

    ##############################################################
    ##############################################################
    ##############################################################
    New-HTMLTab -Name 'System Info' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Computer Info' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'OS Information' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Computer Info' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Operating System Information' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'System DateTimes' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'System DateTimes' {
                    New-TableHeader -Color Blue -Alignment left -Title 'System DateTimes' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'Computer Restore Points' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Computer Restore Points' {
                    New-TableHeader -Color Blue -Alignment left -Title "Computer Restore Points" -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }

        ###########
        New-HTMLTab -Name 'Powershell' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'PowerShell Version' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'PowerShell Version' {
                    New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Version' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'PowerShell Sessions' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'PowerShell Sessions' {
                    New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'Environmental Variables' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Environmental Variables' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Environmental Variables' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'Set Variables' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Set Variables' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Set Variables' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'Functions' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Functions' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Functions' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'PSDrives' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'PSDrives' {
                    New-TableHeader -Color Blue -Alignment left -Title 'PSDrives' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Scheduled Tasks & Jobs' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'schtasks' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'schtasks' {
                    New-TableHeader -Color Blue -Alignment left -Title 'The schtasks tool performs the same operations as Scheduled Tasks in Control Panel.' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'Scheduled Tasks' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Scheduled Tasks' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Get-ScheduledTask obtains task definition objects of scheduled tasks that are registered.' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'Scheduled Jobs' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Scheduled Jobs' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Get-ScheduledJob obtains only scheduled jobs that are created by the current user using the Register-ScheduledJob cmdlet.' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Windows Optional Features' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Windows Optional Features' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Windows Optional Features' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    New-HTMLTab -Name 'Hardware' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Driver Details' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Driver Details' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Driver Details' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Driver Details' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'System Drivers' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'System Drivers' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'System Drivers' {
                    New-TableHeader -Color Blue -Alignment left -Title 'System Drivers' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Motherboard' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Motherboard' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Motherboard' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Motherboard' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Logical Disks' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Logical Disks' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Logical Disks' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Logical Disks' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Disks' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Disks' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Disks' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Disks' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Processor (CPU)' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Processor (CPU)' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Processor (CPU)' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Processor (CPU)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Physical Memory' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Physical Memory' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Physical Memory' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Physical Memory' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Memory Performance' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Memory Performance' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Memory Performance' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Memory Performance' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'BIOS' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'BIOS' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'BIOS' {
                    New-TableHeader -Color Blue -Alignment left -Title 'BIOS' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'USB' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'USB Controllers & Devices' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'USB Controllers & Devices' {
                    New-TableHeader -Color Blue -Alignment left -Title 'USB Controllers & Devices' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'PNP Devices' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'PNP Devices' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'PNP Devices' {
                    New-TableHeader -Color Blue -Alignment left -Title 'PNP Devices' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'USB History' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'USB History' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'USB History' {
                    New-TableHeader -Color Blue -Alignment left -Title 'USB History' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Printers' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Printers' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Printers' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Printers' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
    }
    ##############################################################
    ##############################################################
    ##############################################################
    script:Invoke-PSWriteHTMLProcess -InputData $InputData.'Processes'


    ##############################################################
    ##############################################################
    ##############################################################
    New-HTMLTab -Name 'Network' -IconBrands acquisitions-incorporated {

        script:Invoke-PSWriteHTMLNetworkConnections -InputData $InputData.'Network TCP Connections'

        ###########
        New-HTMLTab -Name 'UDP Endpoints' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Network UDP Endpoints' {
                    New-TableHeader -Color Blue -Alignment left -Title 'UDP Endpoint Connections' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Wireless Networks' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Wireless Networks' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Wireless Networks' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Network Adapters' -IconRegular window-maximize {
            New-HTMLPanel {
                New-HTMLTable -DataTable $InputData.'IP Configuration' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Localhost Network Adapter Information' -FontSize 18 
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLPanel {
                New-HTMLTable -DataTable $InputData.'Hyper-V VM Network Adapter' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Hyper-V Virtual Manchine Network Adapter Information' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Port Proxy' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Port Proxy' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Port Proxies redirect communications from one source to another, be it host internal or external to other endpoints.' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'DNS' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'DNS' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLPanel {
                    New-HTMLTable -DataTable $InputData.'Hosts File' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Hosts File' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
                New-HTMLPanel {
                    New-HTMLTable -DataTable $InputData.'DNS Cache' {
                        New-TableHeader -Color Blue -Alignment left -Title 'DNS Cache' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    New-HTMLTab -Name 'Services' -IconBrands acquisitions-incorporated {
        New-HTMLSection -HeaderText 'Services' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
            New-HTMLTable -DataTable $InputData.'Services' {
                New-TableHeader -Color Blue -Alignment left -Title 'Service Information' -FontSize 18
            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    New-HTMLTab -Name 'Accounts' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'Logon' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Sessions' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLPanel {
                    #New-HTMLText -FontSize 12 -FontFamily 'Source Sans Pro' -Color Blue -Text 'Quser (query user) is a built-in Windows command line tool that is particularly useful when needing to identify active user sessions on a computer.'

                    New-HTMLTable -DataTable $InputData.'Active User Sessions' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Active User Sessions' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
                New-HTMLPanel {
                    New-HTMLTable -DataTable $InputData.'PowerShell Sessions' {
                        New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }    
            }
            New-HTMLSection -HeaderText 'Network Login Information' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLPanel {
                    #New-HTMLText -FontSize 12 -FontFamily 'Source Sans Pro' -Color Blue -Text 'Win32_NetworkLoginProfile WMI class represents the network login information of a specific user on a computer system running Windows. This includes, but is not limited to password status, access privileges, disk quotas, and logon directory paths.'

                    New-HTMLTable -DataTable $InputData.'Network Login Information' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Network Login Information' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            New-HTMLSection -HeaderText 'Logins (Past 30 Days)' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Successful Logins (Past 30 Days)' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Successful Logins (Past 30 Days)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                New-HTMLTable -DataTable $InputData.'Failed Logins (Past 30 Days)' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Failed Logins (Past 30 Days)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
            New-HTMLSection -HeaderText 'Login Event Details (Past 30 Days)' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Event Logs - Login Event Details (Past 30 Days)' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Login Event Details (Past 30 Days)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }           
        }        
    }
    
    ##############################################################
    ##############################################################
    ##############################################################
    New-HTMLTab -Name 'Event Logs' -IconBrands acquisitions-incorporated {
        ###########
        New-HTMLTab -Name 'EventLog List' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'EventLog List' {
                    New-TableHeader -Color Blue -Alignment left -Title 'EventLog List' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'WinEvent LogList' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'WinEvent LogList' {
                    New-TableHeader -Color Blue -Alignment left -Title 'WinEvent LogList' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Application (Last 1000)' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Event Logs - Application (Last 1000)' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Event Logs - Application (Last 1000)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Event Logs - Security (Last 1000)' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Event Logs - Security (Last 1000)' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Event Logs - Security (Last 1000)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        ###########
        New-HTMLTab -Name 'Event Logs - System (Last 1000)' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Event Logs - System (Last 1000)' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Event Logs - System (Last 1000)' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
        
    }
    ##############################################################
    ##############################################################
    ##############################################################

        # ###########
        # New-HTMLTab -Name 'xxxxx' -IconRegular window-maximize {
        #     New-HTMLSection -HeaderText 'Table Search' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
        #         New-HTMLTable -DataTable $InputData.xxxxx {
        #             New-TableHeader -Color Blue -Alignment left -Title 'XXXXXXXXXXXXXXXXXXXX' -FontSize 18
        #         } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
        #     }
        # }

        


}