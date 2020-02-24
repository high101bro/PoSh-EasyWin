function Initialize-ComputerTreeNodes {
    $script:TreeNodeComputerList = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Hosts' 
    $script:TreeNodeComputerList.Tag = "Computers"
    $script:TreeNodeComputerList.Expand()
    $script:TreeNodeComputerList.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
    $script:TreeNodeComputerList.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)

    $script:ComputerListSearch     = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
    $script:ComputerListSearch.Tag = "Search"
}
