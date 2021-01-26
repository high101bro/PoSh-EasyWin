$CommandsTreeViewCustomGroupCommandsRemovalButtonAdd_Click = {
    $QueryHistoryRemoveCategoryList = @()
    $QueryHistoryKeepCategoryList   = @()
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
    foreach ($root in $AllCommandsNode) {
        if ($root.text -match 'Custom Group Commands') {
            $root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            foreach ($Category in $root.Nodes) {
                $QueryHistoryRemoveCategoryList += $Category
                if (!($Category.checked)) { $QueryHistoryKeepCategoryList += $Category }
            }
        }
    }
    foreach ($Entry in $QueryHistoryRemoveCategoryList) { $Entry.remove() }
    $Section1CommandsTab.Controls.Remove($CommandsTreeViewCustomGroupCommandsRemovalButton)

    $QueryHistoryKeepSelected = @()
    foreach ($Category in $QueryHistoryKeepCategoryList) {
        foreach ($Entry in $Category.nodes) {
            $QueryHistoryKeepSelected += [pscustomobject]@{
                CategoryName = $Category.Text
                Name         = $Entry.Text
            }
            Add-NodeCommand -RootNode $script:TreeNodeCustomGroupCommands -Category "$($Category.text)" -Entry "$($Entry.Text)" -ToolTip $Command.Command
        }
    }
    $script:CustomGroupCommandsList = $QueryHistoryKeepSelected
    $QueryHistoryKeepSelected | Export-CliXml "$Dependencies\Custom Group Commands.xml"
}


