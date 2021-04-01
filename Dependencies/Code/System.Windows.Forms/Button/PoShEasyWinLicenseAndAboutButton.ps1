$PoShEasyWinLicenseAndAboutButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3AboutTab

    if ($PoShEasyWinLicenseAndAboutButton.Text -match "GNU General Public License v3" ) {
        $PoShEasyWinLicenseAndAboutButton.Text = "About PoSh-EasyWin"
        $Section1AboutSubTabRichTextBox.Text   = $(Get-Content "$Dependencies\GPLv3 - GNU General Public License.txt" -raw)
    }
    elseif ($PoShEasyWinLicenseAndAboutButton.Text -match "About PoSh-EasyWin" ) {
        $PoShEasyWinLicenseAndAboutButton.Text = "GNU General Public License v3"
        $Section1AboutSubTabRichTextBox.Text   = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    }
}

$PoShEasyWinLicenseAndAboutButtonAdd_MouseHover = {
    Show-ToolTip -Title "Posh-EasyWin" -Icon "Info" -Message @"
+  Switch between the following:
     About PoSh-EasyWin
     GNU General Public License v3
"@
}


