# This is used just to track if any WinRM queries are being conducted and provided a message before execution
$WinRMCommandCount = 0

# If the -ComputerName parameter is provided from command line...
if ($ComputerName) {
    $ComputerList = @()
    [System.Windows.Forms.TreeNodeCollection]$AllComputerNodes = $script:ComputerTreeView.Nodes
    foreach ($TargetComputer in $ComputerName) {
        foreach ($root in $AllComputerNodes) { 
            foreach ($Category in $root.Nodes) { 
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Text -eq $TargetComputer) {
                        $Entry.Checked = $true
                        $ComputerList += $Entry.Text
                    }
                }
            }
        }
    }
}        
elseif ($ComputerSearch) {
    Search-ComputerTreeNode -ComputerSearchInput $ComputerSearch
    $ComputerList = @()
    [System.Windows.Forms.TreeNodeCollection]$AllComputerNode = $script:ComputerTreeView.Nodes 
    foreach ($root in $AllComputerNode) { 
        if ($root.text -match 'Search Results'){ 
            foreach ($Category in $root.Nodes) {
                foreach ($Search in $ComputerSearch){
                    if ($Category.text -match $Search) {
                        foreach ($Entry in $Category.Nodes) {
                            $Entry.Checked = $true
                            $ComputerList += $Entry.Text
                            if ($FilterOutComputer) {        
                                foreach ($Filter in $FilterOutComputer) {
                                    if ($Entry.Text -match $Filter) {
                                        $Entry.Checked = $false
                                    #    $ComputerList = $ComputerList | Where-Object { $_ -ne "$($Entry.Text)"}
                                    }
                                }
                                if ($FilterInComputer) {          
                                    foreach ($Filter in $FilterInComputer)  {
                                        if ($Entry.Text -match $Filter) {
                                            $Entry.Checked = $true
                                      #      $ComputerList += $Entry.Text
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


#===========================================================

# Compiles all the commands treenodes into one object
$script:AllCommands  = $script:AllEndpointCommands
$script:AllCommands += $script:AllActiveDirectoryCommands

# If the -CommandSearch parameter is provided from commandlilne...
if ($CommandSearch) {
    Search-CommandTreeNode -CommandSearchInput $CommandSearch

    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes 
    foreach ($root in $AllCommandsNode) { 
        if ($root.text -match 'Search Results'){ 
            foreach ($Category in $root.Nodes) {
                foreach ($Search in $CommandSearch) {
                    if ($Category.text -match $Search) {
                        foreach ($Entry in $Category.Nodes) {
                            if ($Protocol) {
                                foreach ($Proto in $Protocol) {
                                    if ($Entry.Text -match "[\[\(]$Proto[\)\]].+") { 
                                        $Entry.Checked = $true
                                        if ($Entry.Text -match "[\[\(]RPC[\)\]].+") { 
                                            $script:RpcCommandCount += 1                            
                                        }
                                        elseif ($Entry.Text -match "[\[\(]WinRM[\)\]].+"){
                                            $WinRMCommandCount += 1
                                        }
                                    }
                                    else {
                                        $Entry.Checked = $false
                                    }
                                }
                            }
                            else {
                                $Entry.Checked = $true
                                if ($Entry.Text -match "[\[\(]RPC[\)\]].+") { 
                                    $script:RpcCommandCount += 1                            
                                }
                                elseif ($Entry.Text -match "[\[\(]WinRM[\)\]].+"){
                                    $WinRMCommandCount += 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    Compile-SelectedCommandTreeNode

    if ($FilterOutCommand) {
        $FilteredSelectedCommands = $script:CommandsCheckedBoxesSelected
        # loops through command to filter out commands
        foreach ($Command in $FilteredSelectedCommands) {
            foreach ($Filter in $FilterOutCommand) {
                if ($Command.command -match $Filter) {
                    $FilteredSelectedCommands = $FilteredSelectedCommands | Where-Object {$_.command -notmatch $filter}
                }
            }
        }
        if ($FilterInCommand) {          
            foreach ($Command in $script:CommandsCheckedBoxesSelected) {
                foreach ($Filter in $FilterInCommand)  {
                    if ($Command.command -match $Filter) {
                        if ($command -notin $FilteredSelectedCommands) {
                            $FilteredSelectedCommands += $Command
                        }
                    }
                }
            }
        }
        $script:CommandsCheckedBoxesSelected = $FilteredSelectedCommands  
    }

    

    if ($NoGUI) {
        Write-Host -ForegroundColor Cyan "PoSh-EasyWin's command line version currently only support the WinRM protocol."
        Write-Host -ForegroundColor Yellow "   [!] " -NoNewLine
        Write-Host -ForegroundColor White "If you require the use of the RPC protocol, launch the GUI."
        Write-Host ''
    
    
        Write-Host -ForegroundColor Cyan "The -SaveDirectory parameter allows you specify the save location. The default name is generated by execution time."
        Write-Host -ForegroundColor Green "Collected Data will be save to:"
        Write-Host -ForegroundColor Yellow "   [!] " -NoNewLine
        Write-Host -ForegroundColor White  "$SaveDirectory"
        Write-Host ''
    
    
        if ($ComputerName) {
            Write-Host -ForegroundColor Cyan "The -ComputerName parameter queries endpoints regardless if they exist within PoSh-EasyWin's database."
            Write-Host -ForegroundColor Green  "The following " -NoNewLine
            Write-Host -ForegroundColor Red "$($ComputerName.Count)" -NoNewLine
            Write-Host -ForegroundColor Green  " endpoints will be queried:"
            Write-Host -ForegroundColor Yellow "   [!] " -NoNewLine
            Write-Host -ForegroundColor White   "$($ComputerName -join ', ')"
        }
        elseif ($ComputerSearch) {
            Write-Host -ForegroundColor Cyan "The -ComputerSearch parameter uses RegEx to query for computers via their saved metadata within PoSh-EasyWin's database."
            Write-Host -ForegroundColor Green "The following " -NoNewLine
            Write-Host -ForegroundColor Red "$($ComputerList.Count)" -NoNewLine
            Write-Host -ForegroundColor Green " endpoints will be queried:"
            Write-Host -ForegroundColor Yellow "   [!] " -NoNewLine
            Write-Host -ForegroundColor White   "$($ComputerList -join ', ')"
        }
        else{
            Write-Host -ForegroundColor Red    "Missing requirement:" -NoNewLine
            Write-Host -ForegroundColor White  "  A computer parameter was not selected for use."
            Write-Host -ForegroundColor Green  "Use one of the following computer parameters:"
            Write-Host -ForegroundColor Yellow "   -ComputerSearch"
            Write-Host -ForegroundColor White  "      Uses RegEx to query for comptuers via their saved metadata."
            Write-Host -ForegroundColor White  "      Only hosts that have a match within the database are used."
            Write-Host -ForegroundColor White  "      Example: -ComputerSearch 'Windows 10'"
            Write-Host -ForegroundColor Yellow "   -ComputerName"
            Write-Host -ForegroundColor White  "      Enter one or more hostnames."
            Write-Host -ForegroundColor White  "      Only hosts that have a match within the database are used."
            Write-Host -ForegroundColor White  "      Accepts pipeline input."            
            Write-Host -ForegroundColor White  "      Aliases: -PSComputerName, -MachineName, -CN"
            Write-Host -ForegroundColor White  "      Example: -ComputerName win10-01,win10-02,win10-03"
            Write-Host -ForegroundColor White  "      Example: -ComputerName (Get-Content .\Host_List.txt)"
        }
        Write-Host ''
    
        
        if ($CommandSearch) {
            Write-Host -ForegroundColor Green  "The following " -NoNewLine
            Write-Host -ForegroundColor Red "$($script:CommandsCheckedBoxesSelected.count)" -NoNewLine
            Write-Host -ForegroundColor Green  " queries will be executed:"
            Foreach ($Command in $script:CommandsCheckedBoxesSelected) {
                Write-Host -ForegroundColor Yellow "   [!] " -NoNewLine
                Write-Host -ForegroundColor White "$($Command.Command | Sort-Object)"
            }
        }
        else{
            Write-Host -ForegroundColor Red    "Missing requirement:" -NoNewLine
            Write-Host -ForegroundColor White  "  The Command Search parameter was not provided."
            Write-Host -ForegroundColor Yellow "   -ComputerSearch"
            Write-Host -ForegroundColor White  "      Uses RegEx to query for comptuers via their saved metadata."
            Write-Host -ForegroundColor White  "      Only hosts that have a match within the database are used."            
        }
        Write-Host ''
    

        Write-Host -ForegroundColor Green 'Protocols that will be used: '
        $ProtocolsUsed = @()
        if ($WinRMCommandCount -gt 0) {
            $ProtocolsUsed += 'WinRM'
        }
        if ($script:RpcCommandCount -gt 0) {
            $ProtocolsUsed += 'RPC'
        }
        Foreach ($ProcUsed in $ProtocolsUsed) {
            Write-Host -ForegroundColor Yellow "   [!] " -NoNewLine
            Write-Host -ForegroundColor White $ProcUsed
        }
        Write-Host ''
    

        Write-Host -ForegroundColor Yellow 'Do you want to continue?' -NoNewLine
        Write-Host -ForegroundColor Cyan ' (y/N)' -NoNewLine
        $CommandLineContinue = Read-Host ' '
        switch ($CommandLineContinue) {
            "y" {
                Invoke-Command  $ExecuteScriptHandler
                Invoke-Item $SaveDirectory
            }
            "n" {exit}
            default {
                Write-Host -ForegroundColor Yellow "   [!] " -NoNewLine
                Write-Host -ForegroundColor White  'Invalid Entry! Exiting.'
                Write-Host ''
                exit
            }
        }
    }
}
