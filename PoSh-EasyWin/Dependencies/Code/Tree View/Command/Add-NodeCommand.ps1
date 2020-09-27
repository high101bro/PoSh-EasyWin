function Add-NodeCommand { 
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
        $CommandNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    Else {
        $CategoryNode = New-Object System.Windows.Forms.TreeNode -Property @{
            Name = $Category
            Text = $Category
            Tag  = $Category
            #ToolTipText   = "Checkbox this Category to query all its hosts"
        }
        #$CategoryNode.Expand()
        
        if ($Category -match '[\[\(]WinRM[\)\]].+') {
            $CategoryNode.ToolTipText = @"
Windows Remote Management (WinRM)
Protocols: HTTP(WSMan), MIME, SOAP, XML
Port:      5985/5986 (WinRM v2+)
                80 (WinRM v1)
                47001 (If a WinRM listener not created)
                Any (listeners can be configured on any port)
Encrypted: Yes, HTTP  - message level encryption
                Yes, HTTPS - added TLS protocol encyption 
OS:        Win7 / 2008R2+
                Older Operating Systems with WinRM installed
Data:      Deserialized Objects
Pros:      Single Port required
                Can establish sessions with endpoints
                Supports any cmdlet and native commands
Cons:       Requires WinRM service
                Many admins/networks disable this if not used
"@
        }
        elseif ($Category -match '[\[\(]RPC[\)\]].+') {
            $CategoryNode.ToolTipText = @"
Remote Procedure Call / Distributed COM
Protocols: RPC/DCOM
Encrypted: Not Encrypted (clear text)
Ports:     135, Random High
OS:        Windows 2000 and above
Data:      PowerShell = Deserialized Objects
                Native CMD = Serialized Data
Pros:      Works with older Operating Systems
                Does not require WinRM
Cons:      Uses random high ports
                Not firewall friendly
                Transmits data in clear text
"@
        }
        elseif ($Category -match '[\[\(]SMB[\)\]].+') {
            $CategoryNode.ToolTipText = @"
Server Message Block (via PSExec.exe)
Protocols: SMB (and NetBIOS)
Encrypted: Yes, v3.0+ 
Ports:     445 and 139 (over NetBIOS)
OS:        Port 445 - Windows 2000 and above
Data:      Serialized Data (though EasyWin will convert it)
Pros:      Works with older Operating Systems
                Access to domained and non-domained hosts
                Does not require WinRM or RPC
Cons:      Not natively supported, requires PSExec.exe
                Creates the service: PSEXEC
                May be blocked via Anti-Virus / Endpoint Security
                May be blocked via Application White/Black Listing
"@
        }        else { $CategoryNode.ToolTipText = "This is the directory name of the commands executed previously at that momemnt." }

        $CategoryNode.NodeFont   = New-Object System.Drawing.Font("Courier New",$($FormScale * 10),1,1,1)
        $CategoryNode.ForeColor  = [System.Drawing.Color]::FromArgb(0,0,0,0)
        $Null     = $RootNode.Nodes.Add($CategoryNode)
        $CommandNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    $Null = $CommandNode.Nodes.Add($newNode)
}