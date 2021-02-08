
$Section1FileSearchTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "File Search"
    Left   = $FormScale * 3
    Top    = $FormScale * -10
    Width  = $FormScale * 450
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftCollectionsTabControl.Controls.Add($Section1FileSearchTab)

# Recursively goes through directories down to the specified depth
# Used for backwards compatibility with systems that have older PowerShell versions, newer versions of PowerShell has a -Depth parameter
Update-FormProgress "$Dependencies\Code\Main Body\Get-ChildItemDepth.ps1"
. "$Dependencies\Code\Main Body\Get-ChildItemDepth.ps1"

# This code is used within both the Individual and Session Based execution modes
Update-FormProgress "$Dependencies\Code\Main Body\Conduct-FileSearch.ps1"
. "$Dependencies\Code\Main Body\Conduct-FileSearch.ps1"

$FileSearchDirectoryListingCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Directory Listing (WinRM)"
    Left   = $FormScale * 3
    Top    = $FormScale * 15
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingCheckbox)


        $FileSearchDirectoryListingMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchDirectoryListingCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchDirectoryListingCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor  = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthLabel)


        $FileSearchDirectoryListingMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchDirectoryListingMaxDepthLabel.Left + $FileSearchDirectoryListingMaxDepthLabel.Width
            Top    = $FileSearchDirectoryListingCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingMaxDepthTextbox)


        $FileSearchDirectoryListingLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Collection time is dependant on the directory's contents."
            Left   = $FormScale * 3
            Top    = $FileSearchDirectoryListingCheckbox.Top + $FileSearchDirectoryListingCheckbox.Height + $($FormScale * 5)
            Width  = $FormScale * 330
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingLabel)


        Update-FormProgress "$Dependencies\Code\Main Body\Search-DirectoryTreeview.ps1"
        . "$Dependencies\Code\Main Body\Search-DirectoryTreeview.ps1"
        $FileSearchSearchResultsButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = "Search Results"
            Left   = $FileSearchDirectoryListingLabel.Left + $FileSearchDirectoryListingLabel.Width
            Top    = $FileSearchDirectoryListingLabel.Top
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
        $Section1FileSearchTab.Controls.Add($FileSearchSearchResultsButton)
        CommonButtonSettings -Button $FileSearchSearchResultsButton


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\TextBox\FileSearchDirectoryListingTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\TextBox\FileSearchDirectoryListingTextbox.ps1"
        $FileSearchDirectoryListingTextbox = New-Object System.Windows.Forms.TextBox -Property @{
            Left   = $FormScale * 3
            Top    = $FileSearchDirectoryListingLabel.Top + $FileSearchDirectoryListingLabel.Height + $($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 22
            MultiLine          = $False
            WordWrap           = $false
            Text               = "Enter a single directory"
            AutoCompleteSource = "FileSystem"
            AutoCompleteMode   = "SuggestAppend"
            Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchDirectoryListingTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchDirectoryListingTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchDirectoryListingTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchDirectoryListingTextbox)


$FileSearchFileSearchCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "File Search (WinRM)"
    Left   = $FormScale * 3
    Top    = $FileSearchDirectoryListingTextbox.Top + $FileSearchDirectoryListingTextbox.Height + $($FormScale * 25)
    Width  = $FormScale * 230
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchFileSearchCheckbox)


        $FileSearchFileSearchMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchFileSearchCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchFileSearchCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor  = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthLabel)


        $FileSearchFileSearchMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchFileSearchMaxDepthLabel.Left + $FileSearchFileSearchMaxDepthLabel.Width
            Top    = $FileSearchFileSearchCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            WordWrap  = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchMaxDepthTextbox)


        $FileSearchFileSearchLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Collection time depends on the number of files and directories, plus recursive depth."
            Left   = $FormScale * 3
            Top    = $FileSearchFileSearchMaxDepthTextbox.Top + $FileSearchFileSearchMaxDepthTextbox.Height + $($FormScale * 2)
            Width  = $FormScale * 450
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchLabel)


        $FileSearchSearchByFileHashLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Search by Filename or Filehash:"
            Left   = $FileSearchFileSearchLabel.Left
            Top    = $FileSearchFileSearchLabel.Top + $FileSearchFileSearchLabel.Height
            Width  = $FormScale * 175
            Height = $FormScale * 22
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchSearchByFileHashLabel)


        Update-FormProgress "$Dependencies\Code\Main Body\Get-FileHash.ps1"
        . "$Dependencies\Code\Main Body\Get-FileHash.ps1"
        $FileSearchSelectFileHashComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
            Text   = "Filename"
            Left   = $FileSearchSearchByFileHashLabel.Left + $FileSearchSearchByFileHashLabel.Width
            Top    = $FileSearchSearchByFileHashLabel.Top
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $HashingAlgorithms = @('Filename','MD5','SHA1','SHA256','SHA384','SHA512','RIPEMD160')
        ForEach ($Hash in $HashingAlgorithms) { $FileSearchSelectFileHashComboBox.Items.Add($Hash) }
        $Section1FileSearchTab.Controls.Add($FileSearchSelectFileHashComboBox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchDirectoryRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchDirectoryRichTextbox.ps1"
        $FileSearchFileSearchDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = "Enter Directories; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchSearchByFileHashLabel.Top + $FileSearchSearchByFileHashLabel.Height + ($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 80
            MultiLine = $True
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchFileSearchDirectoryRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchDirectoryRichTextbox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchFileRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchFileSearchFileRichTextbox.ps1"
        $FileSearchFileSearchFileRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = "Enter FileNames; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchFileSearchDirectoryRichTextbox.Top + $FileSearchFileSearchDirectoryRichTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 430
            Height = $FormScale * 80
            MultiLine  = $True
            ScrollBars = "Vertical" #Horizontal
            Font       = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            Add_MouseEnter = $FileSearchFileSearchFileRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchFileSearchFileRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchFileSearchFileRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchFileSearchFileRichTextbox)


Update-FormProgress "$Dependencies\Code\Main Body\Search-AlternateDataStream.ps1"
. "$Dependencies\Code\Main Body\Search-AlternateDataStream.ps1"
$FileSearchAlternateDataStreamCheckbox = New-Object System.Windows.Forms.CheckBox -Property @{
    Text   = "Alternate Data Stream Search (WinRM)"
    Left   = $FormScale * 3
    Top    = $FileSearchFileSearchFileRichTextbox.Top + $FileSearchFileSearchFileRichTextbox.Height + $($FormScale * 20)
    Width  = $FormScale * 260
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = 'Blue'
    Add_Click = { Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands }
}
$Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamCheckbox)


        $FileSearchAlternateDataStreamMaxDepthLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Recursive Depth"
            Left   = $FileSearchFileSearchCheckbox.Width + $($FormScale * 52)
            Top    = $FileSearchAlternateDataStreamCheckbox.Top + $($FormScale * 5)
            Width  = $FormScale * 100
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale *11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthLabel)


        $FileSearchAlternateDataStreamMaxDepthTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Text   = 0
            Left   = $FileSearchAlternateDataStreamMaxDepthLabel.Left + $FileSearchAlternateDataStreamMaxDepthLabel.Width
            Top    = $FileSearchAlternateDataStreamCheckbox.Top + $($FormScale * 2)
            Width  = $FormScale * 50
            Height = $FormScale * 20
            MultiLine = $false
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamMaxDepthTextbox)


        $FileSearchAlternateDataStreamLabel = New-Object System.Windows.Forms.Label -Property @{
            Text   = "Exlcudes':`$DATA' stream, and will show the ADS name and its contents."
            Left   = $FormScale * 3
            Top    = $FileSearchAlternateDataStreamMaxDepthTextbox.Top + $FileSearchAlternateDataStreamMaxDepthTextbox.Height
            Width  = $FormScale * 450
            Height = $FormScale * 22
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            ForeColor = "Black"
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamLabel)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchAlternateDataStreamDirectoryRichTextbox.ps1"
        . "$Dependencies\Code\System.Windows.Forms\RichTextBox\FileSearchAlternateDataStreamDirectoryRichTextbox.ps1"
        $FileSearchAlternateDataStreamDirectoryRichTextbox = New-Object System.Windows.Forms.RichTextBox -Property @{
            Lines  = "Enter Directories; One Per Line"
            Left   = $FormScale * 3
            Top    = $FileSearchAlternateDataStreamLabel.Top + $FileSearchAlternateDataStreamLabel.Height
            Width  = $FormScale * 430
            Height = $FormScale * 80
            Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
            MultiLine     = $True
            Add_MouseEnter = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseEnter
            Add_MouseLeave = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseLeave
            Add_MouseHover = $FileSearchAlternateDataStreamDirectoryRichTextboxAdd_MouseHover
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryRichTextbox)


        Update-FormProgress "$Dependencies\Code\System.Windows.Forms\Button\FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.ps1"
        . "$Dependencies\Code\System.Windows.Forms\Button\FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.ps1"
        . "$Dependencies\Code\Main Body\Get-RemoteAlternateDataStream.ps1"
        $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton = New-Object System.Windows.Forms.Button -Property @{
            Text   = 'Retrieve and Extract Stream Data'
            Left   = $FileSearchAlternateDataStreamDirectoryRichTextbox.Left + $FileSearchAlternateDataStreamDirectoryRichTextbox.Width - $($FormScale * 200 - 1)
            Top    = $FileSearchAlternateDataStreamDirectoryRichTextbox.Top + $FileSearchAlternateDataStreamDirectoryRichTextbox.Height + $($FormScale * 5)
            Width  = $FormScale * 200
            Height = $FormScale * 20
            Add_Click = $FileSearchAlternateDataStreamDirectoryExtractStreamDataButtonAdd_Click
        }
        $Section1FileSearchTab.Controls.Add($FileSearchAlternateDataStreamDirectoryExtractStreamDataButton)
        CommonButtonSettings -Button $FileSearchAlternateDataStreamDirectoryExtractStreamDataButton
