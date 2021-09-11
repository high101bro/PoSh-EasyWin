function Display-ContextMenuForComputerTreeNode {
    param(
        [switch]$ClickedOnNode,
        [switch]$ClickedOnArea
    )

    Create-TreeViewCheckBoxArray -Endpoint

    $script:ComputerListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
        ShowCheckMargin  = $false
        ShowImageMargin  = $false
        ShowItemToolTips = $true
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
    }

    #$script:ComputerListContextMenuStrip.Items.Add("Import Endpoints")
    $script:ComputerListEndpointNameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "$($Entry.Text)"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
        BackColor = 'lightgray'
    }
    $script:ComputerListContextMenuStrip.Items.Add($script:ComputerListEndpointNameToolStripLabel)
    if ($Entry.Text -eq $null) {$script:ComputerListEndpointNameToolStripLabel.Text = "Node Not Selected"}


    $script:ComputerListContextMenuStrip.Items.Add('-')


    $ComputerListInteractWithEndpointToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Interact With Endpoint"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListInteractWithEndpointToolStripLabel)


    if ($ClickedOnNode) {
        if ($script:ComputerListPivotExecutionCheckbox.checked -eq $false) {
            $ComputerListRemoteDesktopToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text        = "  - Remote Desktop"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListRDPButtonAdd_Click
                ToolTipText = "
Establishes a Remote Desktop session with an endpoint.

Uses the native cmd called mstsc.exe (Microsoft Terminal Services Client)

Requires RDP to be entabled within the network or on the host.

Default ports, protocols, and services: 
    TCP|UDP / 3389
    Remote Desktop Protocol (RDP)
    SSL/TLS Encryption: Windows Vista + / Server 2003 +

Command:
    mstsc /v:<target>:3389 /user:USERNAME /pass:PASSWORD /NoConsentPrompt
"
            }
            $script:ComputerListContextMenuStrip.Items.Add($ComputerListRemoteDesktopToolStripButton)


            $ComputerListEnterPSSessionToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text        = "  - Enter-PSSession"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListPSSessionButtonAdd_Click
                ToolTipText = "
Establishes an interactive Powershell Session with an endpoint.

Normally, conntections with endpoints are authenticated with Active Directory and the hostname.

To use with an IP address, rather than a hostname, the Credential parameter must be used. Also, the endpoint must have the remote computer's IP must be in the local TrustedHosts or be configured for HTTPS transport.

Default ports, protocols, and services: 
    TCP / 47001 - Endpoint Listener
    TCP / 5985 [HTTP]  Windows 7+
    TCP / 5986 [HTTPS] Windows 7+
    TCP / 80   [HTTP]  Windows Vista-
    TCP / 443  [HTTPS] Windows Vista-
    Windows Remote Management (WinRM)
    Regardless of the transport protocol used (HTTP or HTTPS), WinRM always encrypts all PowerShell remoting communication after initial authentication

Command:
    Enter-PSSession -ComputerName <target> -Credential <`$creds>
"
            }
            $script:ComputerListContextMenuStrip.Items.Add($ComputerListEnterPSSessionToolStripButton)


            $ComputerListPSExecToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text        = "  - PSExec (Sysinternals)"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListPsExecButtonAdd_Click
                ToolTipText = "
Establishes an interactive cmd prompt via PSExec.

PsExec.exe is a Windows Sysinternals tool.

This tool is particularly useful when WinRM is disabled or when trying to access an endpoint not joined to a domain.

Depending on the network security policy, PSExec may be prevented from running.

Additionally, many anti-virus scanners or security tools will alert on this as malicious executable, despite it being legitimate.

Default ports, protocols, and services: 
    TCP / 445 
    Server Message Block (SMB)
    PSExec version 2.1+ (released 7 March 2014), encrypts all communication between local and remote systems

Command:
    PsExec.exe -AcceptEULA -NoBanner \\<target> -u <domain\username> -p <password> cmd
"
            }
            $script:ComputerListContextMenuStrip.Items.Add($ComputerListPSExecToolStripButton)


            $ComputerListSSHToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text        = "  - SSH (Secure Shell)"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListSSHButtonAdd_Click
                ToolTipText = "
Establishes an interactive secure shell (SSH) with an endpoint.

Useful to access Linux and Windows hosts with SSH enabled.

SSH/OpenSSH is natively available on Windows 10 as up the April 2018 update, it does not support passing credentials automatically.

Uses KiTTY, a better version forked from Plink (PuTTY) that not only has all the same features has but many more.

Plink (PuTTY CLI tool), is an ssh client often used for automation, but has some integration issues with PoSh-EasyWin.

Default ports, protocols, and services: 
    TCP / 22
    Secure Socket Layer/Transport Socket Layer (SSL/TLS)

Command:
    kitty.exe -ssh 'IP/hostname' -l 'username' -pw 'password'
"
            }
            $script:ComputerListContextMenuStrip.Items.Add($ComputerListSSHToolStripButton)


            $ComputerListEventViewerToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text        = "  - Event Viewer GUI (Connect)"
                ForeColor   = 'Black'
                Add_Click   = $EventViewerConnectionButtonAdd_Click
                ToolTipText = "
Establishes an interactive session and displays a GUI with an endpoint.

Must launch shell with elevated permissions, as there is no credential parameter for Show-EventLog.

Default ports, protocols, and services: 
    TCP / 135 and dynamic ports, typically:
    TCP / 49152-65535 (Windows Vista, Server 2008 and above)
    TCP / 1024 -65535 (Windows NT4, Windows 2000, Windows 2003)
    Remote Procedure Call / Distributed Component Object Model (RPC/DCOM)

Command:
    Show-EventLog -ComputerName <Hostname>
"
            }
            $script:ComputerListContextMenuStrip.Items.Add($ComputerListEventViewerToolStripButton)

            $ComputerListEventViewerToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text        = "  - Event Viewer GUI (Collect)"
                ForeColor   = 'Black'
                Add_Click   = $EventViewerCollectionButtonAdd_Click
                ToolTipText = "
Collects data on available Event Logs and saves them locally for review with Event Viewer.

Default ports, protocols, and services: 
    TCP / 47001 - Endpoint Listener
    TCP / 5985 [HTTP]  Windows 7+
    TCP / 5986 [HTTPS] Windows 7+
    TCP / 80   [HTTP]  Windows Vista-
    TCP / 443  [HTTPS] Windows Vista-
    Windows Remote Management (WinRM)
    Regardless of the transport protocol used (HTTP or HTTPS), WinRM always encrypts all PowerShell remoting communication after initial authentication

Command Ex:
    `$EventLogSaveName = (Get-WmiObject -Class Win32_NTEventlogFile | Where-Object LogfileName -EQ 'Security').BackupEventlog('c:\Windows\Temp\Hostname (yyyy-MM-dd HH.mm.ss) Security.evtx')
    eventvwr -l:'c:\Windows\Temp\Hostname (yyyy-MM-dd HH.mm.ss) Security.evtx'
"
            }
            $script:ComputerListContextMenuStrip.Items.Add($ComputerListEventViewerToolStripButton)

            # $ComputerListEndpointInteractionToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
            #     Size = @{ Width  = $FormScale * 150 }
            #     Text = '  - Make a selection'
            #     ForeColor = 'Black'
            #     ToolTipText = 'Interact with endpoints in various way if they are configured to do so.'
            #     Add_SelectedIndexChanged = {
            #         $script:ComputerListContextMenuStrip.Close()
            #         if ($This.selectedItem -eq ' - Remote Desktop') { 
            #             $script:ComputerListContextMenuStrip.Close()
            #             & $ComputerListRDPButtonAdd_Click
            #         }
            #         if ($This.selectedItem -eq ' - PSSession')  { 
            #             $script:ComputerListContextMenuStrip.Close()
            #             & $ComputerListPSSessionButtonAdd_Click
            #         }
            #         if ($This.selectedItem -eq ' - PSExec')  { 
            #             $script:ComputerListContextMenuStrip.Close()
            #             & $ComputerListPsExecButtonAdd_Click
            #         }
            #         if ($This.selectedItem -eq ' - SSH')  { 
            #             $script:ComputerListContextMenuStrip.Close()
            #             & $ComputerListSSHButtonAdd_Click
            #         }
            #         if ($This.selectedItem -eq ' - Event Viewer')  { 
            #             $script:ComputerListContextMenuStrip.Close()
            #             & $EventViewerConnectionButtonAdd_Click
            #         }
            #     }
            # }
            # $ComputerListEndpointInteractionToolStripComboBox.Items.Add(' - Remote Desktop')
            # $ComputerListEndpointInteractionToolStripComboBox.Items.Add(' - PSSession')
            # $ComputerListEndpointInteractionToolStripComboBox.Items.Add(' - PSExec')
            # $ComputerListEndpointInteractionToolStripComboBox.Items.Add(' - SSH')
            # $ComputerListEndpointInteractionToolStripComboBox.Items.Add(' - Event Viewer')
            # $script:ComputerListContextMenuStrip.Items.Add($ComputerListEndpointInteractionToolStripComboBox)    
        }
        elseif ($script:ComputerListPivotExecutionCheckbox.checked -eq $true) {
            $ComputerListPSSessionPivotToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text        = "  - Pivot-PSSession"
                ForeColor   = 'Black'
                Add_Click   = $ComputerListPSSessionPivotButtonAdd_Click
                ToolTipText = 'Sends commands to a pivot host to execute on an endpoint.'
            }
            $script:ComputerListContextMenuStrip.Items.Add($ComputerListPSSessionPivotToolStripButton)
        }
    }
    else {
        $ComputerListLeftClick1ToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
            Text      = "Left-Click an endpoint,`nthen Right-Click for options."
            TextAlign = 'MiddleLeft'
            ForeColor = 'DarkRed'
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListLeftClick1ToolStripLabel)
    }


    $ComputerListSelectedNodeActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Node Actions: Selected"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListSelectedNodeActionsToolStripLabel)


    $ComputerListSelectedNodeActionsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Conduct various actions against a single node.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq " - Tag Node With Metadata") { 
                $script:ComputerListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3HostDataTab

                if ($script:EntrySelected) {
                    Show-TagForm -Endpoint
                    if ($script:ComputerListMassTagValue) {
                        $script:Section3HostDataNameTextBox.Text  = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Name
                        $Section3HostDataOSTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).OperatingSystem
                        $Section3HostDataOUTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).CanonicalName
                        $Section3HostDataIPTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).IPv4Address
                        $Section3HostDataMACTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).MACAddress
                        $Section3HostDataNotesRichTextBox.Text = "[$($script:ComputerListMassTagValue)] " + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Notes
                        Save-TreeViewData -Endpoint
                        $StatusListBox.Items.clear()
                        $StatusListBox.Items.Add("Tag applied to: $($script:EntrySelected.text)")
                    }
                }   
            }
            if ($This.selectedItem -eq ' - Add New Endpoint Node')  { 
                $script:ComputerListContextMenuStrip.Close()
    
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Add hostname/IP:")
           
                
                $ComputerTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
                    Text   = "Add Hostname/IP"
                    Width  = $FormScale * 335
                    Height = $FormScale * 177
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    StartPosition = "CenterScreen"
                    Add_Closing = { $This.dispose() }
                }
            
            
                $ComputerTreeNodePopupAddTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text   = "Enter a hostname/IP"
                    Left   = $FormScale * 10
                    Top    = $FormScale * 10
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodePopupAddTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } })
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupAddTextBox)
            
            
                $ComputerTreeNodePopupOSComboBox  = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text   = "Select an Operating System (or type in a new one)"
                    Left   = $FormScale * 10
                    Top    = $ComputerTreeNodePopupAddTextBox.Top + $ComputerTreeNodePopupAddTextBox.Height + $($FormScale * 10)
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
                    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
                    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodeOSCategoryList = $script:ComputerTreeViewData | Select-Object -ExpandProperty OperatingSystem -Unique
            
            
                # Dynamically creates the OS Category combobox list used for OS Selection
                ForEach ($OS in $ComputerTreeNodeOSCategoryList) { $ComputerTreeNodePopupOSComboBox.Items.Add($OS) }
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupOSComboBox)
            
            
                $ComputerTreeNodePopupOUComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text   = "Select an Organizational Unit / Canonical Name (or type a new one)"
                    Left   = $FormScale * 10
                    Top    = $ComputerTreeNodePopupOSComboBox.Top + $ComputerTreeNodePopupOSComboBox.Height + $($FormScale * 10)
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
                    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
                    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodeOUCategoryList = $script:ComputerTreeViewData | Select-Object -ExpandProperty CanonicalName -Unique
                # Dynamically creates the OU Category combobox list used for OU Selection
                ForEach ($OU in $ComputerTreeNodeOUCategoryList) { $ComputerTreeNodePopupOUComboBox.Items.Add($OU) }
                $ComputerTreeNodePopupOUComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } })
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupOUComboBox)
            
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                if ($Script:CategorySelected){ $ComputerTreeNodePopupOUComboBox.Text = $Script:CategorySelected.text }
                elseif ($Script:EntrySelected){ $ComputerTreeNodePopupOUComboBox.Text = $Script:EntrySelected.text }
                else { $ComputerTreeNodePopupOUComboBox.Text  = "Select an Organizational Unit / Canonical Name (or type a new one)" }
            
            
                $ComputerTreeNodePopupAddHostButton = New-Object System.Windows.Forms.Button -Property @{
                    Text   = "Add Host"
                    Left   = $FormScale * 210
                    Top    = $ComputerTreeNodePopupOUComboBox.Top + $ComputerTreeNodePopupOUComboBox.Height + $($FormScale * 10)
                    Width  = $FormScale * 100
                    Height = $FormScale * 25
                    Add_Click = { AddHost-ComputerTreeNode }
                    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } }    
                }
                Apply-CommonButtonSettings -Button $ComputerTreeNodePopupAddHostButton
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupAddHostButton)
            
                # $script:ComputerTreeView.ExpandAll()
                # Remove-EmptyCategory -Endpoint
                # Normalize-TreeViewData -Endpoint
                # Save-TreeViewData -Endpoint
                $ComputerTreeNodePopup.ShowDialog()
            }
            if ($This.selectedItem -eq " - Rename Selected Node")  { 
                $script:ComputerListContextMenuStrip.Close()

                
                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Enter a new name:")

                    $ComputerTreeNodeRenamePopup = New-Object system.Windows.Forms.Form -Property @{
                        Text   = "Rename $($script:EntrySelected.text)"
                        Width  = $FormScale * 330
                        Height = $FormScale * 107
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                        StartPosition = "CenterScreen"
                        Add_Closing   = { $This.dispose() }    
                    }

                    $script:ComputerTreeNodeRenamePopupTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                        Text   = "New Hostname/IP"
                        Left   = $FormScale * 10
                        Top    = $FormScale * 10
                        Width  = $FormScale * 300
                        Height = $FormScale * 25
                        Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)    
                    }

                    # Renames the computer treenode to the specified name
                    . "$Dependencies\Code\Tree View\Computer\Rename-ComputerTreeNodeSelected.ps1"

                    # Moves the hostname/IPs to the new Category
                    $script:ComputerTreeNodeRenamePopupTextBox.Add_KeyDown({
                        if ($_.KeyCode -eq "Enter") { Rename-ComputerTreeNodeSelected }
                    })
                    $ComputerTreeNodeRenamePopup.Controls.Add($script:ComputerTreeNodeRenamePopupTextBox)


                    $ComputerTreeNodeRenamePopupButton = New-Object System.Windows.Forms.Button -Property @{
                        Text   = "Execute"
                        Left   = $FormScale * 210
                        Top    = $script:ComputerTreeNodeRenamePopupTextBox.Left + $script:ComputerTreeNodeRenamePopupTextBox.Height + ($FormScale * 5)
                        Width  = $FormScale * 100
                        Height = $FormScale * 22
                    }
                    Apply-CommonButtonSettings -Button $ComputerTreeNodeRenamePopupButton
                    $ComputerTreeNodeRenamePopupButton.Add_Click({ Rename-ComputerTreeNodeSelected })
                    $ComputerTreeNodeRenamePopup.Controls.Add($ComputerTreeNodeRenamePopupButton)

                    $ComputerTreeNodeRenamePopup.ShowDialog()
                }
                else {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add($script:EntrySelected.text)
                }
                #elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Rename Selection' }
                #elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Rename Selection' }

                Remove-EmptyCategory -Endpoint
                Save-TreeViewData -Endpoint
            }
            if ($This.selectedItem -eq " - Move Node To New OU/CN")  { 
                $script:ComputerListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {
                    Show-MoveForm -Endpoint -Title "Move: $($script:EntrySelected.Text)" -SelectedEndpoint
            
                    $script:ComputerTreeView.Nodes.Clear()
                    Initialize-TreeViewData -Endpoint
            
                    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                    Foreach($Computer in $script:ComputerTreeViewData) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address  -Metadata $Computer
                    }
            
                    Remove-EmptyCategory -Endpoint
                    Save-TreeViewData -Endpoint
                    UpdateState-TreeViewData -Endpoint -NoMessage
            
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Moved:  $($script:EntrySelected.text)")
                }
            }
            if ($This.selectedItem -eq " - Delete Selected Node")  {
                $script:ComputerListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {

                    $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of Endpoint Node: $($script:EntrySelected.text)`r`n`r`nAll Endpoint metadata and notes will be lost.`r`n`r`nAny previously collected data will still remain.",'Delete Endpoint','YesNo')

                    Switch ( $MessageBox ) {
                        'Yes' {
                            # Removes selected computer nodes
                            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                            foreach ($root in $AllTreeViewNodes) {
                                foreach ($Category in $root.Nodes) {
                                    foreach ($Entry in $Category.nodes) {
                                        if ($Entry.text -eq $script:EntrySelected.text) {
                                            # Removes the node from the treeview
                                            $Entry.remove()
                                            # Removes the host from the variable storing the all the computers
                                            $script:ComputerTreeViewData = $script:ComputerTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                        }
                                    }
                                }
                            }
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add("Deleted:  $($script:EntrySelected.text)")

                            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

                            #This is a bit of a workaround, but it prevents the host data message from appearing after a computer node is deleted...
                            $script:FirstCheck = $false

                            Remove-EmptyCategory -Endpoint
                            Save-TreeViewData -Endpoint
                        }
                        'No' {
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add('Endpoint Deletion Cancelled')
                        }
                    }
                }   
            }
        }
    }
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Add New Endpoint Node")
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Tag Node With Metadata")
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Move Node To New OU/CN")
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Delete Selected Node")
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add(" - Rename Selected Node")
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListSelectedNodeActionsToolStripComboBox)


    $script:ComputerListContextMenuStrip.Items.Add('-')
    $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'Checked Endpoints'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)


    $script:ComputerListContextMenuStrip.Items.Add('-')



    $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'Test Connection'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)

    $ComputerListTestConnectionToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 150 }
        Text = '  - Make a selection'
        ForeColor = "Black"
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - ICMP Ping') { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Ping')
                }
                else {
                    if (Verify-Action -Title "Verification: Ping Test" -Question "Conduct a Ping test to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "Ping" -MessageTrue "Able to Ping" -MessageFalse "Unable to Ping"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Ping:  Cancelled")
                    }
                }            
            }
            if ($This.selectedItem -eq ' - RPC Port Check')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','RPC Port Check')
                }
                else {
                    if (Verify-Action -Title "Verification: RPC Port Check" -Question "Connecting Account:  $Username`n`nConduct a RPC Port Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "RPC Port Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("RPC Port Check:  Cancelled")
                    }
                }
            }
            if ($This.selectedItem -eq ' - SMB Port Check')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','SMB Port Check')
                }
                else {
                    if (Verify-Action -Title "Verification: SMB Port Check" -Question "Connecting Account:  $Username`n`nConduct a SMB Port Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "SMB Port Check" -MessageTrue "SMB Port 445 is Open" -MessageFalse "SMB Port 445 is Closed"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("SMB Port Check:  Cancelled")
                    }
                }
            }
            if ($This.selectedItem -eq ' - WinRM Check')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -lt 1){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','WinRM Check')
                }
                else {
                    if (Verify-Action -Title "Verification: WinRM Check" -Question "Connecting Account:  $Username`n`nConduct a WinRM Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "WinRM Check" -MessageTrue "Able to Verify WinRM" -MessageFalse "Unable to Verify WinRM"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("WinRM Check:  Cancelled")
                    }
                }
            }
        }
    }
    $ComputerListTestConnectionToolStripComboBox.Items.Add(' - ICMP Ping')
    $ComputerListTestConnectionToolStripComboBox.Items.Add(' - RPC Port Check')
    $ComputerListTestConnectionToolStripComboBox.Items.Add(' - SMB Port Check')
    $ComputerListTestConnectionToolStripComboBox.Items.Add(' - WinRM Check')
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListTestConnectionToolStripComboBox)


    $ComputerListCheckedNodeActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Node Actions: All"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListCheckedNodeActionsToolStripLabel)

    $ComputerListCheckedNodeActionsDeselectAllButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text        = "  - Uncheck All Nodes"
        ForeColor   = 'Black'
        Add_Click   = {
            $script:ComputerListContextMenuStrip.Close()
            Deselect-AllComputers
        }
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListCheckedNodeActionsDeselectAllButton)

    $ComputerListCheckedNodeActionsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 150 }
        Text = '  - Make a selection'
        ForeColor = 'Black'
        ToolTipText = 'Conduct various actions against selected nodes.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - NSLookup (Hostname to IP)')  { 
                $script:ComputerListContextMenuStrip.Close()

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','NSLookup')
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3HostDataTab
            
                    $script:ProgressBarEndpointsProgressBar.Value = 0
                    $script:ProgressBarQueriesProgressBar.Value   = 0
            
                    Create-TreeViewCheckBoxArray -Endpoint
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
            
                        $MessageBox = [System.Windows.Forms.MessageBox]::Show("Conduct an NSLookup of $($script:ComputerTreeViewSelected.count) endpoints?","NSLookup",'YesNo','Info')
                        Switch ( $MessageBox ) {
                            'Yes' {
                                $MessageBoxAnswer = $true
                            }
                            'No' {
                                $MessageBoxAnswer = $false
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add('NSLookup Cancelled')
                            }
                        }
            
                        $script:ProgressBarEndpointsProgressBar.Maximum  = $script:ComputerTreeViewSelected.count
                        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            
                        if ($MessageBoxAnswer -eq $true) {
                            $ComputerListNSLookupArray = @()
                            foreach ($node in $script:ComputerTreeViewSelected) {
                                foreach ($root in $AllTreeViewNodes) {
                                    foreach ($Category in $root.Nodes) {
                                        foreach ($Entry in $Category.Nodes) {
                                            $LookupEndpoint = $null
            
                                            if ($Entry.Checked -and $Entry.Text -notin $ComputerListNSLookupArray) {
                                                $ComputerListNSLookupArray += $Entry.Text
                                                $script:Section3HostDataNameTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $Section3HostDataOSTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                                $Section3HostDataOUTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
            
                                                $LookupEndpoint = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $NSlookup = $((Resolve-DnsName "$LookupEndpoint" | Sort-Object IPAddress | Select-Object -ExpandProperty IPAddress -Unique) -Join ', ')
                                                $Section3HostDataIPTextBox.Text = $NSlookup
            
                                                $Section3HostDataMACTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                                $Section3HostDataNotesRichTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                                Save-TreeViewData -Endpoint
            
                                            }
                                            $script:ProgressBarEndpointsProgressBar.Value += 1
                                        }
                                    }
                                }
                            }
                #               Save-TreeViewData -Endpoint -SaveAllChecked
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("NSLookup Complete: $($script:ComputerTreeViewSelected.count) Endpoints")
                        }
                    }
                }     
            }
            if ($This.selectedItem -eq ' - Tag Nodes With Metadata')  {
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Tag All')
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3HostDataTab
            
                    $script:ProgressBarEndpointsProgressBar.Value = 0
                    $script:ProgressBarQueriesProgressBar.Value   = 0
            
                    Create-TreeViewCheckBoxArray -Endpoint
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
                        Show-TagForm -Endpoint
            
                        $script:ProgressBarEndpointsProgressBar.Maximum  = $script:ComputerTreeViewSelected.count
                        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            
                        if ($script:ComputerListMassTagValue) {
                            $ComputerListMassTagArray = @()
                            foreach ($node in $script:ComputerTreeViewSelected) {
                                foreach ($root in $AllTreeViewNodes) {
                                    foreach ($Category in $root.Nodes) {
                                        foreach ($Entry in $Category.Nodes) {
                                            if ($Entry.Checked -and $Entry.Text -notin $ComputerListMassTagArray) {
                                                $ComputerListMassTagArray += $Entry.Text
                                                $script:Section3HostDataNameTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $Section3HostDataOSTextBox.Text          = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                                $Section3HostDataOUTextBox.Text          = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                                                $Section3HostDataIPTextBox.Text          = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                                                $Section3HostDataMACTextBox.Text         = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                                $Section3HostDataNotesRichTextBox.Text   = "[$($script:ComputerListMassTagValue)] " + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                            }
                                            $script:ProgressBarEndpointsProgressBar.Value += 1
                                        }
                                    }
                                }
                            }
                            Save-TreeViewData -Endpoint -SaveAllChecked
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("Tag Complete: $($script:ComputerTreeViewSelected.count) Endpoints")
                        }
                    }
                }      
            }
            if ($This.selectedItem -eq ' - Move Nodes To New OU/CN')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Move All')
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
                        Show-MoveForm -Endpoint -Title "Moving $($script:ComputerTreeViewSelected.count) Endpoints"
            
                        $script:ComputerTreeView.Nodes.Clear()
                        Initialize-TreeViewData -Endpoint
            
                        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                        $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                        Foreach($Computer in $script:ComputerTreeViewData) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address  -Metadata $Computer
                        }
            
                        Remove-EmptyCategory -Endpoint
                        Save-TreeViewData -Endpoint
                        UpdateState-TreeViewData -Endpoint -NoMessage
            
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Moved $($script:ComputerTreeNodeToMove.Count) Endpoints")
                        $ResultsListBox.Items.Clear()
                        $ResultsListBox.Items.Add("The following hostnames/IPs have been moved to $($ComputerTreeNodePopupMoveComboBox.SelectedItem):")
                    }
                    else { ComputerNodeSelectedLessThanOne -Message 'Move Selection' }
                }      
            }
            if ($This.selectedItem -eq ' - Delete Checked Nodes')  { 
                $script:ComputerListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Delete All')
                }
                else {
                    
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    if ($script:ComputerTreeViewSelected.count -eq 1) {
                        $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of $($script:ComputerTreeViewSelected.count) Endpoint Node.`r`n`r`nAll Endpoint metadata and notes will be lost.`r`nAny previously collected data will still remain.",'Delete Endpoint','YesNo')
                    }
                    elseif ($script:ComputerTreeViewSelected.count -gt 1) {
                        $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of $($script:ComputerTreeViewSelected.count) Endpoint Nodes.`r`n`r`nAll Endpoint metadata and notes will be lost.`r`nAny previously collected data will still remain.",'Delete Endpoints','YesNo')
                    }
            
                    Switch ( $MessageBox ) {
                        'Yes' {
                            if ($script:ComputerTreeViewSelected.count -gt 0) {
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                                    foreach ($root in $AllTreeViewNodes) {
                                        foreach ($Category in $root.Nodes) {
                                            foreach ($Entry in $Category.nodes) {
                                                if ($Entry.checked) {
                                                    $Entry.remove()
                                                    # Removes the host from the variable storing the all the computers
                                                    $script:ComputerTreeViewData = $script:ComputerTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                                }
                                            }
                                        }
                                    }
                                }
                                # Removes selected category nodes - Note: had to put this in its own loop...
                                # the saving of nodes didn't want to work properly when use in the above loop when switching between treenode views.
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    foreach ($root in $AllTreeViewNodes) {
                                        foreach ($Category in $root.Nodes) {
                                            if ($Category.checked) { $Category.remove() }
                                        }
                                    }
                                }
                                # Removes selected root node - Note: had to put this in its own loop... see above category note
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    foreach ($root in $AllTreeViewNodes) {
                                        if ($root.checked) {
                                            foreach ($Category in $root.Nodes) { $Category.remove() }
                                            $root.remove()
                                            if ($i -eq "All Endpoints") { $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList) }
                                        }
                                    }
                                }
            
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Deleted:  $($script:ComputerTreeViewSelected.Count) Selected Items")
                                #Removed For Testing#$ResultsListBox.Items.Clear()
                                $ResultsListBox.Items.Add("The following hosts have been deleted:  ")
                                $ComputerListDeletedArray = @()
                                foreach ($Node in $script:ComputerTreeViewSelected) {
                                    if ($Node -notin $ComputerListDeletedArray) {
                                        $ComputerListDeletedArray += $Node
                                        $ResultsListBox.Items.Add(" - $Node")
                                    }
                                }
            
                                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
                
                                Remove-EmptyCategory -Endpoint
                                Save-TreeViewData -Endpoint
                            }
                            else { ComputerNodeSelectedLessThanOne -Message 'Delete Selection' }
                        }
                        'No' {
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add('Endpoint Deletion Cancelled')
                        }
                    }
                }      
            }
        }
    }
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add(' - NSLookup (Hostname to IP)')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add(' - Tag Nodes With Metadata')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add(' - Move Nodes To New OU/CN')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add(' - Delete Checked Nodes')
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListCheckedNodeActionsToolStripComboBox)


    $script:ComputerListContextMenuStrip.Items.Add('-')
    

    $ComputerListEndpointAdditionalActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Additional Actions"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListEndpointAdditionalActionsToolStripLabel)


    $script:ComputerListContextMenuStrip.Items.Add('-')


    $ComputerListImportEndpointDataToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Import Endpoint Data"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListImportEndpointDataToolStripLabel)


    $ComputerListImportEndpointDataToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Import Endpoint Data from various sources. Conflicting endpoint names will not be imported.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - Active Directory') { 
                $script:ComputerListContextMenuStrip.Close()
                Import-DataFromActiveDirectory -Endpoint
            }
            if ($This.selectedItem -eq ' - Local .csv File')  { 
                $script:ComputerListContextMenuStrip.Close()
                Import-DataFromCsv -Endpoint
            }
            if ($This.selectedItem -eq ' - Local .txt File')  { 
                $script:ComputerListContextMenuStrip.Close()
                Import-DataFromTxt -Endpoint
            }
        }
    }
    $ComputerListImportEndpointDataToolStripComboBox.Items.Add(' - Active Directory')
        # Opens a form that provides you options on how to import endpoint data from Acitve Directory
        # Options include:
        #   - Import from Domain with Directory Searcher
        #   - Import from Active Directory remotely using WinRM
        #   - Import from Active Directory Locally
    $ComputerListImportEndpointDataToolStripComboBox.Items.Add(' - Local .csv File')
        # Imports data from a selected Comma Separated Value file
        # This file can be easily generated with the following command:
        #   - Get-ADComputer -Filter * -Properties Name,OperatingSystem,CanonicalName,IPv4Address,MACAddress | Export-Csv "Domain Computers.csv"
        # This file should be formatted with the following headers, though the import script should populate default missing data:
        #   - Name
        #   - OperatingSystem
        #   - CanonicalName
        #   - IPv4Address
        #   - MACAddress
        #   - Notes    
    $ComputerListImportEndpointDataToolStripComboBox.Items.Add(' - Local .txt File')
        # Imports data from a selected Text file
        # Useful if you recieve a computer list file from an Admin or outputted from nmap
        # This file should be formatted with one hostname or IP address per line
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListImportEndpointDataToolStripComboBox)


    $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'View Endpoint Data'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)


    $ComputerListViewEndpointDataToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'View the local data for all endpoints that populates the treeview.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - Out-GridView') { 
                $script:ComputerListContextMenuStrip.Close()
                Import-Csv -Path $script:EndpointTreeNodeFileSave | Out-GridView -Title 'Endpoint Data'
            }
            if ($This.selectedItem -eq ' - Spreadsheet Software')  { 
                $script:ComputerListContextMenuStrip.Close()
                Invoke-Item -Path $script:EndpointTreeNodeFileSave
            }
            if ($This.selectedItem -eq ' - Browser HTML View')  { 
                $script:ComputerListContextMenuStrip.Close()
                Import-Csv -Path $script:EndpointTreeNodeFileSave | Out-HTMLView -Title 'Endpoint Data'
            }
        }
    }
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add(' - Out-GridView')
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add(' - Spreadsheet Software')
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add(' - Browser HTML View')
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListViewEndpointDataToolStripComboBox)    


    $ComputerListEndpointUpdateTreeviewToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'Update TreeView'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListEndpointUpdateTreeviewToolStripLabel)


    $ComputerListEndpointUpdateTreeviewToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Quickly modify the endpoint treeview to better manage and find nodes.'
        Add_SelectedIndexChanged = {
            $script:ComputerListContextMenuStrip.Close()
            
            if ($This.selectedItem -eq ' - Collapsed View') { 
                $script:ComputerListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                $script:ComputerTreeView.CollapseAll()
                foreach ($root in $AllTreeViewNodes) { $root.Expand() }
            }
            if ($This.selectedItem -eq ' - Normal View')  { 
                $script:ComputerListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                $script:ComputerTreeView.CollapseAll()
                foreach ($root in $AllTreeViewNodes) {  
                    $root.Expand() 
                    foreach ($Category in $root.nodes) {
                        $Category.Expand()
                    }
                }
            }
            if ($This.selectedItem -eq ' - Expanded View')  { 
                $script:ComputerListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                foreach ($root in $AllTreeViewNodes) {  
                    $root.Expand() 
                    foreach ($Category in $root.nodes) {
                        $Category.Expand()
                        foreach ($Entry in $Category.nodes){
                            $Entry.Expand()
                            foreach($Metadata in $Entry.nodes){
                                $Metadata.Expand()
                                foreach($Data in $Metadata.nodes){
                                    $Data.Expand()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    $ComputerListEndpointUpdateTreeviewToolStripComboBox.Items.Add(' - Collapsed View')
    $ComputerListEndpointUpdateTreeviewToolStripComboBox.Items.Add(' - Normal View')
    $ComputerListEndpointUpdateTreeviewToolStripComboBox.Items.Add(' - Expanded View')
    $script:ComputerListContextMenuStrip.Items.Add($ComputerListEndpointUpdateTreeviewToolStripComboBox)    


    $script:ComputerListContextMenuStrip.Items.Add('-')


    $Entry.ContextMenuStrip = $script:ComputerListContextMenuStrip
}


