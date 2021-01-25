$Section3HostDataTagsAddButtonAdd_Click = {
    if (!($Section3HostDataTagsComboBox.SelectedItem -eq "Tags")) {
        $Section3HostDataNotesRichTextBox.text = "[$($Section3HostDataTagsComboBox.SelectedItem)] " + $Section3HostDataNotesRichTextBox.text
    }
}

$Section3HostDataTagsAddButtonAdd_MouseHover = {
Show-ToolTip -Title "Add Tag to Notes" -Icon "Info" -Message @"
+  Tags are not mandatory.
+  Tags provide standized info to aide searches.
+  Custom tags can be created and used.
"@
}


