$Section3QueryExplorationEditCheckBoxAdd_Click = {
    if ($Section3QueryExplorationEditCheckBox.checked){
        $Section3QueryExplorationSaveButton.Text      = "Save"
        $Section3QueryExplorationSaveButton.ForeColor = "Red"
        $Section3QueryExplorationDescriptionRichTextbox.ReadOnly    = $false
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly       = $false
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly      = $false
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly  = $false
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly = $false
        $Section3QueryExplorationRPCWMITextBox.ReadOnly         = $false
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly        = $false
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly       = $false
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly       = $false
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly      = $false
        $Section3QueryExplorationTagWordsTextBox.ReadOnly       = $false
    }
    else {
        $Section3QueryExplorationSaveButton.Text      = "Locked"
        $Section3QueryExplorationSaveButton.ForeColor = "Green"
        $Section3QueryExplorationDescriptionRichTextbox.ReadOnly    = $true
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly      = $true
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly  = $true
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly = $true
        $Section3QueryExplorationRPCWMITextBox.ReadOnly         = $true
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly        = $true
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly       = $true
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly      = $true
        $Section3QueryExplorationTagWordsTextBox.ReadOnly       = $true
    }
}

