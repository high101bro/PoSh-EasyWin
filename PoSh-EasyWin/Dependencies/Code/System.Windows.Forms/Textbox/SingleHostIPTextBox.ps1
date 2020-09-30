$SingleHostIPTextBoxAdd_KeyDown = {
    $script:SingleHostIPCheckBox.Checked = $true
    $script:ComputerTreeView.Enabled     = $false
    $script:ComputerTreeView.BackColor   = "lightgray"
}

$SingleHostIPTextBoxAdd_MouseEnter = {
    if ($script:SingleHostIPTextBox.text -eq "$DefaultSingleHostIPText") {
        $script:SingleHostIPTextBox.text = ""
    }
}

$SingleHostIPTextBoxAdd_MouseLeave = {
    if ($script:SingleHostIPTextBox.text -eq "") {
        $script:SingleHostIPTextBox.text = "$DefaultSingleHostIPText"
    }
}

$SingleHostIPTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Single Host Input Field" -Icon "Info" -Message @"
+  Queries a single host provided in the input field,
    disabling the computer treeview list.
+  Enter a valid hostname or IP address to collect data from.
+  Depending upon host or domain configurations, some queries
    such as WinRM against valid IPs may not yield results.
"@
}


