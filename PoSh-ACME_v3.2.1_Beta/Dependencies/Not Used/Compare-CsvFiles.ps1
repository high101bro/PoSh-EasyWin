#============================================================================================================================================================
# Compare CSV Files
#============================================================================================================================================================

#--------------------
# Compare CSV Button
#--------------------
$CompareButton          = New-Object System.Windows.Forms.Button
$CompareButton.Name     = "Compare CSVs"
$CompareButton.Text     = "$($CompareButton.Name)"
$CompareButton.UseVisualStyleBackColor = $True
$CompareButton.Location = New-Object System.Drawing.Point(($OpenResultsButton.Location.X + $OpenResultsButton.Size.Width + 5),$OpenResultsButton.Location.Y)
$CompareButton.Size     = New-Object System.Drawing.Size(115,22)
$CompareButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
$CompareButton.Add_Click({
    # Compare Reference Object
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenCompareReferenceObjectFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenCompareReferenceObjectFileDialog.Title = "Compare Reference Csv"
    $OpenCompareReferenceObjectFileDialog.InitialDirectory = "$CollectedDataDirectory"
    $OpenCompareReferenceObjectFileDialog.filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $OpenCompareReferenceObjectFileDialog.ShowDialog() | Out-Null
    $OpenCompareReferenceObjectFileDialog.ShowHelp = $true

    if ($OpenCompareReferenceObjectFileDialog.Filename) {

    # Compare Difference Object
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenCompareDifferenceObjectFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenCompareDifferenceObjectFileDialog.Title = "Compare Difference Csv"
    $OpenCompareDifferenceObjectFileDialog.InitialDirectory = "$CollectedDataDirectory"
    $OpenCompareDifferenceObjectFileDialog.filter = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
    $OpenCompareDifferenceObjectFileDialog.ShowDialog() | Out-Null
    $OpenCompareDifferenceObjectFileDialog.ShowHelp = $true

    if ($OpenCompareDifferenceObjectFileDialog.Filename) {

    # Imports Csv file headers
    [array]$DropDownArrayItems = Import-Csv $OpenCompareReferenceObjectFileDialog.FileName | Get-Member -MemberType NoteProperty | Select-Object -Property Name -ExpandProperty Name
    [array]$DropDownArray = $DropDownArrayItems | sort

    # This Function Returns the Selected Value and Closes the Form
    function CompareCsvFilesFormReturn-DropDown {
        if ($DropDownField.SelectedItem -eq $null){
            $DropDownField.SelectedItem = $DropDownField.Items[0]
            $script:Choice = $DropDownField.SelectedItem.ToString()
            $CompareCsvFilesForm.Close()
        }
        else{
            $script:Choice = $DropDownField.SelectedItem.ToString()
            $CompareCsvFilesForm.Close()
        }
    }
    function SelectProperty{
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

        #------------------------
        # Compare Csv Files Form
        #------------------------
        $CompareCsvFilesForm = New-Object System.Windows.Forms.Form
        $CompareCsvFilesForm.width  = 330
        $CompareCsvFilesForm.height = 160
        $CompareCsvFilesForm.Text   = ”Compare Two CSV Files”
        $CompareCsvFilesForm.Icon   = [System.Drawing.Icon]::ExtractAssociatedIcon("$ResourcesDirectory\favicon.ico")
        $CompareCsvFilesForm.StartPosition = "CenterScreen"
        $CompareCsvFilesForm.ControlBox = $true
        #$CompareCsvFilesForm.Add_Shown({$CompareCsvFilesForm.Activate()})

        #-----------------
        # Drop Down Label
        #-----------------
        $DropDownLabel          = New-Object System.Windows.Forms.Label
        $DropDownLabel.Location = New-Object System.Drawing.Point(10,10) 
        $DropDownLabel.size     = New-Object System.Drawing.Size(290,45) 
        $DropDownLabel.Text     = "What Property Field Do You Want To Compare?`n  <=   Found in the Reference File`n  =>   Found in the Difference File`n`nReplace the 'Name' property as necessary..."
        $DropDownLabel.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $CompareCsvFilesForm.Controls.Add($DropDownLabel)

        #-----------------
        # Drop Down Field
        #-----------------
        $DropDownField          = New-Object System.Windows.Forms.ComboBox
        $DropDownField.Location = New-Object System.Drawing.Point(10,($DropDownLabel.Location.y + $DropDownLabel.Size.Height))
        $DropDownField.Size     = New-Object System.Drawing.Size(290,30)
        ForEach ($Item in $DropDownArray) {
         [void] $DropDownField.Items.Add($Item)
        }
        $DropDownField.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $CompareCsvFilesForm.Controls.Add($DropDownField)

        #------------------
        # Drop Down Button
        #------------------
        $DropDownButton          = New-Object System.Windows.Forms.Button
        $DropDownButton.Location = New-Object System.Drawing.Point(10,($DropDownField.Location.y + $DropDownField.Size.Height + 10))
        $DropDownButton.Size     = New-Object System.Drawing.Size(100,20)
        $DropDownButton.Text     = "Execute"
        $DropDownButton.Add_Click({CompareCsvFilesFormReturn-DropDown})
        $DropDownButton.Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        $CompareCsvFilesForm.Controls.Add($DropDownButton)   

        [void] $CompareCsvFilesForm.ShowDialog()
        return $script:choice
    }
    $Property = $null
    $Property = SelectProperty
   
    #--------------------------------
    # Compares two Csv files Command
    #--------------------------------
    Compare-Object -ReferenceObject (Import-Csv $OpenCompareReferenceObjectFileDialog.FileName) -DifferenceObject (Import-Csv $OpenCompareDifferenceObjectFileDialog.FileName) -Property $Property `
        | Out-GridView -Title "Reference [<=]:  `"$(($OpenCompareReferenceObjectFileDialog.FileName).split('\') | ? {$_ -match '\d\d\d\d-\d\d-\d\d'})...$(($OpenCompareReferenceObjectFileDialog.FileName).split('\')[-1])`"  <-->  Difference [=>]:  `"$(($OpenCompareDifferenceObjectFileDialog.FileName).split('\') | ? {$_ -match '\d\d\d\d-\d\d-\d\d'})...$(($OpenCompareDifferenceObjectFileDialog.FileName).split('\')[-1])`"" -OutputMode Multiple | Set-Variable -Name CompareImportResults

    # Outputs messages to ResultsListBox 
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Compare Reference File:  $($OpenCompareReferenceObjectFileDialog.FileName)")
    $ResultsListBox.Items.Add("Compare Difference File: $($OpenCompareDifferenceObjectFileDialog.FileName)")
    $ResultsListBox.Items.Add("Compare Property Field:  $($Property)")

    # Writes selected fields to OpNotes
    if ($CompareImportResults) {
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Reference File:  $($OpenCompareReferenceObjectFileDialog.FileName)")
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Difference File: $($OpenCompareDifferenceObjectFileDialog.FileName)")
        $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Compare Property Field:  $($OpenCompareWhatToCompare)")
        foreach ($Selection in $CompareImportResults) {
            $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Compare: $($Selection -replace '@{','' -replace '}','')")
            Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  $($OpNotesListBox.SelectedItems)") -Force 
        }
        $Section1TabControl.SelectedTab = $Section1OpNotesTab
    }
    Save-OpNotes

    } # End If Statement for Compare CSV Reference
    } # End If Statement for Compare CSV Difference
})
$CompareButton.Add_MouseHover({
    ToolTipFunction -Title "Compare CSVs" -Icon "Info" -Message @"
⦿ Utilizes Compare-Object to compare two similar CSV Files.
⦿ Reads the CSV header and provides a dropdown to select a field.
⦿ Provides basic results, indicating which file has different lines:
    The side indicator of <= are for findings in the Reference File.
    The side indicator of => are for findings in the Difference File.
⦿ If the two files are identical, no results will be provided.
⦿ Multiple lines can be selected and added to OpNotes.
    The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.`n`n
"@ })
$Section2MainTab.Controls.Add($CompareButton)
