
$SmithFileSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "File Search"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftSMITHTabControl.Controls.Add($SmithFileSearchTab)


$SmithFileSearchDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Directory Listing (WinRM)"
    Left   = $FormScale * 3
    Top    = $FormScale * 15
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithFileSearchTab.Controls.Add($SmithFileSearchDirectoryListingCheckbox)


        $SmithFileSearchDirectoryListingMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $SmithFileSearchDirectoryListingCheckbox.Width + $($FormScale * 52)
            Top    = $SmithFileSearchDirectoryListingCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor  = "Black"
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchDirectoryListingMaxDepthLabel)


        $SmithFileSearchDirectoryListingMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $SmithFileSearchDirectoryListingMaxDepthLabel.Left + $SmithFileSearchDirectoryListingMaxDepthLabel.Width
            Top    = $SmithFileSearchDirectoryListingCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchDirectoryListingMaxDepthTextbox)


        $SmithFileSearchDirectoryListingLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Collection time is dependant on the directory's contents."
            Left   = $FormScale * 3
            Top    = $SmithFileSearchDirectoryListingCheckbox.Top + $SmithFileSearchDirectoryListingCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 330
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchDirectoryListingLabel)


        $SmithFileSearchSearchResultsButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Search Results"
            Left   = $SmithFileSearchDirectoryListingLabel.Left + $SmithFileSearchDirectoryListingLabel.Width
            Top    = $SmithFileSearchDirectoryListingLabel.Top
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
            Add_Click = {
                $FilSearchViewResultsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
                    Title = "Open Directory Files"
                    Filter = "CSV (*.csv)| *.csv|XML (*.xml)| *.xml|All files (*.*)|*.*"
                    InitialDirectory = $ExecAndScriptDir
                }
                $FilSearchViewResultsOpenFileDialog.ShowDialog()
                Search-DirectoryTreeView -Input $(Import-Csv $FilSearchViewResultsOpenFileDialog.FileName | ForEach-Object {$_.FullName.Trim("\")} )
            }
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchSearchResultsButton)
        CommonButtonSettings -Button $SmithFileSearchSearchResultsButton


        $SmithFileSearchDirectoryListingTextbox = New-Object System.Windows.Forms.TextBox -Property @{
            Left   = $FormScale * 3
            Top    = $SmithFileSearchDirectoryListingLabel.Top + $SmithFileSearchDirectoryListingLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 22
            MultiLine          = $False
            WordWrap           = $false
            Text               = "Enter a single directory"
            AutoCompleteSource = "FileSystem"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $SmithFileSearchDirectoryListingTextboxAdd_MouseEnter
            Add_MouseLeave = $SmithFileSearchDirectoryListingTextboxAdd_MouseLeave
            Add_MouseHover = $SmithFileSearchDirectoryListingTextboxAdd_MouseHover
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchDirectoryListingTextbox)


$SmithFileSearchFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "File Search (WinRM)"
    Left   = $FormScale * 3
    Top    = $SmithFileSearchDirectoryListingTextbox.Top + $SmithFileSearchDirectoryListingTextbox.Height + $($FormScale * 25)
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithFileSearchTab.Controls.Add($SmithFileSearchFileSearchCheckbox)


        $SmithFileSearchFileSearchMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $SmithFileSearchFileSearchCheckbox.Width + $($FormScale * 52)
            Top    = $SmithFileSearchFileSearchCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor  = "Black"
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchFileSearchMaxDepthLabel)


        $SmithFileSearchFileSearchMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $SmithFileSearchFileSearchMaxDepthLabel.Left + $SmithFileSearchFileSearchMaxDepthLabel.Width
            Top    = $SmithFileSearchFileSearchCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchFileSearchMaxDepthTextbox)


        $SmithFileSearchFileSearchLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Collection time depends on the number of files and directories, plus recursive depth."
            Left   = $FormScale * 3
            Top    = $SmithFileSearchFileSearchMaxDepthTextbox.Top + $SmithFileSearchFileSearchMaxDepthTextbox.Height + $($FormScale * 2)
            Width  = $FormScale * 450
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchFileSearchLabel)


        $SmithFileSearchSearchByFileHashLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Search by Filename or Filehash:"
            Left   = $SmithFileSearchFileSearchLabel.Left
            Top    = $SmithFileSearchFileSearchLabel.Top + $SmithFileSearchFileSearchLabel.Height
            Width  = $FormScale * 175
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchSearchByFileHashLabel)


        $SmithFileSearchSelectFileHashComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text   = "Filename"
            Left   = $SmithFileSearchSearchByFileHashLabel.Left + $SmithFileSearchSearchByFileHashLabel.Width
            Top    = $SmithFileSearchSearchByFileHashLabel.Top
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmithHashingAlgorithms = @('Filename','MD5','SHA1','SHA256','SHA384','SHA512','RIPEMD160')
        ForEach ($Hash in $SmithHashingAlgorithms) { $SmithFileSearchSelectFileHashComboBox.Items.Add($Hash) }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchSelectFileHashComboBox)


        $SmithFileSearchFileSearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = "Enter Directories; One Per Line"
            Left   = $FormScale * 3
            Top    = $SmithFileSearchSearchByFileHashLabel.Top + $SmithFileSearchSearchByFileHashLabel.Height + ($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 80
            MultiLine = $True
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $SmithFileSearchFileSearchDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $SmithFileSearchFileSearchDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $SmithFileSearchFileSearchDirectoryRichTextboxAdd_MouseHover
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchFileSearchDirectoryRichTextbox)


        $SmithFileSearchFileSearchFileRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = "Enter FileNames; One Per Line"
            Left   = $FormScale * 3
            Top    = $SmithFileSearchFileSearchDirectoryRichTextbox.Top + $SmithFileSearchFileSearchDirectoryRichTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 80
            MultiLine  = $True
            ScrollBars = "Vertical" #Horizontal
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $SmithFileSearchFileSearchFileRichTextboxAdd_MouseEnter
            Add_MouseLeave = $SmithFileSearchFileSearchFileRichTextboxAdd_MouseLeave
            Add_MouseHover = $SmithFileSearchFileSearchFileRichTextboxAdd_MouseHover
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchFileSearchFileRichTextbox)


$SmithFileSearchAlternateDataStreamCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Alternate Data Stream Search (WinRM)"
    Left   = $FormScale * 3
    Top    = $SmithFileSearchFileSearchFileRichTextbox.Top + $SmithFileSearchFileSearchFileRichTextbox.Height + $($FormScale * 20)
    Width  = $FormScale * 260
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$SmithFileSearchTab.Controls.Add($SmithFileSearchAlternateDataStreamCheckbox)


        $SmithFileSearchAlternateDataStreamMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $SmithFileSearchFileSearchCheckbox.Width + $($FormScale * 52)
            Top    = $SmithFileSearchAlternateDataStreamCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale *11),0,0,0)
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchAlternateDataStreamMaxDepthLabel)


        $SmithFileSearchAlternateDataStreamMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $SmithFileSearchAlternateDataStreamMaxDepthLabel.Left + $SmithFileSearchAlternateDataStreamMaxDepthLabel.Width
            Top    = $SmithFileSearchAlternateDataStreamCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchAlternateDataStreamMaxDepthTextbox)


        $SmithFileSearchAlternateDataStreamLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Exlcudes':`$DATA' stream, and will show the ADS name and its contents."
            Left   = $FormScale * 3
            Top    = $SmithFileSearchAlternateDataStreamMaxDepthTextbox.Top + $SmithFileSearchAlternateDataStreamMaxDepthTextbox.Height
            Width  = $FormScale * 450
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchAlternateDataStreamLabel)


        $SmithFileSearchAlternateDataStreamDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Directories; One Per Line"
            Left   = $FormScale * 3
            Top    = $SmithFileSearchAlternateDataStreamLabel.Top + $SmithFileSearchAlternateDataStreamLabel.Height
            Width  = $FormScale * 430
            Height = $FormScale * 80
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine     = $True
            Add_MouseEnter = $SmithFileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $SmithFileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $SmithFileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseHover
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchAlternateDataStreamDirectoryRichTextbox)


        $SmithFileSearchAlternateDataStreamDirectoryExtractStreamDataButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Retrieve & Extract Stream Data'
            Left   = $SmithFileSearchAlternateDataStreamDirectoryRichTextbox.Left + $SmithFileSearchAlternateDataStreamDirectoryRichTextbox.Width - $($FormScale * 200 - 1)
            Top    = $SmithFileSearchAlternateDataStreamDirectoryRichTextbox.Top + $SmithFileSearchAlternateDataStreamDirectoryRichTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 200
            Height = $FormScale * 20
            Add_Click = $SmithFileSearchAlternateDataStreamDirectoryExtractStreamDataButtonAdd_Click
        }
        $SmithFileSearchTab.Controls.Add($SmithFileSearchAlternateDataStreamDirectoryExtractStreamDataButton)
        CommonButtonSettings -Button $SmithFileSearchAlternateDataStreamDirectoryExtractStreamDataButton
