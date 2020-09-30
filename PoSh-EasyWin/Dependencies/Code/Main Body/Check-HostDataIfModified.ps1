function Check-HostDataIfModified {
    if ($script:Section3HostDataNotesSaveCheck -eq $Section3HostDataNotesRichTextBox.Text) {
        $Section3HostDataSaveButton.ForeColor = "Green"
        $Section3HostDataSaveButton.Text      = "Data Saved"
    }
    else {
        $Section3HostDataSaveButton.ForeColor = "Red"
        $Section3HostDataSaveButton.Text      = "Save Data"
    }
}


