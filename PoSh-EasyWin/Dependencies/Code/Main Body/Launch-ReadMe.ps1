
function Launch-ReadMe {
    param([switch]$ReadMe)
function Conduct-NodeActionAcknowledgement {
    param($TreeView)
    [System.Windows.Forms.TreeNodeCollection]$AllNodes = $TreeView
    foreach ($root in $AllNodes) {
        if ($root.checked){
            foreach ($entry in $root.nodes){ $entry.checked = $true }
        }

        foreach ($Topic in $root.nodes){
            if ($Topic.checked){
                $Topic.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                $Topic.ForeColor = 'Green' #[System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Topic.ForeColor = 'DarkRed'
            }
        }
    }
}


$UserNoticeAcknowledgementForm = New-Object System.Windows.Forms.Form -Property @{
    Text          = "PoSh-EasyWin - Read Me, User Notice, and Acknowledgement"
    StartPosition = "CenterScreen"
    Width   = $FormScale * 1025
    Height  = $FormScale * 525
    TopMost = $true
    Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
    FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
    #clientsize = 100
    Add_Closing = { $This.dispose() }
}
if ($ReadMe) {
    $UserNoticeAcknowledgementForm.text = "PoSh-EasyWin - Read Me"
    TopMost = $false
}


$AcknowledgeLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Below is information to be aware of and understand about how PoSh-EasyWin operates. Each section can be expanded to view additional information. This window shows up during PoSh-EasyWin's first time launch, and can also be viewed again within the options tab."
    Left   = $FormScale * 10
    Top    = $FormScale * 10
    Width  = $FormScale * 980
    Height = $FormScale * 35
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
}
$UserNoticeAcknowledgementForm.Controls.Add($AcknowledgeLabel)


$AcknowledgeTreeView = New-Object System.Windows.Forms.TreeView -Property @{
    Left   = $AcknowledgeLabel.Left
    Top    = $AcknowledgeLabel.Top + $AcknowledgeLabel.Height #($FormScale * 5)
    Width  = $FormScale * 980
    Height = $FormScale * 395
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    LabelEdit        = $False
    ShowLines        = $True
    ShowNodeToolTips = $True
    Add_Click        = {
        if (-not (Test-Path "$PoShHome\Settings\User Notice And Acknowledgement.txt")) {
            Conduct-NodeActionAcknowledgement -TreeView $AcknowledgeTreeView.Nodes
        }
    }
    ###Add_AfterSelect  = { Conduct-NodeAction -TreeView $AcknowledgeTreeView.Nodes -Commands }
}
$UserNoticeAcknowledgementForm.Controls.Add($AcknowledgeTreeView)


$AcknowledgeAllTreeNode = New-Object System.Windows.Forms.TreeNode -Property @{
    #Name = $line
    Text = "Acknowledge All"
}
$AcknowledgeTreeView.Nodes.Add($AcknowledgeAllTreeNode)


if ($ReadMe){
    $AcknowledgeTreeView.CheckBoxes = $false
    [System.Windows.Forms.TreeNodeCollection]$AllNodes = $AcknowledgeTreeView.Nodes
    foreach ($root in $AllNodes) { $root.text = 'Read Me and User Notice' }
}
else {
    $AcknowledgeTreeView.CheckBoxes = $true
}


$Acknowledgement = "About PoSh-EasyWin
    Is the localhost joined to the domain or not
        This tool was designed to be executed from a trusted computer that is not joined to the domain
        That said, it can be ran on a localhost joined to the domain
        Read more about the above further below
    This tool makes use of the .NET Framework to access libraries to:
        Generate the Graphical User Interface
        Create PowerShell Charts
        Network Scanning
    The following modules are optional to use:
        PSWriteHTML
            PoSh-EasyWin can make use of the PSWriteHTML module to generate dynamic graphs
            If this third party module is installed, it provides another means to represent data in an intuitive manner using a web browser
            Though this module has been scanned and reviewed, any third party modules may pose a security risk
            The PSWriteHTML module files have been packaged with PoSh-EasyWin, but are not being used unless its import
            This selection is persistent for this tool, but can be modified within the settings directory
            Resources:
                https://www.powershellgallery.com/packages/PSWriteHTML
                https://github.com/EvotecIT/PSWriteHTML
    Capabilities include:
        Multiple Queries to multiple endpoints
            Able to switch treeview between Method and Commands
                Method - Groups nodes by thier Protocols and Command Types
                    1) Endpoint Commands
                        [RPC]   Windows Management Instrumentation
                        [SMB]   Native Windows Commands
                        [SMB]   PowerShell Cmdlets
                        [SMB]   Windows Management Instrumentation
                        [WinRM] PowerShell Cmdlets
                        [WinRM] PowerShell Scripts
                        [WinRM] Windows Management Instrumentation
                    2) Active Drectory Commands
                        [RPC]   Windows Management Instrumentation
                        [SMB]   Native Windows Commands
                        [SMB]   PowerShell Cmdlets
                        [SMB]   Windows Management Instrumentation
                        [WinRM] PowerShell Cmdlets
                        [WinRM] PowerShell Scripts
                        [WinRM] Windows Management Instrumentation
                    3) Query History
                        Directory Save Name
                            *Populates history nodes of comamnds executed
                        *Able to delete selected history nodes if desired
                Commands - Groups nodes by their Command Names
                    1) Endpoint Commands
                        Processes
                        Services
                        ...etc
                    2) Active Directory Commands
                        Get-ADUser
                        Get-ADComputer
                        ...etc
                    3) Query History
                        Directory Save Name
                            *Populates history nodes of comamnds executed
                        *Able to delete selected history nodes if desired
            Easily update the Command TreeView
                Endpoints Agnostics
                    $PoShHome\Dependencies\Cmds & Scripts\Commands - Endpoint.csv
                    $PoShHome\Dependencies\Cmds & Scripts\Scripts-Host\<lots of scripts>
                Active Directory Specific
                    $PoShHome\Dependencies\Cmds & Scripts\Commands - Active Directory.csv
                    $PoShHome\Dependencies\Cmds & Scripts\Scripts-AD\<lots of scripts>
            WinRM Query Builder
                Uses Show-Command to vet command syntax
                Restricted to just Get commands by default
                Override - Allow other verbs to be able to execute other types of cmdlets
        Quick Investigations / Searches:
            Accounts
                Accounts logged in via Console
                Accounts logged in via PowerShell Session
                Account Logon Activity
                Collection Option:
                    Able to filter by start/end datetimes using calendar and time fields
            Windows Event Logs
                Event IDs Manual Entry
                    Enter one or more Event ID numbers for targeted searches
                    Includes a Select Event IDs feature for easy search
                Event IDs Quick Selection
                    Pre-defined groups of Event IDs
                Event IDs to Monitor
                    Event IDs recommended my Microsoft to investigate if suspicous activity is observered
                Collection Option:
                    Filter by start/end datetimes using calendar and time fields
                    Filter to collection a max numer of results
            Registry Search
                Search Registry one or multiple paths
                    Enter one or more entries
                    Provides simple to view and import example locations
                    Supports recurisve search
                Search by Key Name
                    Enter one or more entries
                    Supports regex and provides examples
                Search by Value Name
                    Enter one or more entries
                    Supports regex and provides examples
                Search by Value Data
                    Enter one or more entries
                    Supports regex and provides examples
                Provides regex examples
            File Search
                Directory Listing
                    Supports recursive search
                    Directory aware auto-complete
                        Uses localhost directory tree
                        Use for assistance, other directory locations that don't populate can be entered
                File Search by:
                    Supports recursive search
                    Enter one or more entries
                    Search by file name or file hash:
                        Filename
                        MD5, SHA1, SHA384, SHA256, SHA512, RIPEMD160
                Alternate Data Stream (ADS) Search with download and extract feature
                    Supports recursive search
                    Enter one or more entries
                    Retrieve Extraced Stream Data
            Network Connection Search
                Packet capture
                    Duration in seconds (default 60)
                    Maximum MegaBytes (default 50 MB)
                Remote IP
                    Enter one or more entries
                    Able to Select IPs from those located in the Computer TreeView
                Remote Port
                    Enter one or more entries
                    Able to search for protocol default ports and select ports
                Local Port
                    Enter one or more entries
                    Able to search for protocol default ports and select ports
                Process Name
                    Enter one or more entries
                    *Uses PID that owns the connection
                DNS Cache Entry
                    *This data is fairly volitile on the endpoints
        Multi-Endpoint Actions
            Process Killer
            Service Stopper
            Network Connection Killer
            Account Logout
            Quarantine / Un-Quarantine Endpoints
                Makes a local copy of the endpoints firewall rules
                Implements firwall rules to drop all connections except by those provided
                Interupts active connections
                Able to restrict comms to:
                    Single IP
                    IP Range
                    Subnet Range
            System Monitor (Sysmon) Deployment
                Able use WinRM or RPC
                Able to select sysmon config file
                Able to change the sysmon Process/Service name
                Able to change the sysmon driver name
            Process Monitor (Procmon) Capture
                Able to capture process data over a timespace (default 5 seconds)
                Able to change the procmon process name
            AutoRuns Data Pull
                Obtains more startup information than native WMI and Windows cmdlets
                Able to change the autoruns process name
            User specified files and custom script
                Allows for the custom deployable of executables and scripts
                Execution flow, cleanup, and retrieve of any files is not managed by PoSh-EasyWin
                Able to select directory or file
                Able to select user created script
                Able to specify just the script without dir/files
                Able to specify the destination folder
        Remote Sessions
            PSSession
            PSExec
        Remote Desktop
        Endpoint Packet Capture
        Windows Event Viewer
        Remote Memory Capture
        Storing and selecting credentials
        Tool Tip Help
            Mouse hover over various fields to view helpful data is balloon
            For the most part implemented, some areas are missing
    Visualization of collected data can be done by:
        Out-GridView : Built into PowerShell 
            Data is viewed in a light-weight spreadsheet style popup
            Supports searching and multiple filters
        PowerShell Terminal/Shell
            Data is imported into a shell from collected/saved .xml files
            Basic process of the data is done to provide simple statistics
            The `$results variable contains the collected data
        PowerShell Charts
            Requires PowerShell v3.0+
            Data can be viewed for numerous key collection types
            The chart type can be change and manipulated and earily searched 
            Able to eaily pivot Out-GridView, shell data, and multi-charts
        Grid Display via PSWriteHTML
            Requires PowerShell v5.1+
            Opens data in web brower to view data process to view as node with links in a grid
            Able to search for data in a spreadsheet format
            Can export/save images and data
    Collected data is saved to the localhost in the following formats:
        Comma Separated Values (.csv)
        Extensible Markup Language (.xml)
    Collected data is viewable in multiple ways:
        Opened in a spreadsheet format using PowerShell's Out-GridView
        Imported into a PowerShell terminal for command line manipulation and viewing
        Multiple Charts generated to quickly identify areas of interest
    TreeView data allows for easy management of data
        Computer TreeView
            Nodes can be displayed by Organizational Units or by Operating Systems
            Nodes selected will display addition details on endpoints
            Nodes can be imported from Active Directory, CSV Files, and Text Files
            Nodes can store user entered data unique to each endpoint
            Nodes are searchable and can be expanded to include Proceesses, Services, and Network Connections
        Command TreeView
            Nodes can be viewed by query Method or Commands
            Nodes selected will display additional notes and alternate commands
            Nodes can be modified by manipulated the source .csv file or adding/removing scripts
            Nodes are searchable
    It supports the following protocols:
        Windows Remote Management (WinRM)
        Remote Procedure Call / Distributed Component Object Model (RPC/DCOM)
        Server Message Block (SMB)
If the localhost is not joined to the domain
    Best practice is to have a firewall in place between the localhost and the endpoints
    If SysInternals' Sysmon is installed on the localhost, do not have the logs sent to an aggregated source
        Sysmon logs new process created and their command line arguments in Event ID 1
            PS> Get-WinEvent -FilterHashtable @{logname='Microsoft-Windows-Sysmon/Operational';id=1;}
        This means that credentials may be viewable by others
    If using WinRM, you may need to be added to the WSMAN trustedhosts on endpoints
        Add to trustedhosts [Option 1] Group Policy GUI
            1) Computer Configuration > Policies > Windows Settings > Security Settings > System Services > Windows Remote Management (WS-Management)
            2) Computer Configuration > Policies > Windows Settings > Security Settings > Windows Firewall with Advanced Security > Windows Firewall with Advanced Security > Inbound Rules > New Rule
            3) Computer Configuration > Policies > Administrative Templates: Policy Definitions (ADMX) > Windows Components > Windows Remote Management (WinRM) > WinRM Client > Trusted Hosts
            4) Computer Configuration > Policies > Administrative Templates: Policy Definitions (ADMX) > Windows Components > Windows Remote Management (WinRM) > WinRM Service > Allow remote server management through WinRM
            5) Computer Configuration > Policies > Administrative Templates: Policy Definitions (ADMX) > Windows Components > Windows PowerShell > Turn on Script Execution
            6) Computer Configuration > Preferences > Control Panel Settings > Services > New > Service
        Add to trustedhosts [Option 2] on each endpoint
            PS> Get-Item -Path WSMan:\localhost\Client\TrustedHosts
            PS> [newer]  Set-Item -Path WSMan:\localhost\Client\TrustedHosts '<IP Address,hostname, *.domain, or *>'
            PS> [legacy] winrm set winrm/config/client @{TrustedHosts='<IP Address,hostname, *.domain, or *>'}
    Resources:
        https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
        https://docs.microsoft.com/en-us/powershell/module/microsoft.wsman.management/about/about_wsman_provider?view=powershell-5.1
        https://techdirectarchive.com/2020/03/23/how-to-add-trusted-host-for-the-winrm-client/
        https://powershellpr0mpt.com/2015/08/03/configuring-powershell-remoting-through-gpo/
If the localhost is joined to the domain
    Use a host located within a secure subnet free from access by other endpoints within the network
    Use due diligence to ensure the localhost is free of malware
    The use of stored credentials is not necessary if PoSh-EasyWin is lauching with domain credentials
    The tool has better support for the Event Viewer feature
    If SysInternals' Sysmon is installed on the localhost, do not have the logs sent to an aggregated source
        Sysmon logs new process created and their command line arguments in Event ID 1
            PS> Get-WinEvent -FilterHashtable @{logname='Microsoft-Windows-Sysmon/Operational';id=1;}
        This means that credentials may be viewable by others
    Resources:
        https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
Tips in order to run PoSh-EasyWin:
    Scripts downloaded from the internet are blocked for execution as a security precaution
        You may have to use the Unblock-File cmdlet to be able to run the script
            PS> Get-ChildItem -Path C:\Path\To\PoSh-Easywin -Recurse | Unblock-File
    Set the execution policy [Option 1] Locally via command line
        Open a PowerShell terminal with admin privledges, then set the execution policy for the current process
            PS> Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
        Verify the execution policy
            PS> Get-ExecutionPolicy -List
    Set the execution policy [Option 2] Using Group Policy
        Open the GPO for editing. In the GPO editor, select:
            Computer Configuration > Policies > Administrative Templates > Windows Components > Windows PowerShell
            Right-click 'Turn on script execution', then select 'Edit'
            In the winodws that appears, click on 'Enabled' radio button
            Under 'Execution Policy', select 'Allow All Scripts'
            Click on 'Ok', then close the GPO Editor
            Push out GPO Updates, or on the computer's powershell/cmd terminal, type in 'gpupdate /force'
        Update the Group Policy on remote endpoints
            Right-click on the GPO > Select 'Group Policy Update'
            PS> Invoke-GPUpdate -Computer `$hostname
        Update the Group Policy locally - note that this will update all policies
            PS> gpupdate /force
            PS> Invoke-GPUpdate
    Congiure Windows Remote Management (WinRM) for use. It's primary protocol used and provides the best user experience
        How to enable PowerShell Remoting via command line
            PS> [newer]  Enable-PSRemoting -Force
            PS> [legacy] winrm quickconfig
        How to enable Powershell Remoting via Group Policy
            Launch the Group Policy Management Console (GPMC) then navigate to and do the following:
            1) Enable Windows Remote Management
                Computer Policies > Administrative Templates > Windows Components > Windows Remote Management (RM) > WinRM Service
                    Double-click Allow Remote Server Management Through WinRM Policy
                    Select the radio button next to Enabled
                    Make the appropriate entry into the IPv4 and IPv6 fields
            2) Configure Windows Firewall Settings
                Computer Policies > Windows Settings > Security Settings > Windows Firewall with Advanced Security
                    Expand the selection and right-click Incoming Connections, New Rule
                    The New Inbound Rule Wizard will appear
                    Select the radio button next to Predefined and from the drop-down menu
                    Select Windows Remote Management
                    Click Next to continue
                    Two predefined rules will be displayed on this screen
                    Select the Allow The Connection option
                    Click Finish to complete the configuration
            3) Configure Windows Remote Service
                Computer Policies > Windows Settings > Security Settings > System Services
                    Double-click the Windows Remote Management (WS-Management) service to configure the properties
                    In the new window that opens, select Automatic under Select Service Startup Mode
                    Check the Define This Policy Setting option
                Computer Policies > Preferences > Control Panel Settings > Services
                    Right-click it and select New | Service
                    Under the General Tab, select No Change from the drop-down menu next to Startup
                    Enter WinRM in the text box next to the Service Name
                    Select Start Service from the drop-down menu next to Service action
                    Under the Recovery Tab
                        Select 'Restart The Service' from the drop-down menu next to the First Failures
                        Select 'Restart The Service' from the drop-down menu next to the Second Failures
                        Select 'Restart The Service' from the drop-down menu next to the Subsequent Failures
                    Then click OK to save the settings changes
            Update the Group Policy on remote endpoints
                Right-click on the GPO > Select 'Group Policy Update'
                PS> Invoke-GPUpdate -Computer `$hostname
            Update the Group Policy locally - note that this will update all policies
                PS> gpupdate /force
                PS> Invoke-GPUpdate
        PowerShell Security - Module and Script Block Logging
            Computer Configuration > Policies > Administrative Templates > Windows Components > Windows PowerShell > 'Set PowerShell Script Module Logging' to 'Enabled'
            Computer Configuration > Policies > Administrative Templates > Windows Components > Windows PowerShell > 'Set PowerShell Script Block Logging' to 'Enabled'
    Resources:
        PS> Get-Help Unblock-File
        PS> Get-Help Set-ExecutionPolicy
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-5.1
        https://www.techrepublic.com/article/how-to-enable-powershell-remoting-via-group-policy/
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/unblock-file?view=powershell-5.1
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies?view=powershell-5.1
        https://activedirectorypro.com/update-group-policy-remote-computers/
PoSh-EasyWin supports the following protocols
    Depending on the protocol used, some have more capabilities than others
    Windows Remote Management (WinRM)
        Protocols: HTTP(WSMan), MIME, SOAP, XML
        Port
            5985/5986 (WinRM v2+)
            80 (WinRM v1)
            47001 (If a WinRM listener not created)
            Any (listeners can be configured on any port)
        Encrypted:
            Yes, HTTP  - message level encryption
            Yes, HTTPS - added TLS protocol encyption
        Operating Systems:
            Windows 7 and above
            Server 2008 R2 and above
            Older Operating Systems with WinRM installed
        Data:
            Deserialized Objects
        Pros:
            Single Port required
            Can establish sessions with endpoints
            Supports any cmdlet and native commands
        Cons:
            Requires WinRM service
            Many admins/networks disable this if not used
    Remote Procedure Call / Distributed Component Object Model (RPC/DCOM)
        Protocols: RPC/DCOM
        Encrypted: Not Encrypted (clear text)
        Ports:
            135
            Random High
        Operating Systems:
            Windows 2000 and above
        Data:
            PowerShell = Deserialized Objects
            Native CMD = Serialized Data
        Pros:
            Works with older Operating Systems
            Does not require WinRM
        Cons:
            Uses random high ports
            Not firewall friendly
            Transmits data in clear text
    Server Message Block (SMB)
        Protocols:
            SMB
            NetBIOS
        Encrypted:
            Yes: v3.0+
            No:  v1, v2, v2.1
        Ports:
            445
            139 (over NetBIOS)
        Operating Systems:
            Port 445 - Windows 2000 and above
        Data:
            Serialized Data Normally
            Deserialed Object (PoSh-EasyWin will convert the data)
        Pros:
            Works with older Operating Systems
            Access to domained and non-domained hosts
            Does not require WinRM or RPC
        Cons:
            Not natively supported, requires PSExec.exe
            Creates the service: PSEXEC
            May be blocked via Anti-Virus / Endpoint Security
            May be blocked via Application White/Black Listing
Best practice is to use two elevated credentials when conducting remote actions on endpoints with this tool:
    1) The primary credential is used to authenticate with endpoints and do the actual collection or execution task
    2) The other credential automatically rolls the password after the primary credential finishes
    Both accounts need to be created by the network administrator for use
    This mitigates the risk of credentials being stolen on compromised endpoints
    Credentials are rolled immediately within 3-5 seconds after completing queries and tasks:
        Completing queries using the WinRM, RPC, or SMB protocols
        Completing interaction tasks on endpoints such as:
            multi-endpoint process killing
            multi-endpoint service stopper
            sysmon deployment
            procmon collection
        When entering a PSSession or PSExec session
        Accessing endpoints with Remote Desktop
        Memory Collection using WinPmem
Credentials can be securely stored to the localhost
    The stored credentials are secured wtih Windows standard Data Protection API (DPAPI)
        DPAPI is a built-in way Windows users can use certificates to encrypt and decrypt information on the fly
        The stored credentials are saved using the Extensible Markup Language as .xml files
    The stored credentials can only be read, imported, and decrypted by the user that has they RSA key stored
        The DPAPI keys are created in part using the User's Security Identifer (SID)
        The RSA keys are stored on the localhost under %APPDATA%\Microsoft\Protect\{SID}
    Resources:
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-clixml?view=powershell-5.1
        https://powershellcookbook.com/recipe/PukO/securely-store-credentials-on-disk
Passing stored credentials to non-PowerShell applications on the localhost are done in plain text
    This occurs on the localhost when any of the following occurs:
        When entering a Remote Desktop Connection (RDP) session, which uses cmdkey.exe to pass credentials to mstsc.exe
        When using SysInternals' PSExec.exe to conduct the following over the Server Message Block (SMB) protocol
            Executing remote commands/queries on endpoints
            Entering into a session to conduct actions on an endpoint
        When entering a PSSession that is launched from a new terminal
            This is normally done securely, but isn't because of how this tool launches PSSessions in new terminals
    Stored credentials are passed securely when:
        Conducting Remot Procedure Call (RPC) queries
        Conducting Windows Remote Management (WinRM) queries
    If SysInternals' Sysmon is installed on the localhost, do not have the logs sent to an aggregated source
        Sysmon logs new process created and their command line arguments in Event ID 1
            PS> Get-WinEvent -FilterHashtable @{logname='Microsoft-Windows-Sysmon/Operational';id=1;}
        This means that credentials may be viewable by others
    Launching this tool with elevated credentials and not using stored credentials:
        The localhost needs to be joined to the domain
        No credentials are passed in plain text - features will use the privledges of the account that launched the tool
    Resources:
        https://devblogs.microsoft.com/scripting/use-powershell-to-pass-credentials-to-legacy-systems/
        https://docs.microsoft.com/en-us/sysinternals/downloads/psexec
        https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon"

foreach ($line in ($Acknowledgement -split "\n")) {
    if ($line -match '^\s{40}'){
        $newNode11 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode10.Nodes.Add($newNode11)
    }
    elseif ($line -match '^\s{36}'){
        $newNode10 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode9.Nodes.Add($newNode10)
    }
    elseif ($line -match '^\s{32}'){
        $newNode9 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode8.Nodes.Add($newNode9)
    }
    elseif ($line -match '^\s{28}'){
        $newNode8 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode7.Nodes.Add($newNode8)
    }
    elseif ($line -match '^\s{24}'){
        $newNode7 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode6.Nodes.Add($newNode7)
    }
    elseif ($line -match '^\s{20}'){
        $newNode6 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode5.Nodes.Add($newNode6)
    }
    elseif ($line -match '^\s{16}'){
        $newNode5 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode4.Nodes.Add($newNode5)
    }
    elseif ($line -match '^\s{12}'){
        $newNode4 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode3.Nodes.Add($newNode4)
    }
    elseif ($line -match '^\s{8}'){
        $newNode3 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode2.Nodes.Add($newNode3)

    }
    elseif ($line -match '^\s{4}'){
        $newNode2 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $newNode1.Nodes.Add($newNode2)

    }
    else {
        $newNode1 = New-Object System.Windows.Forms.TreeNode -Property @{
            Text = $line.trimstart(' ')
        }
        $AcknowledgeAllTreeNode.Nodes.Add($newNode1)
    }
}




# Do not sort the treeview, we want it in a specific order
#$AcknowledgeTreeView.Sort()

[System.Windows.Forms.TreeNodeCollection]$AllNodes = $AcknowledgeTreeView.Nodes
$AllNodes.ExpandAll()
foreach ($root in $AllNodes) {
    foreach ($Topic in $root.nodes){
        $Topic.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        $Topic.ForeColor = 'DarkRed' #[System.Drawing.Color]::FromArgb(0,0,0,224)
        foreach ($SubTopic in $Topic.nodes){
            $SubTopic.Collapse()
        }
    }
}

if (-not $ReadMe){
    function FormScaleButtonSettings {
        param($Button)
        $Button.ForeColor = "Black"
        $Button.Flatstyle = 'Flat'
        $Button.BackColor = 'LightGray'
        $Button.UseVisualStyleBackColor = $true
        $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
        $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
        $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray
    }


    $UserNoticeAcknowledgementCheckCancelButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'Cancel'
        Left = $AcknowledgeTreeView.Left
        Top  = $AcknowledgeTreeView.Top + $AcknowledgeTreeView.Height + ($FormScale * 5)
        AutoSize = $true
        Add_click = { 
            $UserNoticeAcknowledgementForm.Close() 
        }
    }
    $UserNoticeAcknowledgementForm.Controls.Add($UserNoticeAcknowledgementCheckCancelButton)
    FormScaleButtonSettings -Button $UserNoticeAcknowledgementCheckCancelButton


    $UserNoticeAcknowledgementCheckOkayButton = New-Object System.Windows.Forms.Button -Property @{
        Text   = 'I have read and understand the above information'
        Left   = $UserNoticeAcknowledgementCheckCancelButton.Left + $UserNoticeAcknowledgementCheckCancelButton.Width + 10
        Top    = $UserNoticeAcknowledgementCheckCancelButton.Top
        AutoSize = $true
        Add_Click = {
            $ProceedAfterAcknowledgement = $true
            [System.Windows.Forms.TreeNodeCollection]$AllNodes = $AcknowledgeTreeView.Nodes
            foreach ($root in $AllNodes) {
                foreach ($Topic in $root.nodes){
                    if ($Topic.checked -eq $false){ $ProceedAfterAcknowledgement = $false}
                }
            }
            if ($ProceedAfterAcknowledgement){
                Get-Date | Set-Content "$PoShHome\Settings\User Notice And Acknowledgement.txt"
                $UserNoticeAcknowledgementForm.Close()
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("Ensure to read and acknowledge all the topics by checkboxing the nodes with red text and turning them green. There is a lot of good information in there you should be aware of about this tool's operation.",'PoSh-EasyWin Notice & Acknowledgement')
            }
        }
    }
    $UserNoticeAcknowledgementForm.Controls.Add($UserNoticeAcknowledgementCheckOkayButton)
    FormScaleButtonSettings -Button $UserNoticeAcknowledgementCheckOkayButton
}

$UserNoticeAcknowledgementForm.ShowDialog()
}







