function Add-CommandTreeNode { 
    param ( 
        $RootNode, 
        $Category,
        $Entry,
        $ToolTip
    )
    $newNode = New-Object System.Windows.Forms.TreeNode -Property @{
        Name = "$Entry"
        Text = "$Entry"
    }

    if ($ToolTip) { 
        $newNode.ToolTipText  = "$ToolTip" 
    }
    else { 
        $newNode.ToolTipText  = "No Data Available" 
    }

    If ($RootNode.Nodes.Tag -contains $Category) {
        $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    Else {
        $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = $Category
            Text = $Category
            Tag  = $Category
            #ToolTipText   = "Checkbox this Category to query all its hosts"
        }
        #$CategoryNode.Expand()
        
        if ($Category -match '(WinRM)') {
            $CategoryNode.ToolTipText = @"
Windows Remote Management (WinRM)
Protocols: HTTP(WSMan), MIME, SOAP, XML
Port:      5985/5986
Encrypted: Yes
OS:        Win7 / 2008R2+
           Older OSs with WinRM installed
Data:      Deserialized Objects
Pros:      Single Port required
           Supports any cmdlet
Cons       Requires WinRM
"@
        }
        elseif ($Category -match '(RPC)') {
            $CategoryNode.ToolTipText = @"
Remote Procedure Call
Protocols: RPC/DCOM
Encrypted: Not Encrypted (clear text)
Ports:     135, Random High
OS:        Windows 2000 and above
Data:      PowerShell = Deserialized Objects
           Native CMD = Serialized Data
Pros:      Works with older OSs
           Does not require WinRM
Cons:      Uses random high ports
           Not firewall friendly
           Transmits data in clear text
"@
        }
        else { $CategoryNode.ToolTipText = "This is the directory name of the commands executed previously at that momemnt." }

        $CategoryNode.NodeFont   = New-Object System.Drawing.Font("$Font",10,1,1,1)
        $CategoryNode.ForeColor  = [System.Drawing.Color]::FromArgb(0,0,0,0)
        $Null     = $RootNode.Nodes.Add($CategoryNode)
        $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    $Null = $HostNode.Nodes.Add($newNode)
}