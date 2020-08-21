function Add-ComputerTreeNode { 
    param ( 
        $RootNode,
        $Category,
        $Entry,
        $ToolTip
    )
    $newNode      = New-Object System.Windows.Forms.TreeNode  
    $newNode.Name = "$Entry"
    $newNode.Text = "$Entry"
    if ($ToolTip) { $newNode.ToolTipText  = "$ToolTip" }
    else { $newNode.ToolTipText  = "No Data Available" }
    If ($RootNode.Nodes.Tag -contains $Category) {
        $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
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
        $Null     = $RootNode.Nodes.Add($CategoryNode)
        $HostNode = $RootNode.Nodes | Where-Object {$_.Tag -eq $Category}
    }
    $Null = $HostNode.Nodes.Add($newNode)
}