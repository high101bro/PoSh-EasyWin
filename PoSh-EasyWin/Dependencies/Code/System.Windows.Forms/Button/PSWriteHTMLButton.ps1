$PSWriteHTMLButtonAdd_Click = {
    ##########################################################################################################################
    ##########################################################################################################################
    # PSWriteHTML Form CheckedBoxList #
    ##########################################################################################################################
    ##########################################################################################################################

    $PSWriteHTMLForm = New-Object System.Windows.Forms.Form -Property @{
        Text            = "Graph Data Selection"
        StartPosition   = "CenterScreen"
        Width           = $FormScale * 300
        Height          = $FormScale * 200
        Icon            = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
        ShowIcon        = $true
        showintaskbar   = $false
        ControlBox      = $true
        MaximizeBox     = $false
        MinimizeBox     = $true
        AutoScroll      = $True
        Add_Load        = {}
        Add_Closing     = {}
    }


    $PSWriteHTMLCheckedListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
        Text   = "Select Data to Collect"
        Left   = $FormScale * 5
        Top    = $FormScale * 5
        Width  = $FormScale * 200
        Height = $FormScale * 125
        ScrollAlwaysVisible = $true
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_Click = {}
    }
    $PSWriteHTMLCheckedBoxList = @(
        'Active Directory Computers',
        'Active Directory Users & Groups',
        'Endpoint Network Connections',
        'Endpoint Console Logons',
        'Endpoint PowerShell Sessions',
        'Endpoint Process Data',
        'Endpoint Storage Data',
        'Endpoint RAM Data',
        'Endpoint CPU Data'
    )
    foreach ( $Query in $PSWriteHTMLCheckedBoxList ) { $PSWriteHTMLCheckedListBox.Items.Add($Query) }
    $PSWriteHTMLForm.Controls.Add($PSWriteHTMLCheckedListBox)


    $PSWriteHTMLGraphDataButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
        Text   = "Collect and Graph Data"
        Left   = $FormScale * 5
        Top    = $PSWriteHTMLCheckedListBox.Top + $PSWriteHTMLCheckedListBox.Height + $($FormScale * 5)
        Width  = $FormScale * 150
        Height = $FormScale * 22
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        Add_Click = { 
            if ($PSWriteHTMLCheckedListBox.CheckedItems.Count -gt 0) {
                $PSWriteHTMLForm.Close()
            }
            else {
                [System.Windows.Forms.MessageBox]::Show("Checkbox at least one to collect and graph data.")
            }
        }
    }
    $PSWriteHTMLForm.Controls.Add($PSWriteHTMLGraphDataButton)
    CommonButtonSettings -Button $PSWriteHTMLGraphDataButton

    $PSWriteHTMLForm.Showdialog()

    $PSWriteHTMLCheckedItemsList = @()
    foreach($Checked in $PSWriteHTMLCheckedListBox.CheckedItems) {
        $PSWriteHTMLCheckedItemsList += $Checked
    }








    #if ($PSWriteHTMLCheckedItemsList -match 'Active Directory'){
        $script:DomainControllerNameForm = New-Object System.Windows.Forms.Form -Property @{
            Text    = 'PoSh-EasyWin'
            Width   = $FormScale * 300
            Height  = $FormScale * 200
            StartPosition = "CenterScreen"
            TopMost = $false
            Icon    = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
            Font    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
            ShowIcon        = $true
            showintaskbar   = $false
            ControlBox      = $true
            MaximizeBox     = $false
            MinimizeBox     = $true
            AutoScroll      = $True
    
            Add_Closing = { $This.dispose() }
        }
    
        $script:PoShEasyWinIPToExcludeTextbox = New-Object System.Windows.Forms.TextBox -Property @{
            Text   = "<Enter a PoSh-EasyWin's IP to exclude>"
            Width  = $FormScale * 240
            Height = $FormScale * 22
            Left   = $FormScale * 5
            Top    = $FormScale * 5
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $script:DomainControllerNameForm.Controls.Add($script:PoShEasyWinIPToExcludeTextbox)
        if ((Test-Path "$PoShHome\Settings\PoSh-EasyWin's IP to Exclude.txt")){
            $script:PoShEasyWinIPToExcludeTextbox.text = Get-Content "$PoShHome\Settings\PoSh-EasyWin's IP to Exclude.txt"
        }


        $script:DomainControllerNameOkayTextBox = New-Object System.Windows.Forms.TextBox -Property @{
            Text   = '<Enter a Domain Controller hostname>'
            Width  = $script:PoShEasyWinIPToExcludeTextbox.Width
            Height = $script:PoShEasyWinIPToExcludeTextbox.Height
            Left   = $script:PoShEasyWinIPToExcludeTextbox.Left
            Top    = $script:PoShEasyWinIPToExcludeTextbox.Top + $script:PoShEasyWinIPToExcludeTextbox.Height + $($FormScale * 5)
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $script:DomainControllerNameForm.Controls.Add($script:DomainControllerNameOkayTextBox)
        if ((Test-Path "$PoShHome\Settings\Domain Controller Selected.txt")){
            $script:DomainControllerNameOkayTextBox.text = Get-Content "$PoShHome\Settings\Domain Controller Selected.txt"
        }

        $DomainControllerNameOkayButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Okay'
            Width  = $FormScale * 150
            Height = $FormScale * 22
            Left   = $script:DomainControllerNameOkayTextBox.Left
            Top    = $script:DomainControllerNameOkayTextBox.Top + $script:DomainControllerNameOkayTextBox.Height + $($FormScale * 5)
            Add_Click = {
                $script:PoShEasyWinIPToExcludeTextbox.text | Set-Content "$PoShHome\Settings\PoSh-EasyWin's IP to Exclude.txt"
                $script:PoShEasyWinIPAddress = $script:PoShEasyWinIPToExcludeTextbox.text

                #Checks if the computer entered is in the computer treeview  
                $ComputerNodeFound = $false
                [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
                foreach ($root in $AllHostsNode) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) { 
                            if ($Entry.Text -eq $script:DomainControllerNameOkayTextBox.text){
                                $ComputerNodeFound = $true 
                            }
                        }
                    }
                }
                
                if (-not $ComputerNodeFound) {
                    [System.Windows.Forms.MessageBox]::Show('The hostname entered was not found within the computer treeview.','PoSh-EasyWin','Ok','Warning')
                }
                else {
                    $script:DomainControllerComputerName = $script:DomainControllerNameOkayTextBox.text
                    $script:DomainControllerNameForm.close()
                }
            }
        }
        $script:DomainControllerNameForm.Controls.Add($DomainControllerNameOkayButton)
        CommonButtonSettings -Button $DomainControllerNameOkayButton
    
        $script:DomainControllerNameForm.ShowDialog()


        
<#
        switch ($ElevateShell) {
        'Yes'{
            if ($ShowTerminal) { Start-Process PowerShell.exe -Verb runAs -ArgumentList $ThisScript }
            else               { Start-Process PowerShell.exe -Verb runAs -ArgumentList $ThisScript -WindowStyle Hidden }
            exit
        }
        'No' {
            if ($ShowTerminal) { Start-Process PowerShell.exe -ArgumentList "$ThisScript -SkipEvelationCheck" }
            else               { Start-Process PowerShell.exe -ArgumentList "$ThisScript -SkipEvelationCheck" -WindowStyle Hidden }
            exit
        }
        'Cancel' {exit}
        }#>
    #}








    



    
    #################
    # Console Logon #
    #################
    $ConsoleLogonScriptBlock = {
        ## Find all sessions matching the specified username
        $quser = quser | Where-Object {$_ -notmatch 'SESSIONNAME'}

        $sessions = ($quser -split "`r`n").trim()

        foreach ($session in $sessions) {
            try {
                # This checks if the value is an integer, if it is then it'll TRY, if it errors then it'll CATCH
                [int]($session -split '  +')[2] | Out-Null

                [PSCustomObject]@{
                    PSComputerName = $env:COMPUTERNAME
                    UserName       = ($session -split '  +')[0].TrimStart('>')
                    SessionName    = ($session -split '  +')[1]
                    SessionID      = ($session -split '  +')[2]
                    State          = ($session -split '  +')[3]
                    IdleTime       = ($session -split '  +')[4]
                    LogonTime      = ($session -split '  +')[5]
                    CollectionType = 'ConsoleLogons'
                }
            }
            catch {
                [PSCustomObject]@{
                    PSComputerName = $env:COMPUTERNAME
                    UserName       = ($session -split '  +')[0].TrimStart('>')
                    SessionName    = ''
                    SessionID      = ($session -split '  +')[1]
                    State          = ($session -split '  +')[2]
                    IdleTime       = ($session -split '  +')[3]
                    LogonTime      = ($session -split '  +')[4]
                    CollectionType = 'ConsoleLogons'
                }
            }
        }
    }









    ################
    # Process Data #
    ################
    $ProcessesScriptblock = {
        $ErrorActionPreference = 'SilentlyContinue'
        $CollectionTime = Get-Date
        $Processes      = Get-WmiObject Win32_Process
        $Services       = Get-WmiObject Win32_Service

        # Get's Endpoint Network Connections associated with Process IDs
        $ParameterSets = (Get-Command Get-NetTCPConnection).ParameterSets | Select-Object -ExpandProperty Parameters
        if (($ParameterSets | ForEach-Object {$_.name}) -contains 'OwningProcess') {
            $NetworkConnections = Get-NetTCPConnection
        }
        else {
            $NetworkConnections = netstat -nao -p TCP
            $NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
                $line = $line -replace '^\s+',''
                $line = $line -split '\s+'
                $properties = @{
                    Protocol      = $line[0]
                    LocalAddress  = ($line[1] -split ":")[0]
                    LocalPort     = ($line[1] -split ":")[1]
                    RemoteAddress = ($line[2] -split ":")[0]
                    RemotePort    = ($line[2] -split ":")[1]
                    State         = $line[3]
                    ProcessId     = $line[4]
                }
                $Connection = New-Object -TypeName PSObject -Property $properties
                $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
                $Connection | Add-Member -MemberType NoteProperty 'OwningProcess'   $proc.ProcessId
                $Connection | Add-Member -MemberType NoteProperty 'ParentProcessId' $proc.ParentProcessId
                $Connection | Add-Member -MemberType NoteProperty 'Name'            $proc.Caption
                $Connection | Add-Member -MemberType NoteProperty 'ExecutablePath'  $proc.ExecutablePath
                $Connection | Add-Member -MemberType NoteProperty 'CommandLine'     $proc.CommandLine
                $Connection | Add-Member -MemberType NoteProperty 'PSComputerName'  $env:COMPUTERNAME
                if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                    $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                    $hash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                    $Connection | Add-Member -MemberType NoteProperty MD5 $($hash -replace "-","")
                }
                else {
                    $Connection | Add-Member -MemberType NoteProperty MD5 $null
                }
                $Connection
            }
            $NetworkConnections = $NetStat | Select-Object -Property PSComputerName,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,Name,OwningProcess,ProcessId,ParentProcessId,MD5,ExecutablePath,CommandLine
        }


        # Create Hashtable of all network processes and their PIDs
        $ProcessNamePid = @{}
        foreach ( $proc in $Processes ) {
            if ( $proc.ProcessID -notin $ProcessNamePid.keys ) {
                $ProcessNamePid[$proc.ProcessID] += $proc.ProcessName
            }
        }


        # Create Hashtable of all network processes and their PIDs
        $NetConnections = @{}
        foreach ( $Connection in $NetworkConnections ) {
            $connStr = "[$($Connection.State)] " + "$($Connection.LocalAddress)" + ";" + "$($Connection.LocalPort)" + " <--> " + "$($Connection.RemoteAddress)" + ";" + "$($Connection.RemotePort)" + " [$($Connection.CreationTime)]`n"
            if ( $Connection.OwningProcess -in $NetConnections.keys ) {
                if ( $connStr -notin $NetConnections[$Connection.OwningProcess] ) { $NetConnections[$Connection.OwningProcess] += $connStr }
            }
            else { $NetConnections[$Connection.OwningProcess] = $connStr }
        }


        # Create HashTable of services associated to PIDs
        $ServicePIDs = @{}
        foreach ( $svc in $Services ) {
            if ( $svc.ProcessID -notin $ServicePIDs.keys ) {
                $ServicePIDs[$svc.ProcessID] += "$($svc.name) [$($svc.Startmode) Start By $($svc.startname)]`n"
            }
        }


        # Create HashTable of Process Filepath's MD5Hash
        $MD5Hashtable = @{}
        foreach ( $Proc in $Processes ) {
            if ( $Proc.Path -and $Proc.Path -notin $MD5Hashtable.keys ) {
                $MD5Hashtable[$Proc.Path] += $(Get-FileHash -Path $Proc.Path -ErrorAction SilentlyContinue).Hash
            }
        }


        # Create HashTable of Process Filepath's Authenticode Signature Information
        $TrackPaths                     = @()
        $AuthenCodeSigStatus            = @{}
        $AuthenCodeSigSignerCertificate = @{}
        $AuthenCodeSigSignerCompany     = @{}
        foreach ( $Proc in $Processes ) {
            if ( $Proc.Path -notin $TrackPaths ) {
                $TrackPaths += $Proc.Path
                $AuthenCodeSig = Get-AuthenticodeSignature -FilePath $Proc.Path -ErrorAction SilentlyContinue
                if ( $Proc.Path -notin $AuthenCodeSigStatus.keys ) { $AuthenCodeSigStatus[$Proc.Path] += $AuthenCodeSig.Status }
                if ( $Proc.Path -notin $AuthenCodeSigSignerCertificate.keys ) { $AuthenCodeSigSignerCertificate[$Proc.Path] += $AuthenCodeSig.SignerCertificate.Thumbprint }
                if ( $Proc.Path -notin $AuthenCodeSigSignerCompany.keys ) { $AuthenCodeSigSignerCompany[$Proc.Path] += $AuthenCodeSig.SignerCertificate.Subject.split(',')[0].replace('CN=','').replace('"','') }
            }
        }


        function Get-ProcessTree {
            [CmdletBinding()]
            param(
                [string]$ComputerName = 'localhost', 
                $Processes,
                [int]$IndentSize = 5
            )
        
            $indentSize   = [Math]::Max(1, [Math]::Min(12, $indentSize))
            #$computerName = ($computerName, ".")[[String]::IsNullOrEmpty($computerName)]
            $PIDs         = $Processes | Select-Object -ExpandProperty ProcessId
            $Parents      = $Processes | Select-Object -ExpandProperty ParentProcessId -Unique
            $LiveParents  = $Parents   | Where-Object { $PIDs -contains $_ }
            $DeadParents  = Compare-Object -ReferenceObject $Parents -DifferenceObject $LiveParents `
                            | Select-Object -ExpandProperty InputObject
            $ProcessByParent = $Processes | Group-Object -AsHashTable ParentProcessId

            function Write-ProcessTree($Process, [int]$level = 0) {
                $EnrichedProcess       = Get-Process -Id $Process.ProcessId
                $indent                = New-Object String(' ', ($level * $indentSize))

                $ProcessID             = $Process.ProcessID
                $ParentProcessID       = $Process.ParentProcessID
                $ParentProcessName     = $ProcessNamePid[$Process.ParentProcessID]
                #$CreationDate          = $([Management.ManagementDateTimeConverter]::ToDateTime($Process.CreationDate))

                $ServiceInfo           = $ServicePIDs[$Process.ProcessId]

                $NetConns              = $($NetConnections[$Process.ProcessId]).TrimEnd("`n")
                $NetConnsCount         = if ($NetConns) {$($NetConns -split "`n").Count} else {[int]0}

                $MD5Hash               = $MD5Hashtable[$Process.Path]

                $StatusMessage         = $AuthenCodeSigStatus[$Process.Path]
                $SignerCertificate     = $AuthenCodeSigSignerCertificate[$Process.Path]
                $SignerCompany         = $AuthenCodeSigSignerCompany[$Process.Path]

                $Modules               = $EnrichedProcess.Modules.ModuleName
                $ModuleCount           = $Modules.count

                $ThreadCount           = $EnrichedProcess.Threads.count

                $Owner                 = $Process.GetOwner().Domain.ToString() + "\"+ $Process.GetOwner().User.ToString()
                $OwnerSID              = $Process.GetOwnerSid().Sid.ToString()
                $EnrichedProcess `
                | Add-Member NoteProperty 'Level'                  $level                    -PassThru -Force `
                | Add-Member NoteProperty 'ProcessID'              $ProcessID                -PassThru -Force `
                | Add-Member NoteProperty 'ProcessName'            $_.Name                   -PassThru -Force `
                | Add-Member NoteProperty 'ProcessNameIndented'    "$indent$($process.Name)" -PassThru -Force `
                | Add-Member NoteProperty 'ParentProcessID'        $ParentProcessID          -PassThru -Force `
                | Add-Member NoteProperty 'ParentProcessName'      $ParentProcessName        -PassThru -Force `
                | Add-Member NoteProperty 'CreationDate'           $CreationDate             -PassThru -Force `
                | Add-Member NoteProperty 'ServiceInfo'            $ServiceInfo              -PassThru -Force `
                | Add-Member NoteProperty 'NetworkConnections'     $NetConns                 -PassThru -Force `
                | Add-Member NoteProperty 'NetworkConnectionCount' $NetConnsCount            -PassThru -Force `
                | Add-Member NoteProperty 'StatusMessage'          $StatusMessage            -PassThru -Force `
                | Add-Member NoteProperty 'SignerCertificate'      $SignerCertificate        -PassThru -Force `
                | Add-Member NoteProperty 'SignerCompany'          $SignerCompany            -PassThru -Force `
                | Add-Member NoteProperty 'MD5Hash'                $MD5Hash                  -PassThru -Force `
                | Add-Member NoteProperty 'Modules'                $Modules                  -PassThru -Force `
                | Add-Member NoteProperty 'ModuleCount'            $ModuleCount              -PassThru -Force `
                | Add-Member NoteProperty 'ThreadCount'            $ThreadCount              -PassThru -Force `
                | Add-Member NoteProperty 'Owner'                  $Owner                    -PassThru -Force `
                | Add-Member NoteProperty 'OwnerSID'               $OwnerSID                 -PassThru -Force `
                | Add-Member NoteProperty 'Duration'               $(New-TimeSpan -Start $_.StartTime -End $CollectionTime) -PassThru -Force `
                | Add-Member NoteProperty 'MemoryUsage'            $(if    ($_.WorkingSet -gt 1GB) {"$([Math]::Round($_.WorkingSet/1GB, 2)) GB"}
                                                                    elseif ($_.WorkingSet -gt 1MB) {"$([Math]::Round($_.WorkingSet/1MB, 2)) MB"}
                                                                    elseif ($_.WorkingSet -gt 1KB) {"$([Math]::Round($_.WorkingSet/1KB, 2)) KB"}
                                                                    else                           {"$([Math]::Round($_.WorkingSet,     2)) Bytes"} ) -PassThru -Force

                $ProcessByParent.Item($ProcessID) `
                | Where-Object   { $_ } `
                | ForEach-Object { Write-ProcessTree $_ ($level + 1) }
            }
            $Processes `
            | Where-Object   { $_.ProcessId -ne 0 -and ($_.ProcessId -eq $_.ParentProcessId -or $DeadParents -contains $_.ParentProcessId) } `
            | ForEach-Object { Write-ProcessTree $_ }
        }
        Get-ProcessTree -Processes $Processes | Select-Object `
        ProcessName, Level, ProcessNameIndented, ProcessID, ParentProcessName, ParentProcessID, ServiceInfo,`
        StartTime, Duration, CPU, TotalProcessorTime, `
        NetworkConnections, NetworkConnectionCount, CommandLine, Path, `
        WorkingSet, MemoryUsage, `
        MD5Hash, SignerCertificate, StatusMessage, SignerCompany, Company, Product, ProductVersion, Description, `
        Modules, ModuleCount, Threads, ThreadCount, Handle, Handles, HandleCount, `
        Owner, OwnerSID, `
        @{n='CollectionType';e={'ProcessData'}}
    }





    #######################
    # Network Connections #
    #######################
    $NetworkConnectionsScriptBlock = {
        $NetworkConnections = netstat -nao -p TCP
        $NetStat = Foreach ($line in $NetworkConnections[4..$NetworkConnections.count]) {
            $line = $line -replace '^\s+',''
            $line = $line -split '\s+'
            $properties = @{
                Protocol      = $line[0]
                LocalAddress  = ($line[1] -split ":")[0]
                LocalPort     = ($line[1] -split ":")[1]
                RemoteAddress = ($line[2] -split ":")[0]
                RemotePort    = ($line[2] -split ":")[1]
                State         = $line[3]
                ProcessId     = $line[4]
            }
            $Connection = New-Object -TypeName PSObject -Property $properties
            $proc       = Get-WmiObject -query ('select * from win32_process where ProcessId="{0}"' -f $line[4])
            $Connection | Add-Member -MemberType NoteProperty OwningProcess $proc.ProcessId
            $Connection | Add-Member -MemberType NoteProperty ParentProcessId $proc.ParentProcessId
            $Connection | Add-Member -MemberType NoteProperty ProcessName $proc.Caption
            $Connection | Add-Member -MemberType NoteProperty ExecutablePath $proc.ExecutablePath
            $Connection | Add-Member -MemberType NoteProperty CommandLine $proc.CommandLine
            $Connection | Add-Member -MemberType NoteProperty PSComputerName $env:COMPUTERNAME
            if ($Connection.ExecutablePath -ne $null -AND -NOT $NoHash) {
                $MD5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $hash = [System.BitConverter]::ToString($MD5.ComputeHash([System.IO.File]::ReadAllBytes($proc.ExecutablePath)))
                $Connection | Add-Member -MemberType NoteProperty MD5 $($hash -replace "-","")
            }
            else {
                $Connection | Add-Member -MemberType NoteProperty MD5 $null
            }
            $Connection
        }
        $NetStat | Select-Object -Property PSComputerName, Protocol, LocalAddress, LocalPort, RemoteAddress, RemotePort, `
        State, Name, ProcessName, OwningProcess, ProcessId, ParentProcessId, MD5, ExecutablePath, CommandLine, `
        @{n='CollectionType';e={'NetworkConnections'}}
    }






    #######################
    # PowerShell Sessions #
    #######################
    $PowerShellSessionsScriptBlock = { 
        Get-WSManInstance -ResourceURI Shell -Enumerate |  `
        Select-Object @{n='PSComputerName';e={$env:Computername}}, ClientIP, Owner, ProcessId, State, ShellRunTime, ShellInactivity, `
        @{n='CollectionType';e={'PowerShellSessions'}} 
    }









    ###########
    # Storage #
    ###########
    $StorageDataScriptBlock = { 
        Get-WmiObject -Class Win32_LogicalDisk |
            Select-Object -Property @{n='PSComputerName';e={$env:computername}},
            @{n='Name';e={$_.DeviceID}},
            DeviceID, DriveType, VolumeName,
            @{Name     = 'DriveTypeName'
                Expression = {
                    if     ($_.DriveType -eq 0) {'Unknown'}
                    elseif ($_.DriveType -eq 1) {'No Root Directory'}
                    elseif ($_.DriveType -eq 2) {'Removeable Disk'}
                    elseif ($_.DriveType -eq 3) {'Local Drive'}
                    elseif ($_.DriveType -eq 4) {'Network Drive'}
                    elseif ($_.DriveType -eq 5) {'Compact Disc'}
                    elseif ($_.DriveType -eq 6) {'RAM Disk'}
                    else                        {'Error: Unknown'}
                }
            },
            @{n='FreeSpaceGB';e={"{0:N2}" -f ($_.FreeSpace /1GB)}},
            @{n="CapacityGB"; e={"{0:N2}" -f ($_.Size/1GB)}},
            @{n='CollectionType';e={'StorageData'}}
    }






    ##############################
    # RAM - Random Access Memory #
    ##############################
    $RAMDataScriptBlock = { 
        Get-WmiObject -Class Win32_PhysicalMemory | 
            Select-Object -Property Manufacturer,Name,Banklabel,Configuredclockspeed,
            Capacity,Serialnumber,PartNumber,DeviceLocator,
            @{n='CapacityGB';e={"{0:N2}" -f ($_.Capacity /1GB)}},
            @{n='PSComputerName';e={$env:Computername}},
            @{n='CollectionType';e={'RAMData'}} 
    }




    ################################
    # CPU - Central Processor Unit #
    ################################
    $CPUDataScriptBlock = {
        Get-WmiObject Win32_Processor | 
            Select-Object -Property LoadPercentage,NumberOfCores,NumberOfLogicalProcessors,
            Manufacturer,Name,Description,MaxClockSpeed,CurrentClockSpeed,Status,
            ProcessorID,PartNumber,
            @{n='PSComputerName';e={$env:Computername}},
            @{n='CollectionType';e={'CPUData'}} 
    }







    ##########################################################################################################################
    ##########################################################################################################################
    # Endpoint Data Collection #
    ##########################################################################################################################
    ##########################################################################################################################
    Generate-ComputerList

    if ($PSWriteHTMLCheckedItemsList -match 'Endpoint' -and $script:ComputerList.count -eq 0){
        [system.media.systemsounds]::Exclamation.play()
        [system.windows.forms.messagebox]::Show("Select one or more endpoints.")
    }
    elseif ($PSWriteHTMLCheckedItemsList -match 'Endpoint' -and $script:ComputerList.count -gt 0) {
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
            $PSSession = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential
            Create-LogEntry -LogFile $LogFile -Message "New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential"
        }
        else {
            $PSSession = New-PSSession -ComputerName $script:ComputerList 
            Create-LogEntry -LogFile $LogFile -Message "New-PSSession -ComputerName $script:ComputerList"
        }
    }






    $AllGraphData = @()

    if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Network Connections') {
        $EndpointDataNetworkConnections = Invoke-Command -ScriptBlock $NetworkConnectionsScriptBlock -Session $PSSession
        $NetworkConnectionEndpoints = $EndpointDataNetworkConnections | Select-Object PSComptuerName -Unique
        $AllGraphData += $EndpointDataNetworkConnections
    }
    if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Process Data') {
        $ProcessData = Invoke-Command -ScriptBlock $ProcessesScriptBlock -Session $PSSession
        $AllGraphData += $ProcessData
    }
    if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint PowerShell Sessions') {
        $EndpointDataPowerShellSessions = Invoke-Command -ScriptBlock $PowerShellSessionsScriptBlock -Session $PSSession
        $AllGraphData += $EndpointDataPowerShellSessions
    }
    if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Console Logons') {
        $EndpointDataConsoleLogons = Invoke-Command -ScriptBlock $ConsoleLogonScriptBlock -Session $PSSession
        $AllGraphData += $EndpointDataConsoleLogons
    }
    if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Storage Data') {
        $EndpointDataStorageData = Invoke-Command -ScriptBlock $StorageDataScriptBlock -Session $PSSession
        $AllGraphData += $EndpointDataStorageData
    }
    if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint RAM Data') {
        $EndpointDataRAMData = Invoke-Command -ScriptBlock $RAMDataScriptBlock -Session $PSSession
        $AllGraphData += $EndpointDataRAMData
    }
    if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint CPU Data') {
        $EndpointDataCPUData = Invoke-Command -ScriptBlock $CPUDataScriptBlock -Session $PSSession
        $AllGraphData += $EndpointDataCPUData
    }



    $PSSession | Remove-PSSession
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$PSSession | Remove-Session"










    ##########################################################################################################################
    ##########################################################################################################################
    # Active Directory Collection #
    ##########################################################################################################################
    ##########################################################################################################################

    $ActiveDirectoryComputersScriptBlock = { 
        Get-ADComputer -Filter * -Properties Name, OperatingSystem, CanonicalName, IPv4Address, IPv6Address, MACAddress,`
        OperatingSystemServicePack, OperatingSystemHotfix, Enabled, LogonCount, LastLogonDate, WhenCreated, WhenChanged, Location, DistinguishedName `
        | Select-Object Name, OperatingSystem, CanonicalName, IPv4Address, IPv6Address, MACAddress,`
        OperatingSystemServicePack, OperatingSystemHotfix, Enabled, LogonCount, LastLogonDate, WhenCreated, WhenChanged, Location, DistinguishedName, `
        @{n='CollectionType';e={'ADComputers'}} 
    } 
    $ActiveDirectoryUsersScriptBlock = { 
        $ADUsers = Get-ADUser -Filter * -Properties Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, `
        PasswordLastSet, PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive, SamAccountName
        
        $ADUsers | Select-Object Name, SID, Enabled, LockedOut, Created, Modified, LastLogonDate, LastBadPasswordAttempt, BadLogonCount, PasswordLastSet, `
        PasswordExpired, PasswordNeverExpires, PasswordNotRequired, CanonicalName, MemberOf, SmartCardLogonRequired, ScriptPath, HomeDrive, SamAccountName, `
        @{n='CollectionType';e={'ADUsers'}}

        $ADUserList = $ADUsers | Select-Object -Property SamAccountName, SID
        foreach ($Account in $ADUserList) {
            Get-ADPrincipalGroupMembership -Identity $Account.SamAccountName `
            | Add-Member -MemberType NoteProperty SamAccountName $Account.SamAccountName -Force -PassThru `
            | Select-Object -Property SamAccountName, @{n="GroupName";e={$_.Name}}, @{n='AccountSID';e={$Account.SID}}, @{n='GroupSID';e={$_.SID}}, GroupCategory, GroupScope, DistinguishedName, @{n='CollectionType';e={'ADGroup'}}
        } 
    } 








    if ($PSWriteHTMLCheckedItemsList -match 'Active Directory'){
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
            $PSSession = New-PSSession -ComputerName $script:DomainControllerComputerName -Credential $script:Credential
            Create-LogEntry -LogFile $LogFile -Message "New-PSSession -ComputerName $script:DomainControllerComputerName -Credential $script:Credential"
        }
        else {
            $PSSession = New-PSSession -ComputerName $script:DomainControllerComputerName
            Create-LogEntry -LogFile $LogFile -Message "New-PSSession -ComputerName $script:DomainControllerComputerName"
        }
    }







    if ($PSWriteHTMLCheckedItemsList -contains 'Active Directory Computers') {
        $ActiveDirectoryComputers = Invoke-Command -ScriptBlock $ActiveDirectoryComputersScriptBlock -Session $PSSession
        $AllGraphData += $ActiveDirectoryComputers
    }
    if ($PSWriteHTMLCheckedItemsList -contains 'Active Directory Users & Groups') {
        $ActiveDirectoryUsers = Invoke-Command -ScriptBlock $ActiveDirectoryUsersScriptBlock -Session $PSSession
        $AllGraphData += $ActiveDirectoryUsers
    }







    $PSSession | Remove-PSSession
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$PSSession | Remove-Session"







    if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
        Start-Sleep -Seconds 3
        Generate-NewRollingPassword
    }































































        ##########################################################################################################################
        ##########################################################################################################################
        # Generate PSWriteHTML Graphs
        ##########################################################################################################################
        ##########################################################################################################################
        #$AllGraphData | ogv
        if ($AllGraphData) {
        New-HTML -TitleText 'Hunt the Bad Stuff' -Online -FilePath "PSScriptRoot\Hunt the Bad Stuff.html" {
            New-HTMLSection -HeaderText 'All Data - Spreadsheet' -CanCollapse -Collapsed {
                New-HTMLTable -DataTable ($AllGraphData)
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Network Connections') {
                New-HTMLSection -HeaderText 'Network Connections - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($EndpointDataNetworkConnections)
                }
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Process Data') {
                New-HTMLSection -HeaderText 'Process Data - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($ProcessData)
                }
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Console Logons') {
                New-HTMLSection -HeaderText 'Console Logons - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($EndpointDataConsoleLogons)
                }
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint PowerShell Sessions') {
                New-HTMLSection -HeaderText 'PowerShell Sessions - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($EndpointDataPowerShellSessions)
                }
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Storage Data') {
                New-HTMLSection -HeaderText 'Storage Data - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($EndpointDataStorageData)
                }
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint RAM Data') {
                New-HTMLSection -HeaderText 'RAM Data - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($EndpointDataRAMData)
                }
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint CPU Data') {
                New-HTMLSection -HeaderText 'CPU Data - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($EndpointDataCPUData)
                }
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Active Directory Computers') {
                New-HTMLSection -HeaderText 'Active Directory Computers - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($ActiveDirectoryComputers)
                }
            }
            if ($PSWriteHTMLCheckedItemsList -contains 'Active Directory Users & Groups') {
                New-HTMLSection -HeaderText 'Active Directory Users & Groups - Spreadsheet' -CanCollapse -Collapsed {
                    New-HTMLTable -DataTable ($ActiveDirectoryUsers)
                }
            }

            New-HTMLSection -HeaderText 'PoSh-EasyWin - Graph The Data' -CanCollapse {
                New-HTMLPanel {
                    New-HTMLDiagram -Height '1000px' {
                        New-DiagramOptionsInteraction
                        New-DiagramOptionsManipulation
                        New-DiagramOptionsPhysics
                        New-DiagramOptionsLayout `
                            -RandomSeed 13
                        New-DiagramOptionsNodes `
                            -BorderWidth 1 `
                            -ColorBackground LightSteelBlue `
                            -ColorHighlightBorder Orange `
                            -ColorHoverBackground Organe
                        New-DiagramOptionsLinks `
                            -ColorHighlight Orange `
                            -ColorHover Orange
                        New-DiagramOptionsEdges `
                            -ColorHighlight Orange `
                            -ColorHover Orange





                        $NIClist  = @()
                        $OuCnList = @()
                        $ADGroups = @()

                        foreach ($object in $AllGraphData) {
                            ######################################################
                            if ($object.CollectionType -eq 'NetworkConnections') {
                            ######################################################
                                if ($object.state -match 'Establish'){
                                    if ($object.LocalAddress -notin $NIClist) {
                                        New-DiagramNode `
                                            -Label  $object.PSComputerName `
                                            -To     $object.LocalAddress `
                                            -Image  "$Dependencies\Images\Computer.jpg" `
                                            -Size   25 `
                                            -FontSize   20 `
                                            -FontColor  Blue `
                                            -LinkColor  DarkBlue `
                                            -ArrowsToEnabled
                                        $NIClist += $object.LocalAddress
                                    }                            
                                    New-DiagramNode `
                                        -Label  $object.LocalAddress `
                                        -To     "[$($Object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)`n($($object.State))" `
                                        -Image  "$Dependencies\Images\NIC.jpg" `
                                        -Size   20 `
                                        -LinkColor Blue `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "[$($Object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)`n($($object.State))" `
                                        -To     "$($object.LocalAddress):$($object.LocalPort)" `
                                        -Image  "$Dependencies\Images\Process.jpg" `
                                        -size   15 `
                                        -LinkColor Blue `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "$($object.LocalAddress):$($object.LocalPort)" `
                                        -To     "$($object.RemoteAddress):$($object.RemotePort)" `
                                        -shape  dot `
                                        -size   10 `
                                        -ColorBorder      Blue `
                                        -ColorBackground  LightSteelBlue `
                                        -LinkColor        Blue `
                                        -ArrowsToEnabled
                                    if ($object.RemoteAddress -eq $script:PoShEasyWinIPAddress) {
                                        New-DiagramNode `
                                            -Label  "$($object.RemoteAddress):$($object.RemotePort)" `
                                            -To     $object.RemoteAddress `
                                            -Image  "$Dependencies\Images\favicon.ico" `
                                            -size   10 `
                                            -ColorBorder      Blue `
                                            -ColorBackground  LightSteelBlue `
                                            -LinkColor        Blue `
                                            -ArrowsToEnabled
                                    }
                                    else {
                                        New-DiagramNode `
                                            -Label  "$($object.RemoteAddress):$($object.RemotePort)" `
                                            -To     $object.RemoteAddress `
                                            -shape  dot `
                                            -size   10 `
                                            -ColorBorder      Blue `
                                            -ColorBackground  LightSteelBlue `
                                            -LinkColor        Blue `
                                            -ArrowsToEnabled
                                    }

                                    if ($object.RemoteAddress -ne $script:PoShEasyWinIPAddress) {
                                        New-DiagramNode `
                                            -Label  $object.RemoteAddress `
                                            -Image  "$Dependencies\Images\NIC.jpg" `
                                            -size   20 `
                                            -LinkColor Blue `
                                            -ArrowsToEnabled
                                    }                                 
                                }
                                elseif ($object.state -match 'Listen'){
                                    New-DiagramNode `
                                        -Label  $object.PSComputerName `
                                        -To     "[$($Object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)`n($($object.State))" `
                                        -Image  "$Dependencies\Images\Computer.jpg" `
                                        -Size   25 `
                                        -FontSize   20 `
                                        -FontColor  Blue `
                                        -LinkColor Orange `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "[$($Object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)`n($($object.State))" `
                                        -To     "[$($Object.PSComputerName)]`n$($object.LocalAddress):$($object.LocalPort)" `
                                        -Image  "$Dependencies\Images\Process.jpg" `
                                        -size   15 `
                                        -LinkColor Orange `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "[$($Object.PSComputerName)]`n$($object.LocalAddress):$($object.LocalPort)" `
                                        -shape  dot `
                                        -size   10 `
                                        -ColorBorder      Orange `
                                        -ColorBackground  Yellow `
                                        -LinkColor        Orange `
                                        -ArrowsToEnabled
                                }
                                else {
                                    if ($object.LocalAddress -notin $NIClist) {
                                        New-DiagramNode `
                                            -Label  $object.PSComputerName `
                                            -To     $object.LocalAddress `
                                            -Image  "$Dependencies\Images\Computer.jpg" `
                                            -Size   25 `
                                            -FontSize   20 `
                                            -FontColor  Blue `
                                            -LinkColor  DarkViolet `
                                            -ArrowsToEnabled
                                        $NIClist += $object.LocalAddress
                                    }                            
                                    New-DiagramNode `
                                        -Label  $object.LocalAddress `
                                        -To     "[$($Object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)`n($($object.State))" `
                                        -Image  "$Dependencies\Images\NIC.jpg" `
                                        -Size   20 `
                                        -LinkColor DarkViolet `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "[$($Object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)`n($($object.State))" `
                                        -To     "$($object.LocalAddress):$($object.LocalPort)" `
                                        -Image  "$Dependencies\Images\Process.jpg" `
                                        -size   15 `
                                        -LinkColor DarkViolet `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "$($object.LocalAddress):$($object.LocalPort)" `
                                        -To     "$($object.RemoteAddress):$($object.RemotePort)" `
                                        -shape  dot `
                                        -size   10 `
                                        -ColorBorder      DarkViolet `
                                        -ColorBackground  Violet `
                                        -LinkColor        DarkViolet `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "$($object.RemoteAddress):$($object.RemotePort)" `
                                        -To     $object.RemoteAddress `
                                        -shape  dot `
                                        -size   10 `
                                        -ColorBorder      DarkViolet `
                                        -ColorBackground  Violet `
                                        -LinkColor        DarkViolet `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  $object.RemoteAddress `
                                        -Image  "$Dependencies\Images\NIC.jpg" `
                                        -size   20 `
                                        -LinkColor DarkViolet `
                                        -ArrowsToEnabled
                                }   
                            }





                            ###############################################
                            if ($object.CollectionType -eq 'ProcessData') {
                            ###############################################
                                if ($object.level -eq 0) {
                                    New-DiagramNode `
                                        -Label  $object.PSComputerName `
                                        -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                        -Image  "$Dependencies\Images\Computer.jpg" `
                                        -Size   25 `
                                        -FontSize   20 `
                                        -FontColor  Blue `
                                        -LinkColor  Pink `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                        -Image  "$Dependencies\Images\Process.jpg" `
                                        -size   15 `
                                        -LinkColor  Pink `
                                        -ArrowsToEnabled
                                        
                                    if ($object.NetworkConnections) {
                                        foreach ($conn in $($object.NetworkConnections -split "`n")){
                                            if ($conn -match 'Establish') {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      Red `
                                                    -ColorBackground  LightCoral `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                            elseif ($conn -match 'Listen') {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      Orange `
                                                    -ColorBackground  Yellow `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                            else {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      DarkViolet `
                                                    -ColorBackground  Violet `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                        }
                                    }
                                }
                                elseif ($object.level -gt 0) {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                        -To     "[$($object.PSComputerName)]`n$($object.ParentProcessName)`nPID:$($object.ParentProcessID)" `
                                        -Image  "$Dependencies\Images\Process.jpg" `
                                        -size   15 `
                                        -LinkColor  Pink `
                                        -ArrowsFromEnabled
                                    if ($object.ServiceInfo) {
                                        New-DiagramNode `
                                            -Label  "[$($object.PSComputerName)]`nService: $(($object.ServiceInfo -split ' ')[0])`n$((($object.ServiceInfo -split ' ')[1..$object.ServiceInfo.length] -join ' ') -replace '[','' -replace ']','')" `
                                            -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                            -Shape  triangle `
                                            -size   10 `
                                            -ColorBackground  Cyan `
                                            -LinkColor        Pink `
                                            -ArrowsFromEnabled
                                    }
                                    if ($object.NetworkConnections) {
                                        foreach ($conn in $($object.NetworkConnections -split "`n")){
                                            if ($conn -match 'Establish') {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      Red `
                                                    -ColorBackground  LightCoral `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                            elseif ($conn -match 'Listen') {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      Orange `
                                                    -ColorBackground  Yellow `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                            else {
                                                New-DiagramNode `
                                                    -Label  "$(($conn -replace ';',':' -split ' ')[0])`n$(($conn -replace ';',':' -split ' ')[1..$conn.length] -join ' ')" `
                                                    -To     "[$($object.PSComputerName)]`n$($object.ProcessName)`nPID:$($object.ProcessID)" `
                                                    -Shape  dot `
                                                    -size   10 `
                                                    -BorderWidth      1 `
                                                    -ColorBorder      DarkViolet `
                                                    -ColorBackground  Violet `
                                                    -LinkColor        Pink `
                                                    -ArrowsFromEnabled
                                            }
                                        }
                                    }
                                }
                            }
                            





                            ###############################################################
                            if ($object.CollectionType -eq 'ConsoleLogons') {
                            ###############################################################
                                New-DiagramNode `
                                    -Label  $object.PSComputerName `
                                    -To     "[$($object.PSComputerName)]`nState: $($object.State)`n($($object.LogonTime))" `
                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                    -Size   25 `
                                    -FontSize   20 `
                                    -FontColor  Blue `
                                    -ArrowsFromEnabled
                                New-DiagramNode `
                                    -Label  "[$($object.PSComputerName)]`nState: $($object.State)`n($($object.LogonTime))" `
                                    -To     "[$($object.PSComputerName)]`nConsole Logon`nState: $($object.State)" `
                                    -Image  "$Dependencies\Images\Clock.jpg" `
                                    -Size   25 `
                                    -ArrowsFromEnabled
                                New-DiagramNode `
                                    -Label  "[$($object.PSComputerName)]`nConsole Logon`nState: $($object.State)" `
                                    -To     "[$($object.PSComputerName)]`nAccount: $($object.UserName)" `
                                    -Image  "$Dependencies\Images\Console.jpg" `
                                    -Size   25 `
                                    -ArrowsFromEnabled
                                New-DiagramNode `
                                    -Label  "[$($object.PSComputerName)]`nAccount: $($object.UserName)" `
                                    -Image  "$Dependencies\Images\User.jpg" `
                                    -Size   20 `
                                    -ArrowsFromEnabled
                            }







                            ###############################################################
                            if ($object.CollectionType -eq 'PowerShellSessions') {
                            ###############################################################
                                New-DiagramNode `
                                    -Label  $object.PSComputerName `
                                    -To     "[$($object.PSComputerName)]`nAccount: $($object.Owner)`nPID: $($object.ProcessID)" `
                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                    -Size   25 `
                                    -FontSize   20 `
                                    -FontColor  Blue `
                                    -LinkColor  Blue `
                                    -ArrowsToEnabled
                                New-DiagramNode `
                                    -Label  "[$($object.PSComputerName)]`nAccount: $($object.Owner)`nPID: $($object.ProcessID)" `
                                    -To     "[$($object.PSComputerName)]`nPowerShell Session`nState: $($object.State)`nPID: $($object.ProcessID)" `
                                    -Image  "$Dependencies\Images\User.jpg" `
                                    -Size   20 `
                                    -LinkColor  Blue `
                                    -ArrowsToEnabled

                                if ($object.State -eq 'Connected'){
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nPowerShell Session`nState: $($object.State)`nPID: $($object.ProcessID)" `
                                        -To     "[$($object.PSComputerName)]`nState: $($object.State)`n($($object.ShellRunTime))" `
                                        -Image  "$Dependencies\Images\PowerShell.jpg" `
                                        -Size   25 `
                                        -ColorBorder Green `
                                        -LinkColor   Blue `
                                        -ArrowsToEnabled
                                }
                                elseif ($object.State -eq 'Disconnected'){
                                    New-DiagramNode `
                                        -Label  "$($object.State)`nPID: $($object.ProcessID)" `
                                        -To     "[$($object.PSComputerName)]`nState: $($object.State)`n($($object.ShellRunTime))" `
                                        -Image  "$Dependencies\Images\PowerShell.jpg" `
                                        -Size   25 `
                                        -ColorBorder Orange `
                                        -LinkColor   Blue `
                                        -ArrowsToEnabled
                                }
                                else {
                                    New-DiagramNode `
                                        -Label  "$($object.State)`nPID: $($object.ProcessID)" `
                                        -To     "[$($object.PSComputerName)]`nState: $($object.State)`n($($object.ShellRunTime))" `
                                        -Image  "$Dependencies\Images\PowerShell.jpg" `
                                        -Size   25 `
                                        -LinkColor  Blue `
                                        -ArrowsToEnabled
                                }
                                New-DiagramNode `
                                    -Label  "[$($object.PSComputerName)]`nState: $($object.State)`n($($object.ShellRunTime))" `
                                    -To     "$($object.ClientIP)" `
                                    -Image  "$Dependencies\Images\Clock.jpg" `
                                    -Size   25 `
                                    -LinkColor  Blue `
                                    -ArrowsToEnabled

                                New-DiagramNode `
                                    -Label  $object.ClientIP `
                                    -Image  "$Dependencies\Images\NIC.jpg" `
                                    -Size   20
                            }















































                            ###############################################################
                            if ($object.CollectionType -eq 'StorageData') {
                            ###############################################################
                                New-DiagramNode `
                                    -Label  $object.PSComputerName `
                                    -To     "[$($object.PSComputerName)]`nDevice ID: $($object.Name)`nType: $($object.DriveTypeName)`nCapacity: $($object.CapacityGB)GB`nFree Space: $($object.FreeSpaceGB)GB" `
                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                    -Size   25 `
                                    -FontSize   20 `
                                    -LinkColor  Green `
                                    -FontColor  Blue

                                if     ($object.DriveTypeName -eq 'Local Drive')    { $StorageImage = "$Dependencies\Images\LocalDisk.jpg" }
                                elseif ($object.DriveTypeName -eq 'Removeable Disk'){ $StorageImage = "$Dependencies\Images\USB.jpg" }
                                elseif ($object.DriveTypeName -eq 'Compact Disc')   { $StorageImage = "$Dependencies\Images\CD.jpg" }
                                else   { $StorageImage = "$Dependencies\Images\Storage.jpg" }

                                if ((($object.CapacityGB - $object.FreeSpaceGB) / $object.CapacityGB) -gt 0.9 ) {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nDevice ID: $($object.Name)`nType: $($object.DriveTypeName)`nCapacity: $($object.CapacityGB)GB`nFree Space: $($object.FreeSpaceGB)GB" `
                                        -Image  $StorageImage `
                                        -size   25 `
                                        -LinkColor  Green `
                                        -FontColor  Red
                                }
                                elseif ((($object.CapacityGB - $object.FreeSpaceGB) / $object.CapacityGB) -gt 0.75 ) {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nDevice ID: $($object.Name)`nType: $($object.DriveTypeName)`nCapacity: $($object.CapacityGB)GB`nFree Space: $($object.FreeSpaceGB)GB" `
                                        -Image  $StorageImage `
                                        -size   25 `
                                        -LinkColor  Green `
                                        -FontColor  LightCoral
                                }
                                elseif ((($object.CapacityGB - $object.FreeSpaceGB) / $object.CapacityGB) -gt 0.50 ) {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nDevice ID: $($object.Name)`nType: $($object.DriveTypeName)`nCapacity: $($object.CapacityGB)GB`nFree Space: $($object.FreeSpaceGB)GB" `
                                        -Image  $StorageImage `
                                        -size   25 `
                                        -LinkColor  Green `
                                        -FontColor  DarkOrange
                                }
                                else {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nDevice ID: $($object.Name)`nType: $($object.DriveTypeName)`nCapacity: $($object.CapacityGB)GB`nFree Space: $($object.FreeSpaceGB)GB" `
                                        -Image  $StorageImage `
                                        -size   25 `
                                        -LinkColor  Green `
                                        -FontColor  DarkGreen
                                }
                            }
                            ###############################################################
                            if ($object.CollectionType -eq 'RAMData') {
                            ###############################################################
                                New-DiagramNode `
                                    -Label  $object.PSComputerName `
                                    -To     "[$($object.PSComputerName)]`nBank Label: $($object.BankLabel)`nCapacity: $($object.CapacityGB)GB" `
                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                    -Size   25 `
                                    -FontSize   20 `
                                    -LinkColor  Green `
                                    -FontColor  Blue
                                New-DiagramNode `
                                    -Label  "[$($object.PSComputerName)]`nBank Label: $($object.BankLabel)`nCapacity: $($object.CapacityGB)GB" `
                                    -Image  "$Dependencies\Images\RAM.jpg" `
                                    -size   25 
                            }
                            ###############################################################
                            if ($object.CollectionType -eq 'CPUData') {
                            ###############################################################
                                New-DiagramNode `
                                    -Label  $object.PSComputerName `
                                    -To     "[$($object.PSComputerName)]`nCores/Processors: $($object.NumberOfCores)/$($object.NumberOfLogicalProcessors)`nCPU Load: $($object.LoadPercentage)%" `
                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                    -Size   25 `
                                    -FontSize   20 `
                                    -LinkColor  Green `
                                    -FontColor  Blue
                                if ($object.LoadPercentage -gt 90) {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nCores/Processors: $($object.NumberOfCores)/$($object.NumberOfLogicalProcessors)`nCPU Load: $($object.LoadPercentage)%" `
                                        -Image  "$Dependencies\Images\CPU.jpg" `
                                        -size   25 `
                                        -LinkColor  Green `
                                        -FontColor  Red
                                }
                                elseif ($object.LoadPercentage -gt 75) {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nCores/Processors: $($object.NumberOfCores)/$($object.NumberOfLogicalProcessors)`nCPU Load: $($object.LoadPercentage)%" `
                                        -Image  "$Dependencies\Images\CPU.jpg" `
                                        -size   25 `
                                        -LinkColor  Green `
                                        -Fontcolor  LightCoral
                                }
                                elseif ($object.LoadPercentage -gt 50) {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nCores/Processors: $($object.NumberOfCores)/$($object.NumberOfLogicalProcessors)`nCPU Load: $($object.LoadPercentage)%" `
                                        -Image  "$Dependencies\Images\CPU.jpg" `
                                        -size   25 `
                                        -LinkColor  Green `
                                        -Fontcolor  DarkOrange
                                }
                                else {
                                    New-DiagramNode `
                                        -Label  "[$($object.PSComputerName)]`nCores/Processors: $($object.NumberOfCores)/$($object.NumberOfLogicalProcessors)`nCPU Load: $($object.LoadPercentage)%" `
                                        -Image  "$Dependencies\Images\CPU.jpg" `
                                        -size   25 `
                                        -LinkColor  Green `
                                        -Fontcolor  DarkGreen
                                }
                            }
































                            

                            ######################################################
                            if ($object.CollectionType -eq 'ADComputers') {
                            ######################################################    
                                $OuCn = ($object.DistinguishedName -split ',')[1..$object.DistinguishedName.length] -join ','
                                
                                $Level = 0
                                $OrgUnit = $object.DistinguishedName -split ','
                          
                                foreach ($OU in $OrgUnit) {
                                    $OrgUnit[0..$Level] -join ','
                                    $Level += 1
                                    if ("Active Directory" -notin $OuCnList) {
                                        $OuCnList += "Active Directory"
                                        New-DiagramNode `
                                            -Label  "Active Directory" `
                                            -To     "$($OrgUnit[-1])" `
                                            -Image  "$Dependencies\Images\ActiveDirectory.jpg" `
                                            -Size   35 `
                                            -BorderWidth 2 `
                                            -ArrowsFromEnabled  
                                    }    
                                    elseif ("$($OrgUnit[$Level..$OrgUnit.Length])" -notin $OuCnList) {
                                        $OuCnList += "$($OrgUnit[$Level..$OrgUnit.Length])"
                                        New-DiagramNode `
                                            -Label  "$($OrgUnit[$Level..$OrgUnit.Length] -join ',')" `
                                            -To     "$($OrgUnit[$($Level + 1)..$OrgUnit.Length] -join ',')" `
                                            -Image  "$Dependencies\Images\OrganizationalUnit.jpg" `
                                            -Size   30 `
                                            -ArrowsToEnabled
                                    }
                                }
                                
                                New-DiagramNode `
                                    -Label  $OuCn `
                                    -To     $object.Name `
                                    -Image  "$Dependencies\Images\OrganizationalUnit.jpg" `
                                    -Size   30 `
                                    -ArrowsFromEnabled

                                New-DiagramNode `
                                    -Label  $object.Name `
                                    -Image  "$Dependencies\Images\Computer.jpg" `
                                    -size   25

                                if ($PSWriteHTMLCheckedItemsList -contains 'Endpoint Network Connections') {
                                    if ($object.Name -in $NetworkConnectionEndpoints -and $object.IPv4Address -ne $script:PoShEasyWinIPAddress) {
                                        New-DiagramNode `
                                            -Label  $object.IPv4Address `
                                            -To     $object.Name
                                            -shape  hexagon `
                                            -Size   10 `
                                            -ArrowsFromEnabled
                                    }
                                }
                            }



                            ######################################################
                            if ($object.CollectionType -eq 'ADGroup') {
                            ######################################################    
                                #if ($object.Group -ne 'Domain Computers') {
                                    New-DiagramNode `
                                        -Label  $object.SamAccountName `
                                        -To     "[$($object.SamAccountName)]`nGroup: $($object.GroupName)`nSID: $($object.GroupSID)" `
                                        -Image  "$Dependencies\Images\User.jpg" `
                                        -Size   20 `
                                        -ArrowsToEnabled
                                    New-DiagramNode `
                                        -Label  "[$($object.SamAccountName)]`nGroup: $($object.GroupName)`nSID: $($object.GroupSID)" `
                                        -Image  "$Dependencies\Images\Group.jpg" `
                                        -Size   15
                                #}
                            }
                            #>
                            <#
                            ######################################################
                            if ($object.CollectionType -eq 'ADUsers') {
                            ######################################################    
                                New-DiagramNode `
                                    -Label  "[Active Directory]`n$($OuCn)" `
                                    -To     $object.Name `
                                    -Image  "$Dependencies\Images\ActiveDirectory.jpg" `
                                    -Size   30 `
                                    -ArrowsFromEnabled
                                #$MemberOf = ($object.MemberOf -split ',')[1..$object.MemberOf.length] -join ','
                                foreach ( $group in $object.MemberOf ) {
                                    $MemberOf = ($group -split ',')[0].TrimStart('CN=').trim()
                                    if ($MemberOf -notin $ADGroups){
                                        $ADGroups += $MemberOf
                                        New-DiagramNode `
                                            -Label  $MemberOf `
                                            -To     $object.name `
                                            -Image  "$Dependencies\Images\Group.jpg" `
                                            -Size   50 `
                                            -ArrowsFromEnabled
                                        New-DiagramNode `
                                            -Label  $object.name `
                                            -Image  "$Dependencies\Images\User.jpg" `
                                            -Size   20 `
                                            -ArrowsFromEnabled
                                    }
                                }
                            }
                            #>






                        }
                    }
                }
            }
        } -ShowHTML
    }
}

$PSWriteHTMLButtonAdd_MouseHover = {
    Show-ToolTip -Title "Graph Data" -Icon "Info" -Message @"
+  Utilizes the PSWriteHTML module to generate graph data in a web browser.
+  Requires that the PSWriteHTML module is loaded 
+  Requires PowerShell v5.1+
"@
}


