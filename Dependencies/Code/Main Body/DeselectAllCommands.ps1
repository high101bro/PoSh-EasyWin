function Deselect-AllCommands {
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
    foreach ($root in $AllCommandsNode) {
        $root.Checked   = $false
        $root.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
        $root.Collapse()
        if ($root.text -notmatch 'Custom Group Commands') { $root.Expand() }
        foreach ($Category in $root.Nodes) {
            $Category.Checked   = $false
            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            $Category.Collapse()
            foreach ($Entry in $Category.nodes) {
                $Entry.Checked   = $false
                $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }

    $CustomQueryScriptBlockCheckBox.checked                      = $false
    $RegistrySearchCheckbox.checked                              = $false
    $RegistrySearchRecursiveCheckbox.checked                     = $false
    $RegistryKeyNameCheckbox.checked                             = $false
    $RegistryValueNameCheckbox.checked                           = $false
    $RegistryValueDataCheckbox.checked                           = $false
    $AccountsCurrentlyLoggedInConsoleCheckbox.checked            = $false
    $AccountsCurrentlyLoggedInPSSessionCheckbox.checked          = $false
    $AccountActivityCheckbox.checked                             = $false
    $EventLogsEventIDsManualEntryCheckbox.checked                = $false
    $EventLogsQuickPickSelectionCheckbox.checked                 = $false
    $EventLogsEventIDsToMonitorCheckbox.checked                  = $false
    $FileSearchDirectoryListingCheckbox.checked                  = $false
    $FileSearchFileSearchCheckbox.checked                        = $false
    $FileSearchAlternateDataStreamCheckbox.checked               = $false
    $NetworkEndpointPacketCaptureCheckBox.checked                = $false
    $NetworkConnectionSearchRemoteIPAddressCheckbox.checked      = $false
    $NetworkConnectionSearchRemotePortCheckbox.checked           = $false
    $NetworkConnectionSearchLocalPortCheckbox.checked            = $false
    $NetworkConnectionSearchProcessCheckbox.checked              = $false
    $NetworkConnectionSearchDNSCacheCheckbox.checked             = $false
    $NetworkConnectionSearchCommandLineCheckbox.checked          = $false
    $NetworkConnectionSearchExecutablePathCheckbox.checked       = $false
    $SysinternalsSysmonCheckbox.checked                          = $false
    $SysinternalsAutorunsCheckbox.checked                        = $false
    $SysinternalsProcessMonitorCheckbox.checked                  = $false
    $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked   = $false

    $CustomQueryScriptBlockCheckBox.ForeColor                    = 'Blue'
    $RegistrySearchCheckbox.ForeColor                            = 'Blue'
    $RegistrySearchRecursiveCheckbox.ForeColor                   = 'Blue'
    $RegistryKeyNameCheckbox.ForeColor                           = 'Blue'
    $RegistryValueNameCheckbox.ForeColor                         = 'Blue'
    $RegistryValueDataCheckbox.ForeColor                         = 'Blue'
    $AccountsCurrentlyLoggedInConsoleCheckbox.ForeColor          = 'Blue'
    $AccountsCurrentlyLoggedInPSSessionCheckbox.ForeColor        = 'Blue'
    $AccountActivityCheckbox.ForeColor                           = 'Blue'
    $EventLogsEventIDsManualEntryCheckbox.ForeColor              = 'Blue'
    $EventLogsQuickPickSelectionCheckbox.ForeColor               = 'Blue'
    $EventLogsEventIDsToMonitorCheckbox.ForeColor                = 'Blue'
    $FileSearchDirectoryListingCheckbox.ForeColor                = 'Blue'
    $FileSearchFileSearchCheckbox.ForeColor                      = 'Blue'
    $FileSearchAlternateDataStreamCheckbox.ForeColor             = 'Blue'
    $NetworkEndpointPacketCaptureCheckBox.ForeColor              = 'Blue'
    $NetworkConnectionSearchRemoteIPAddressCheckbox.ForeColor    = 'Blue'
    $NetworkConnectionSearchRemotePortCheckbox.ForeColor         = 'Blue'
    $NetworkConnectionSearchLocalPortCheckbox.ForeColor          = 'Blue'
    $NetworkConnectionSearchProcessCheckbox.ForeColor            = 'Blue'
    $NetworkConnectionSearchDNSCacheCheckbox.ForeColor           = 'Blue'
    $NetworkConnectionSearchCommandLineCheckbox.ForeColor        = 'Blue'
    $NetworkConnectionSearchExecutablePathCheckbox.ForeColor     = 'Blue'
    $SysinternalsSysmonCheckbox.ForeColor                        = 'Blue'
    $SysinternalsAutorunsCheckbox.ForeColor                      = 'Blue'
    $SysinternalsProcessMonitorCheckbox.ForeColor                = 'Blue'
    $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.ForeColor = 'Blue'

#Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}


