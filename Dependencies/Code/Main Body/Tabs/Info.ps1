
$MainLeftInfoTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Info"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 4
}
$MainLeftTabControl.Controls.Add($MainLeftInfoTab)


$MainLeftInfoTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * 557 }
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftInfoTab.Controls.Add($MainLeftInfoTabControl)


$ResourceFiles = Get-ChildItem "$Dependencies\About"


# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceFiles) {

    $Section1AboutSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        UseVisualStyleBackColor = $True
        Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $MainLeftInfoTabControl.Controls.Add($Section1AboutSubTab)


    $TabContents = Get-Content -Path $File.FullName -Force | ForEach-Object {$_ + "`r`n"}
    $Section1AboutSubTabTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text       = "$TabContents"
        Name       = "$file"
        Location = @{ X = $FormScale * -2
                      Y = $FormScale * -2 }
        Size     = @{ Width  = $FormScale * 442
                      Height = $FormScale * 536 }
        MultiLine  = $True
        ScrollBars = "Vertical"
        Font       = New-Object System.Drawing.Font("Courier New",($FormScale * 9),0,0,0)
    }
    $Section1AboutSubTab.Controls.Add($Section1AboutSubTabTextBox)
}