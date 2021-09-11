
$Section3AboutTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "About"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
}
$InformationTabControl.Controls.Add($Section3AboutTab)


$Section1AboutSubTabRichTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Text   = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    Left   = $FormScale * 3
    Width  = $FormScale * 742
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $true
    ReadOnly   = $True
    BackColor  = 'White'
    ShortcutsEnabled = $true
}
$Section3AboutTab.Controls.Add($Section1AboutSubTabRichTextBox)
$Section1AboutSubTabRichTextBox.bringtofront()


$FeatureRequestReportBugButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Request Feature / Report Bug"
    Top    = $FormScale * 300
    Left   = $FormScale * 553
    Width  = $FormScale * 175
    Height = $FormScale * 25
    Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    Add_Click = {
        $Verify = [System.Windows.Forms.MessageBox]::Show(
            "Do you want to navigate to PoSh-EasyWin's GitHub page and either request a feature or report a bug?",
            "PoSh-EasyWin - Feature Request / Report Bug",
            'YesNo',
            "Warning")
        switch ($Verify) {
            'Yes'{Start-Process "https://github.com/high101bro/PoSh-EasyWin/issues"}
            'No' {continue}
        }                    
    }
}
$Section3AboutTab.Controls.Add($FeatureRequestReportBugButton)
Apply-CommonButtonSettings -Button $FeatureRequestReportBugButton
$FeatureRequestReportBugButton.bringtofront()

