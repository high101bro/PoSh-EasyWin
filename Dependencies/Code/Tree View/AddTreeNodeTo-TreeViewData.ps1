function AddTreeNodeTo-TreeViewData {
    param (
        [switch]$Accounts,
        [switch]$Endpoint,
        $RootNode,
        $Category,
        $Entry,
        [switch]$DoNotPopulateMetadata,
        $Metadata,
        $IPv4Address,
        $ToolTip
    )
    # checks if data is in date/datetime format, if so, it trims off the time
    if ($Category -match ".{1,2}/.{1,2}/.{4}") {
        #$Category = ($Category.ToString() -split ' ')[0]
        $Category = ([datetime]$Category).ToString("yyyy-MM-dd")
    }

    if ($Accounts) {
        $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = "$Entry"
            Text = "$Entry"
        }
        
        if (-not $DoNotPopulateMetadata) {
            $MetadataCreated = New-Object System.Windows.Forms.TreeNode -Property @{
                Name = "Created"
                Text = "Created: $($Metadata.Created)"
            }
            $newNode.Nodes.Add($MetadataCreated)
    
            # $MetadataModified = New-Object System.Windows.Forms.TreeNode -Property @{
            #     Name = "Modified"
            #     Text = "Modified: $($Metadata.Modified)"
            # }
            # $newNode.Nodes.Add($MetadataModified)

            $MetadataLockedOut = New-Object System.Windows.Forms.TreeNode -Property @{
                Name = "Locked Out"
                Text = "Locked Out: $($Metadata.LockedOut)"
            }
            $newNode.Nodes.Add($MetadataLockedOut)

            $MetadataGroups = New-Object System.Windows.Forms.TreeNode -Property @{
                Name = 'Groups Membership'
                Text = 'Groups Membership'
            }
            $newNode.Nodes.Add($MetadataGroups)
            
            $AccountGroups = $Metadata.MemberOf -split ' CN=' | Foreach-Object {$_.trim('CN=').split(',')[0]}
            $MetadataGroups.Nodes.Add("[ Total Count: $($AccountGroups.Count) ]")
            foreach ($Group in $AccountGroups) {
                $MetadataEachGroup = New-Object System.Windows.Forms.TreeNode -Property @{
                    Name = $Group
                    Text = $Group
                }
                $MetadataGroups.Nodes.Add($MetadataEachGroup)
            }
        }

        if ($ToolTip) {
            $newNode.ToolTipText  = "$ToolTip"
        }
        else {
            $newNode.ToolTipText  = "No Data Available"
        }
    
        If ($RootNode.Nodes.Tag -contains $Category) {
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        Else {
            $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
                Name        = $Category
                Text        = $Category
                Tag         = $Category
                ToolTipText = "Checkbox this Category to query select all child nodes"
                NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            $RootNode.Nodes.Add($CategoryNode)
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        $EndpointNode.Nodes.Add($newNode)
    }


    if ($Endpoint) {
        $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = "$Entry"
            Text = "$Entry"
        }
    
        #batman #TODO work on this
        # $MetadataOperatingSystem = New-Object System.Windows.Forms.TreeNode -Property @{
        #     Name = "OperatingSystem"
        #     Text = $($Metadata.OperatingSystem)
        #     Tag  = $($Metadata.OperatingSystem)
        #     ToolTipText = ""
        #     NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        #     ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
        # }
        # $newNode.Nodes.Add($MetadataOperatingSystem)
    
        if (-not $DoNotPopulateMetadata) {
            $MetadataIPv4Address = New-Object System.Windows.Forms.TreeNode -Property @{
                Name = "IPv4Address"
                Text = $Metadata.IPv4Address
            }
            $MetadataIPv4Address.Bounds.Height = 0
            $MetadataIPv4Address.Bounds.Width = 0
            $newNode.Nodes.Add($MetadataIPv4Address)
    
            $MetadataIPv4Ports = New-Object System.Windows.Forms.TreeNode -Property @{
                Name = 'Port Scan'
                Text = 'Port Scan'
            }
            $newNode.Nodes.Add($MetadataIPv4Ports)
    
            $MetadataIPv4Ports.Nodes.Add("[ Total Count: $($Metadata.PortScan.split(',').Count) ]")
            foreach ($PortScan in ($Metadata.PortScan.split(','))) {
                $MetadataIPv4EachPort = New-Object System.Windows.Forms.TreeNode -Property @{
                    Name = $PortScan
                    Text = $PortScan
                }
                $MetadataIPv4Ports.Nodes.Add($MetadataIPv4EachPort)
            }
        }
    
        if ($ToolTip) {
            $newNode.ToolTipText  = "$ToolTip"
        }
        else {
            $newNode.ToolTipText  = "No Data Available"
        }
    
        If ($RootNode.Nodes.Tag -contains $Category) {
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        Else {
            $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
                Name        = $Category
                Text        = $Category
                Tag         = $Category
                ToolTipText = "Checkbox this Category to query all its hosts"
                NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            $RootNode.Nodes.Add($CategoryNode)
            $EndpointNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
        }
        $EndpointNode.Nodes.Add($newNode)
    }
}

