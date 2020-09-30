function Add-NodeComputer {
    param (
        $RootNode,
        $Category,
        $Entry,
        $Metadata,
        $ToolTip
    )
    $newNode      = New-Object System.Windows.Forms.TreeNode -Property @{
        Name = "$Entry"
        Text = "$Entry"
    }

    $MetadataOperatingSystem = New-Object System.Windows.Forms.TreeNode -Property @{
        Name = $($Metadata.OperatingSystem)
        Text = $($Metadata.OperatingSystem)
        Tag  = $($Metadata.OperatingSystem)
        ToolTipText = ""
        NodeFont    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor   = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $newNode.Nodes.Add($MetadataOperatingSystem)

    $MetadataIPv4Address = New-Object System.Windows.Forms.TreeNode -Property @{
        Name = $Metadata.IPv4Address
        Text = $Metadata.IPv4Address
    }
    $newNode.Nodes.Add($MetadataIPv4Address)

    $MetadataIPv4Ports = New-Object System.Windows.Forms.TreeNode -Property @{
        Name = 'Port Scan'
        Text = 'Port Scan'
    }
    $newNode.Nodes.Add($MetadataIPv4Ports)

    $MetadataIPv4Ports.Nodes.Add("[ Total Count: $($Metadata.'Port Scan'.split(',').Count) ]")
    foreach ($PortScan in ($Metadata.'Port Scan'.split(','))) {
        $MetadataIPv4EachPort = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = $PortScan
            Text = $PortScan
        }
        $MetadataIPv4Ports.Nodes.Add($MetadataIPv4EachPort)
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

