function script:Invoke-PSWriteHTMLEndpointSnapshot {
    param(
        $InputData = $null,
        [switch]$MenuPrompt,
        [string[]]$CheckedItems
    )
    ##############################################################
    ##############################################################
    ##############################################################

    if ($CheckedItems -contains 'System Info' ) {
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
                New-HTMLSection -HeaderText 'Prefetch' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Prefetch' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Prefetch' -FontSize 18
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
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Hardware' ) {
        New-HTMLTab -Name 'Hardware' -IconBrands acquisitions-incorporated {
            ###########
            New-HTMLTab -Name 'Drivers' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Drivers' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Driver Details' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Drivers' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            # New-HTMLTab -Name 'System Drivers' -IconRegular window-maximize {
            #     New-HTMLSection -HeaderText 'System Drivers' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
            #         New-HTMLTable -DataTable $InputData.'System Drivers' {
            #             New-TableHeader -Color Blue -Alignment left -Title 'System Drivers' -FontSize 18
            #         } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            #     }
            # }
            ###########
            ###########
            New-HTMLTab -Name 'Motherboard / BIOS' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Motherboard / BIOS' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Motherboard' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Motherboard' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'BIOS' {
                            New-TableHeader -Color Blue -Alignment left -Title 'BIOS' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                }
            }
            ###########
            New-HTMLTab -Name 'Disks' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Disks' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Disks' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Disks' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Logical Disks' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Logical Disks' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
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
            New-HTMLTab -Name 'Memory' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Memory' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Physical Memory' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Physical Memory' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Memory Performance' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Memory Performance' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                }
            }
            ###########
            New-HTMLTab -Name 'USB / PNP' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'USB' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'USB Controllers & Devices' {
                            New-TableHeader -Color Blue -Alignment left -Title 'USB Controllers & Devices' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'USB History' {
                            New-TableHeader -Color Blue -Alignment left -Title 'USB History' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                New-HTMLSection -HeaderText 'PNP Devices' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'PNP Devices' {
                        New-TableHeader -Color Blue -Alignment left -Title 'PNP Devices' -FontSize 18
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
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Security' ) {
        New-HTMLTab -Name 'Security' -IconBrands acquisitions-incorporated {
            ###########
            New-HTMLTab -Name 'Auditing' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Auditing' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Audit Options' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Audit Options' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'auditpol' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Audit Policy (auditpol)' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
            }
            ###########
            New-HTMLTab -Name 'System Boot' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'System Boot' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Secure Boot Policy' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Secure Boot Policy' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Confirm Secure Boot UEFI' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Confirm Secure Boot UEFI' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
            }

            ###########
            New-HTMLTab -Name 'Security HotFixes' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Security HotFixes' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Security HotFixes' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Security HotFixes' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'Anti-Virus' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Antivirus Products' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Antivirus Products' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Antivirus Products' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
                New-HTMLSection -HeaderText 'Defender Status & Preferences' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Mp Computer Status' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Defender Status' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Mp Preferences' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Defender Preferences' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                New-HTMLSection -HeaderText 'Defender Threat Detection' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Mp Threat Detection' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Defender Active & Past Threats' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Mp Threat' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Defender Threat History' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
            }
            ###########
            New-HTMLTab -Name 'Firewall' -IconBrands acquisitions-incorporated {
                New-HTMLSection -HeaderText 'Firewall' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Firewall Profiles' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Firewall Profiles' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Firewall Rules' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Firewall Rules' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
            }
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Accounts' ) {
        New-HTMLTab -Name 'Accounts' -IconBrands acquisitions-incorporated {
            ###########
            New-HTMLTab -Name 'Accounts & Groups' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Local Group Administrators' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Local Group Administrators' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Local Group Administrators' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
                New-HTMLSection -HeaderText 'Local' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Local Users' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Local Users' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Local Groups' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Local Groups' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }    
                }
                New-HTMLSection -HeaderText 'Non-Local' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Non-Local Users' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Non-Local Users' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Non-Local Groups' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Non-Local Groups' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }    
                }
            }
            ###########
            New-HTMLTab -Name 'Logon Activity' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Sessions' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
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
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Network' ) {
        
        if ($MenuPrompt) { script:Launch-NetworkConnectionGUI }

        New-HTMLTab -Name 'Network' -IconBrands acquisitions-incorporated {
            ###########
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
                New-HTMLSection -HeaderText 'Network Adapters' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'IP Configuration' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Localhost Network Adapter Information' -FontSize 18 
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Hyper-V VM Network Adapters' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Hyper-V Virtual Manchine Network Adapter Information' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
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
            ###########
            if ($CheckedItems -match 'SRUM') {
                New-HTMLTab -Name 'SRUM' -IconRegular window-maximize {
                    New-HTMLSection -HeaderText 'Network' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLText -FontSize 12 -FontFamily 'Source Sans Pro' -Color Blue -Text "The System Resource Usage Monitor (SRUM) uses the Extensible Storage Engine (ESE) Database File (EDB) to store its folder data. SRUM is used to monitor desktop application programs, services, Windows applications and network connections. This specification is based on available documentation and was enhanced by analyzing test data."
                    }
                    New-HTMLSection -HeaderText 'Network' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLPanel {
                            New-HTMLTable -DataTable $InputData.'SRUM Network Connectivity' {
                                New-TableHeader -Color Blue -Alignment left -Title 'SRUM Network Connectivity' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                        New-HTMLPanel {
                            New-HTMLTable -DataTable $InputData.'SRUM Network Data Usage' {
                                New-TableHeader -Color Blue -Alignment left -Title 'SRUM Network Data Usage' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                    }
                }
            }
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Processes' ) {
        script:Invoke-PSWriteHTMLProcess -InputData $InputData.'Processes'
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Services' ) {
        New-HTMLTab -Name 'Services' -IconBrands acquisitions-incorporated {
            New-HTMLSection -HeaderText 'Services' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Services' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Service Information' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Event Logs' ) {
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
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Software' ) {
        New-HTMLTab -Name 'Software' -IconBrands acquisitions-incorporated {
            ###########
            New-HTMLTab -Name 'Software (Registry)' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Software (Registry)' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Software (Registry)' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Software (Registry)' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'Product Info' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Product Info' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Product Info' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Product Info' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'Crashed Applications' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Crashed Applications' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Crashed Applications' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Crashed Applications' -FontSize 18
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
            ###########
            if ($CheckedItems -match 'SRUM') {
                New-HTMLTab -Name 'SRUM' -IconRegular window-maximize {
                    New-HTMLSection -HeaderText 'SRUM' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLText -FontSize 12 -FontFamily 'Source Sans Pro' -Color Blue -Text "The System Resource Usage Monitor (SRUM) uses the Extensible Storage Engine (ESE) Database File (EDB) to store its folder data. SRUM is used to monitor desktop application programs, services, Windows applications and network connections. This specification is based on available documentation and was enhanced by analyzing test data."
                    }
                    New-HTMLSection -HeaderText 'Application' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLPanel {
                            New-HTMLTable -DataTable $InputData.'SRUM Application Usage' {
                                New-TableHeader -Color Blue -Alignment left -Title 'SRUM Application Usage' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                        New-HTMLPanel {
                            New-HTMLTable -DataTable $InputData.'SRUM Application Timeline' {
                                New-TableHeader -Color Blue -Alignment left -Title 'SRUM Application Timeline' -FontSize 18
                            } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                        }
                    }
                    New-HTMLSection -HeaderText 'Push Notifications' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                        New-HTMLTable -DataTable $InputData.'SRUM Push Notifications' {
                            New-TableHeader -Color Blue -Alignment left -Title 'SRUM Push Notifications' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
            }
        }
    }          

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Shares' ) {
        New-HTMLTab -Name 'Shares' -IconBrands acquisitions-incorporated {
            ###########
            New-HTMLTab -Name 'SMB Shares' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'SMB Shares' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'SMB Shares' {
                        New-TableHeader -Color Blue -Alignment left -Title 'SMB Shares' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'SMB Share Access' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'SMB Share Access' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'SMB Share Access' {
                        New-TableHeader -Color Blue -Alignment left -Title 'SMB Share Access' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'SMB Connections' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'SMB Connections' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'SMB Connections' {
                        New-TableHeader -Color Blue -Alignment left -Title 'SMB Connections' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'SMB Mappings' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'SMB Mappings' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'SMB Mappings' {
                        New-TableHeader -Color Blue -Alignment left -Title 'SMB Mappings' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'SMB Sessions' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'SMB Sessions' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'SMB Sessions' {
                        New-TableHeader -Color Blue -Alignment left -Title 'SMB Sessions' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'SMB Open Files' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'SMB Open Files' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'SMB Open Files' {
                        New-TableHeader -Color Blue -Alignment left -Title 'SMB Open Files' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Startup' ) {
        New-HTMLTab -Name 'Startup' -IconBrands acquisitions-incorporated {
            ###########
            New-HTMLTab -Name 'Startup Commands (Registry)' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Startup Commands (Registry)' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Startup Commands (Registry)' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Startup Commands (Registry)' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            ###########
            New-HTMLTab -Name 'Startup Commands' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'Startup Commands' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'Startup Commands' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Startup Commands' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'PowerShell' ) {
        New-HTMLTab -Name 'Powershell' -IconRegular window-maximize {
            New-HTMLTab -Name 'Environment' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'PowerShell' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'PowerShell Version' {
                            New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Version' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'WinRM Status' {
                            New-TableHeader -Color Blue -Alignment left -Title 'WinRM Status' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                New-HTMLSection -HeaderText 'PSDrives' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'PSDrives' {
                        New-TableHeader -Color Blue -Alignment left -Title 'PSDrives' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
                New-HTMLSection -HeaderText 'Variables' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Environmental Variables' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Environmental Variables' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Set Variables' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Set Variables' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression    
                    }
                }
                New-HTMLSection -HeaderText 'Commands / Functions' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'PowerShell Commands' {
                            New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Commands' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Functions' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Functions' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                New-HTMLSection -HeaderText 'Modules' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Powershell Modules Installed' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Modules Installed' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'Powershell Modules Available' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Modules Available' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
            }
            New-HTMLTab -Name 'Activity' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'PowerShell' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'PowerShell Sessions' {
                            New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Sessions' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'WSMan TrustedHosts' {
                            New-TableHeader -Color Blue -Alignment left -Title 'WSMan TrustedHosts' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                New-HTMLSection -HeaderText 'PowerShell Command History' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTable -DataTable $InputData.'PowerShell Command History' {
                        New-TableHeader -Color Blue -Alignment left -Title 'PowerShell Command History' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            New-HTMLTab -Name 'Profiles' -IconRegular window-maximize {
                New-HTMLSection -HeaderText 'PowerShell' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLTextBox -FontSize 12 -FontFamily 'Source Sans Pro' -Color Blue -TextBlock "
    The PowerShell Console supports the following profiles in precedence order (higher ones override  lower ones): 
        Current user, Current Host:
            $Home\[My]Documents\PowerShell\Microsoft.PowerShell_profile.ps1
        Current User, All Hosts
            $Home\[My]Documents\PowerShell\Profile.ps1
        All Users, Current Host
            $PsHome\Microsoft.PowerShell_profile.ps1
        All Users, All Hosts
            $PsHome\Profile.ps1

    Notes:
        The above are paths to where the profiles are stored if they exist. No results are return if the file doesn't exist.
        $PSHome = The installation directory for PowerShell
        $Home = The current user’s home directory
    "
                }
                New-HTMLSection -HeaderText 'All Users' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'PowerShell Profile (All Users All Hosts)' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Profile: All Users, All Hosts' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'PowerShell Profile (All Users Current Host)' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Profile: All Users, Current Host' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
                New-HTMLSection -HeaderText 'Current User' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'PowerShell Profile (Current User All Hosts)' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Profile: Current User, All Hosts' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                    New-HTMLPanel {
                        New-HTMLTable -DataTable $InputData.'PowerShell Profile (Current User Current Host)' {
                            New-TableHeader -Color Blue -Alignment left -Title 'Profile: Current User, Current Host' -FontSize 18
                        } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                    }
                }
            }
        }
    }

    ##############################################################
    ##############################################################
    ##############################################################
    if ($CheckedItems -contains 'Virtualization' ) {
        New-HTMLTab -Name 'Virtualization' -IconRegular window-maximize {
            New-HTMLSection -HeaderText 'Virtualization Software' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLPanel {
                    New-HTMLTable -DataTable $InputData.'VMWare Detected' {
                        New-TableHeader -Color Blue -Alignment left -Title 'VMWare Detected' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
                New-HTMLPanel {
                    New-HTMLTable -DataTable $InputData.'Hyper-V Status' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Hyper-V Status' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            New-HTMLSection -HeaderText 'Hyper-V Virtual Machines' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLPanel {
                    New-HTMLTable -DataTable $InputData.'Hyper-V VMs' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Hyper-V VMs' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
                New-HTMLPanel {
                    New-HTMLTable -DataTable $InputData.'Hyper-V VM Snapshots' {
                        New-TableHeader -Color Blue -Alignment left -Title 'Hyper-V VM Snapshots' -FontSize 18
                    } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
                }
            }
            New-HTMLSection -HeaderText 'Hyper-V VM Network Adapters' -HeaderTextColor White -HeaderTextAlignment center -CanCollapse {
                New-HTMLTable -DataTable $InputData.'Hyper-V VM Network Adapters' {
                    New-TableHeader -Color Blue -Alignment left -Title 'Hyper-V VM Network Adapters' -FontSize 18
                } -Buttons @('copyHtml5', 'excelHtml5', 'csvHtml5', 'pdfHtml5', 'pageLength') -SearchRegularExpression
            }
        }
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU12TSvq3KB1k2SI1YhUAJVykE
# zZ+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUti7lVjmXNrQC/lLUZC0L75m5CbUwDQYJKoZI
# hvcNAQEBBQAEggEAtFDoKDoEmhydSJ6+EwBsCnSo68pOQYrWasGj/zh0lo3qUh5x
# qMAMpT+jqZ3ouq9HcNCHKrZR6/YL10NyOImGfdTvNlRYhmV582lh3wcvMop4B4Xt
# zVwNBiuCl3/6oUEM0Ud2+QcaFJpE85O1aBXxSNx/BgkPVLtesy7uZ0wcuBKyz8tp
# YQvW/4eqknWbMaVb+1HqzGowHi87JBz5hc0TDcvpHVh4PQgajBfDg9HnIZCmtFTc
# bcHVDFW26cVDSnIYmwctax+JTNOPWnz7gCeWKvHXP6Hc4F4qF/4IKm/xfL1e8Vz3
# nnA5q6iozUguxp7+Nct9uXFMidNC52JC+3IkBA==
# SIG # End signature block
