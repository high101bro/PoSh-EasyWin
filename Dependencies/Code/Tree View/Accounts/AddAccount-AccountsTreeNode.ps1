function AddAccount-AccountsTreeNode {
    if (($AccountsTreeNodePopupAddTextBox.Text -eq "Enter an Account") -or ($AccountsTreeNodePopupOUComboBox.Text -eq "Select an Organizational Unit / Canonical Name (or type a new one)")) {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Add an Account:  Error")
        [System.Windows.MessageBox]::Show('Enter a suitable name:
- Cannot be blank
- Cannot already exists
- Cannot be the default value ','Error')
    }
    elseif ($script:AccountsTreeViewData.Name -contains $AccountsTreeNodePopupAddTextBox.Text) {
        Message-NodeAlreadyExists -Accounts -Message "Add an Account:  Error" -Account $AccountsTreeNodePopupAddTextBox.Text
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Added Selection:  $($AccountsTreeNodePopupAddTextBox.Text)")

        $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
        $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupOUComboBox.SelectedItem -Entry $AccountsTreeNodePopupAddTextBox.Text #-ToolTip "No Unique Data Available"
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("$($AccountsTreeNodePopupAddTextBox.Text) has been added to $($AccountsTreeNodePopupOUComboBox.Text)")

        $AccountsTreeNodeAddAccount = New-Object PSObject -Property @{
            Name            = $AccountsTreeNodePopupAddTextBox.Text
            CanonicalName   = $AccountsTreeNodePopupOUComboBox.Text
        }
        $script:AccountsTreeViewData += $AccountsTreeNodeAddAccount
        $script:AccountsTreeView.ExpandAll()
        $AccountsTreeNodePopup.close()
        Save-TreeViewData -Accounts
        UpdateState-TreeViewData -Accounts -NoMessage
    }
}

