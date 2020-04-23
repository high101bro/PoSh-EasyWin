$EnumerationDomainGeneratedAutoCheckBoxAdd_Click = {
    if ($EnumerationDomainGeneratedAutoCheckBox.Checked -eq $true){
        $EnumerationDomainGeneratedTextBox.Enabled   = $false
        $EnumerationDomainGeneratedTextBox.BackColor = "lightgray"
    }
    elseif ($EnumerationDomainGeneratedAutoCheckBox.Checked -eq $false) {
        $EnumerationDomainGeneratedTextBox.Text = "<Domain Name>"
        $EnumerationDomainGeneratedTextBox.Enabled   = $true    
        $EnumerationDomainGeneratedTextBox.BackColor = "white"
    }
}
