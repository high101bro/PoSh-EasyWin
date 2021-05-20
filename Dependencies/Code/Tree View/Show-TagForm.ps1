function Show-TagForm {
    $script:ComputerListMassTagValue = $null
    $ComputerListMassTagForm = New-Object System.Windows.Forms.Form -Property @{
        Text = "Tag Endpoints"
        Size     = @{ Width  = $FormScale * 350
                      Height = $FormScale * 115 }
        StartPosition = "CenterScreen"
        Font = New-Object System.Drawing.Font('Courier New',$($FormScale * 11),0,0,0)
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Add_Closing = { $This.dispose() }
    }
    #$ComputerListMassTagForm | select *
    $ComputerListMassTagNewTagNameLabel = New-Object System.Windows.Forms.Label -Property @{
        Text     = "Tag Name:"
        Location = @{ X = $FormScale * 5
                      Y = $FormScale * 14 }
        Size     = @{ Width  = $FormScale * 100
                      Height = $FormScale * 25 }
    }
    $ComputerListMassTagNewTagNameComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text     = ""
        Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + $ComputerListMassTagNewTagNameLabel.Size.Width + $($FormScale * 5)
                      Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 215
                      Height = $FormScale * 25 }
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        #DataSource         = $ArrayIfNotAddedWIth .Items.Add
    }
    #$TagListFileContents = Get-Content -Path $TagAutoListFile
    ForEach ($Tag in $TagListFileContents) {
        $ComputerListMassTagNewTagNameComboBox.Items.Add($Tag)
    }
    $ComputerListMassTagNewTagNameComboBox.Add_KeyDown({
        if ($_.KeyCode -eq "Enter" -and $ComputerListMassTagNewTagNameComboBox.text -ne '') {
            $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
            $ComputerListMassTagForm.Close()
        }
    })
    $ComputerListMassTagNewTagNameButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Apply Tag"
        Location = @{ X = $ComputerListMassTagNewTagNameLabel.Location.X + $($FormScale * 104)
                      Y = $ComputerListMassTagNewTagNameLabel.Location.Y + $ComputerListMassTagNewTagNameLabel.Size.Height + $($FormScale * 2) }
        Size     = @{ Width  = $FormScale * 100
                      Height = $FormScale * 25 }
        Add_Click = {
            if ($ComputerListMassTagNewTagNameComboBox.text -ne '') {
                $script:ComputerListMassTagValue = $ComputerListMassTagNewTagNameComboBox.text
                $ComputerListMassTagForm.Close()
            }
        }
    }
    CommonButtonSettings -Button $ComputerListMassTagNewTagNameButton
    $ComputerListMassTagForm.Controls.AddRange(@($ComputerListMassTagNewTagNameLabel,$ComputerListMassTagNewTagNameComboBox,$ComputerListMassTagNewTagNameButton))
    $ComputerListMassTagForm.Add_Shown({$ComputerListMassTagForm.Activate()})
    $ComputerListMassTagForm.ShowDialog()
}