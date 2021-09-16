function Initialize-TreeViewData {
    <#
        .Description
    #>
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )
    if ($Accounts) {
        $script:TreeNodeAccountsList = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Accounts'
        $script:TreeNodeAccountsList.Tag = "Accounts"
        $script:TreeNodeAccountsList.Expand()
        $script:TreeNodeAccountsList.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $script:TreeNodeAccountsList.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    
        $script:AccountsListSearch     = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
        $script:AccountsListSearch.Tag = "Search"
    }
    if ($Endpoint) {
        $script:TreeNodeComputerList = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList 'All Endpoints'
        $script:TreeNodeComputerList.Tag = "Endpoint"
        $script:TreeNodeComputerList.Expand()
        $script:TreeNodeComputerList.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
        $script:TreeNodeComputerList.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    
        $script:ComputerListSearch     = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList '* Search Results'
        $script:ComputerListSearch.Tag = "Search"
    }
}


