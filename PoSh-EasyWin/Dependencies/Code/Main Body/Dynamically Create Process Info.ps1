$ResourceFiles = Get-ChildItem "$Dependencies\Process Info"

foreach ($File in $ResourceFiles) {
    #-----------------------------
    # Creates Tabs From Each File
    #-----------------------------
    $Section1ProcessesSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        Font                    = New-Object System.Drawing.Font("$Font",11,0,0,0)
        UseVisualStyleBackColor = $True
    }
    $Section1ProcessesTabControl.Controls.Add($Section1ProcessesSubTab)

    #-----------------------------
    # Imports Data Into Textboxes
    #-----------------------------
    $TabContents = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"} 
    $Section1ProcessesSubTabTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Name       = "$file"
        Text       = "$TabContents"
        Location = @{ X = $TextBoxRightPosition
                      Y = $TextBoxDownPosition }
        Size     = @{ Width  = $TextBoxWidth
                      Height = $TextBoxHeight }
        Font       = New-Object System.Drawing.Font("$Font",11,0,0,0)
        MultiLine  = $True
        ScrollBars = "Vertical"
    }
    $Section1ProcessesSubTab.Controls.Add($Section1ProcessesSubTabTextBox)
}
