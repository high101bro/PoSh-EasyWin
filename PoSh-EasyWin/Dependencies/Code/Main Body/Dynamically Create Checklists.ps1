$ChecklistDownPosition      = 10
$ChecklistDownPositionShift = 30

foreach ($File in $ResourceChecklistFiles) {
    #-------------------------
    # Creates Tabs From Files
    #-------------------------
    $Section1ChecklistSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        AutoScroll              = $True
        UseVisualStyleBackColor = $True
        Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $MainLeftChecklistTabControl.Controls.Add($Section1ChecklistSubTab)

    #-------------------------------------
    # Imports Data and Creates Checkboxes
    #-------------------------------------
    $TabContents = Get-Content -Path $File.FullName -Force | foreach {$_ + "`r`n"}
    foreach ($line in $TabContents) {
        $Checklist = New-Object System.Windows.Forms.CheckBox -Property @{
            Text     = "$line"
            Location = @{ X = $FormScale * 5
                          Y = $FormScale * $ChecklistDownPosition }
            Size     = @{ Width  = $FormScale * 410
                          Height = $FormScale * 30 }
            Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        if ($Checklist.Check -eq $True) { $Checklist.ForeColor = "Blue" }
        $Section1ChecklistSubTab.Controls.Add($Checklist)          

        $ChecklistDownPosition += $ChecklistDownPositionShift
    }
    $ChecklistDownPosition = $FormScale * 10
}
