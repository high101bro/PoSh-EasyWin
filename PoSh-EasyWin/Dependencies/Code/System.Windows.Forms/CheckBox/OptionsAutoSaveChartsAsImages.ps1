$OptionsAutoSaveChartsAsImagesAdd_Click = {
    $This.Text | Set-Content "$PoShHome\Settings\Auto Save Charts As Images.txt" -Force

    if (-not $(Test-Path -Path $AutosavedChartsDirectory)) {
        New-Item -Type Directory -Path $AutosavedChartsDirectory -Force
    }
}

$OptionsAutoSaveChartsAsImagesAdd_MouseHover = {
    Show-ToolTip -Title "AutoSave Charts" -Icon "Info" -Message @"
+  Autosaves Multi-Series charts that are viewed
+  Images will be saved to the 'Autosaved Charts' folder in PoSh-AMCE's root directory
"@
}


