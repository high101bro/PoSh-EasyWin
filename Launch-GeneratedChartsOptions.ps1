$FormTitle = 'This is the title'
$FormScale = 2
$Font = 'Courier New'
$Dependencies = 'C:\Users\danie\Documents\GitHub\PoSh-EasyWin\Dependencies'

    $PS = gwmi win32_process | Select *


    $ChartGenerationOptionsForm = New-Object System.Windows.Forms.Form -Property @{
        Text   = "PoSh-EasyWin - Create Charts"
        Width  = $FormScale * 450
        Height = $FormScale * 500
        StartPosition = "CenterScreen"
        #Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        AutoScroll    = $True
        #FormBorderStyle =  "fixed3d"
        #ControlBox    = $false
        MaximizeBox   = $false
        MinimizeBox   = $false
        ShowIcon      = $true
        TopMost       = $true
        Add_Shown     = $ScriptBlockProgressBarInput
        Add_Closing = { $This.dispose() }
    }
    "$Dependencies\Images\PowerShell_Charts.png"

                $ChartGenerationPropertyList0PictureBox = New-Object Windows.Forms.PictureBox -Property @{
                    Text   = "PowerShell Charts"
                    Left   = $FormScale * 10
                    Top    = $FormScale * 10
                    Width  = $FormScale * 405
                    Height = $FormScale * 44
                    Image  = [System.Drawing.Image]::Fromfile("$Dependencies\Images\PowerShell_Charts.png")
                    SizeMode = 'StretchImage'
                }
                $script:ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList0PictureBox)


                $ChartGenerationPropertyList0Label = New-Object System.Windows.Forms.Label -Property @{
                    Text   = "Select among the following list boxes to generate charts. Use the Shift and Ctrl keys to select multiple properties."
                    Left   = $FormScale * 10
                    Top    = $ChartGenerationPropertyList0PictureBox.Top + $ChartGenerationPropertyList0PictureBox.Height + ($FormScale * 5)
                    Width  = $FormScale * 405
                    Height = $FormScale * 44
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                    ForeColor = 'Blue'
                }
                $ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList0Label)


                $ChartGenerationPropertyList1Label = New-Object System.Windows.Forms.Label -Property @{
                    Text   = "Counts the unique values found across all endpoints`n`nDefault Chart: Bar"
                    Left   = $FormScale * 10
                    Top    = $ChartGenerationPropertyList0Label.Top + $ChartGenerationPropertyList0Label.Height + ($FormScale * 5)
                    Width  = $FormScale * 200
                    Height = $FormScale * 50
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                }
                $ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList1Label)


                            $ChartGenerationPropertyList1ListBox = New-Object System.Windows.Forms.ListBox -Property @{
                                Name   = "ResultsListBox"
                                Left   = $FormScale * 10
                                Top    = $ChartGenerationPropertyList1Label.Top + $ChartGenerationPropertyList1Label.Height + ($FormScale * 5)
                                Width  = $FormScale * 200
                                Height = $FormScale * 200
                                FormattingEnabled   = $True
                                SelectionMode       = 'MultiExtended'
                                ScrollAlwaysVisible = $True
                                AutoSize            = $False
                                Font                = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                            }
                            $ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList1ListBox)


                            $ChartGenerationPropertyList1Button = New-Object System.Windows.Forms.Button -Property @{
                                Text   = "Select All"
                                Left   = $FormScale * 10
                                Top    = $ChartGenerationPropertyList1ListBox.Top + $ChartGenerationPropertyList1ListBox.Height + ($FormScale * 5)
                                Width  = $ChartGenerationPropertyList1ListBox.Width
                                Height = $FormScale * 22
                                Add_Click = {
                                    for($i = 0; $i -lt $ChartGenerationPropertyList1ListBox.Items.Count; $i++) { $ChartGenerationPropertyList1ListBox.SetSelected($i, $true) }
                                }
                            }
                            $ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList1Button)
                            CommonButtonSettings -Button $ChartGenerationPropertyList1Button


                $ChartGenerationPropertyList2Label = New-Object System.Windows.Forms.Label -Property @{
                    Text   = "Counts the total values found across all endpoints.`n`nDefault Chart: Pie"
                    Left   = $ChartGenerationPropertyList1Label.Left + $ChartGenerationPropertyList1Label.Width + ($FormScale * 10)
                    Top    = $ChartGenerationPropertyList1Label.Top
                    Width  = $FormScale * 200
                    Height = $FormScale * 50
                    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
                }
                $ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList2Label)


                            $ChartGenerationPropertyList2ListBox = New-Object System.Windows.Forms.ListBox -Property @{
                                Name   = "ResultsListBox"
                                Left   = $ChartGenerationPropertyList2Label.Left
                                Top    = $ChartGenerationPropertyList2Label.Top + $ChartGenerationPropertyList2Label.Height + ($FormScale * 5)
                                Width  = $FormScale * 200
                                Height = $FormScale * 200
                                FormattingEnabled   = $True
                                SelectionMode       = 'MultiExtended'
                                ScrollAlwaysVisible = $True
                                AutoSize            = $False
                                Font                = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                            }
                            $ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList2ListBox)


                            $ChartGenerationPropertyList2Button = New-Object System.Windows.Forms.Button -Property @{
                                Text   = "Select All"
                                Left   = $ChartGenerationPropertyList2ListBox.Left
                                Top    = $ChartGenerationPropertyList2ListBox.Top + $ChartGenerationPropertyList2ListBox.Height + ($FormScale * 5)
                                Width  = $ChartGenerationPropertyList2ListBox.Width
                                Height = $FormScale * 22
                                Add_Click = {
                                    for($i = 0; $i -lt $ChartGenerationPropertyList2ListBox.Items.Count; $i++) { $ChartGenerationPropertyList2ListBox.SetSelected($i, $true) }
                                }
                            }
                            $ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList2Button)
                            CommonButtonSettings -Button $ChartGenerationPropertyList2Button


                $ChartProperties = $PS[0] | ForEach-Object { $_.psobject.properties.name }
                foreach ( $Property in $ChartProperties ) { $ChartGenerationPropertyList1ListBox.Items.Add($Property) }
                foreach ( $Property in $ChartProperties ) { $ChartGenerationPropertyList2ListBox.Items.Add($Property) }


                $ChartGenerationPropertyList3Button = New-Object System.Windows.Forms.Button -Property @{
                    Text   = "Generate Charts"
                    Left   = $ChartGenerationPropertyList0Label.Left
                    Top    = $ChartGenerationPropertyList1Button.Top + $ChartGenerationPropertyList1Button.Height + ($FormScale * 5)
                    Width  = $ChartGenerationPropertyList0Label.Width + ($FormScale * 5)
                    Height = $FormScale * 44
                    Add_Click = { }
                }
                $ChartGenerationOptionsForm.Controls.Add($ChartGenerationPropertyList3Button)
                CommonButtonSettings -Button $ChartGenerationPropertyList3Button


    $ChartGenerationOptionsForm.ShowDialog()










