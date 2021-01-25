$DirectoryOpenButtonAdd_Click = {
    if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {
        $OpenDirectory = $script:CollectionSavedDirectoryTextBox.Text
    }
    elseif (Test-Path $CollectedDataDirectory) {
        $OpenDirectory = $CollectedDataDirectory
    }
    else {
        $OpenDirectory = $PoShHome
    }
    Invoke-Item -Path $OpenDirectory
}

$DirectoryOpenButtonAdd_MouseHover = {
    Show-ToolTip -Title "Open Results" -Icon "Info" -Message @"
+  Opens the directory where the collected data is saved.
+  The 'Collected Data' parent directory is opened by default.
+  After collecting data, the directory opened is changed to that
    of where the data is saved - normally the timestamp folder.
+  From here, you can easily navigate the rest of the directory.
"@
}


