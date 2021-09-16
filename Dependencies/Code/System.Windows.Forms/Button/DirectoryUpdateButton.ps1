$DirectoryUpdateButtonAdd_Click = {
    $script:CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
    $script:CollectionSavedDirectoryTextBox.Text = $script:CollectedDataTimeStampDirectory
}

$DirectoryUpdateButtonAdd_MouseHover = {
    Show-ToolTip -Title "New Timestamp" -Icon "Info" -Message @"
+  Provides a new timestamp name for the directory files are saved.
+  The timestamp is automatically renewed upon launch of PoSh-EasyWin.
+  Collections are saved to a 'Collected Data' directory that is created
    automatically where the PoSh-EasyWin script is executed from.
+  The directory's timestamp does not auto-renew after data is collected,
    you have to manually do so. This allows you to easily run multiple
    collections and keep this co-located.
+  The full directory path may also be manually modified to contain any
    number or characters that are permitted within NTFS. This allows
    data to be saved to uniquely named or previous directories created.
"@
}


