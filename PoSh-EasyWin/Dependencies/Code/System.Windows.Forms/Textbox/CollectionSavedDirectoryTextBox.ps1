$CollectionSavedDirectoryTextBoxAdd_MouseHover = {
    Show-ToolTip -Title "Results Folder" -Icon "Info" -Message @"
+  This path supports auto-directory completion.
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


