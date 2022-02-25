param(
    $FormScale
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework


[System.Windows.MessageBox]::Show(@"
PoSh-PopQuis is a PowerShell Questions Generator that allows you to select modules to populate a question pool to test your knowledge by either answering questions manually or by multiple choice. This tool requires an updated Get-Help database to create its content which can be updated with the Update-Help cmdlet. You can install additional modules for added questions.

Copyright (C) 2020  Daniel S Komnick 
https://www.github.com/high101bro/

This program is free software: you can redistribute it and/or modify it under the  terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

A copy of the GNU General Public License (GPLv3) is located at https://www.gnu.org/licenses/.
"@,'Copy Right / EULA')


$CommandsToBeQuestioned = Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow'

$Modules = $CommandsToBeQuestioned | Select-Object ModuleName -Unique | Sort-Object ModuleName | Where-Object {$_.ModuleName -ne ''}

#$AllCommands = $ModulesThatAreCurrentlyImported.ExportedCommands.Values.Name
#$Sources     = $ModulesThatAreCurrentlyImported.ExportedCommands.Values.Source | Sort-Object -Unique


function Generate-PopQuiz {
    param(
        $CommandsToBeQuestioned = $CommandsToBeQuestioned,
        [string[]]$ModuleName,
        [int]$NumberofQuestions
    )
    $script:GradedTest          = $false
    $script:CurrentQuestion     = ''
    $script:CurrentButton       = ''
    $script:CurrentQuestionList = @()
    $script:Answers             = @{}
    $script:Points              = @{}
    
    $script:PopQuizAnswerTextBox.Text  = ''
    $script:PopQuizAnswerSubmittedTextBox.Text = ''
    $PopQuizGenerateButton.BackColor = 'LightGray'

    Count-Questions
    $script:PopQuizPool = $script:PopQuizPool | Sort-Object {Get-Random} | Where-Object {$_ -ne '' -or $_ -ne $null} | Select-Object -First $NumberofQuestions | Sort-Object {Get-Random}

    $script:TotalNumberOfCommands = $script:PopQuizPool.Count

    $script:InCrementQ = 0
    $script:IncrementX = 2
    $script:IncrementY = 0
    foreach ($q in $script:PopQuizPool) {
        $script:Question = $q
        # Creates the question buttons at the lower left of the GUI
        $script:InCrementQ += 1
        Invoke-Expression @"

        `$script:HintCount = 0
        `$script:Question$($script:InCrementQ)Hint = @()
        `$script:NoMoreHints = `$false
        `$CmdletHelp = Get-Help `$script:Question
        `$script:Points.Set_Item($($script:InCrementQ-1),'2.0')

            `$CmdletModule = `$script:Question | Select-Object -ExpandProperty Source
            `$script:Question$($script:InCrementQ)Hint += `@"
        Module = `$(`$CmdletModule.trim("`r`n"))
`"@
    
            # Adds Hint for syntax
            `$CmdletSyntax = `$CmdletHelp.Syntax
            `$CmdletSyntax = (`$CmdletSyntax | Out-String).Replace("`$script:Question",'     VERB-NOUN').Replace("`r`n`r`n","???").Replace("`r`n","").Replace("???","`r`n`r`n").Trim("`r`n")
            `$script:Question$($script:InCrementQ)Hint += `$CmdletSyntax.trim("`r`n")
        
            # Adds Hint for description
            if (`$(`$script:Question.Description) -ne ''){
                `$CmdletDescription = `$CmdletHelp.Description
                `$CmdletDescription = (`$CmdletDescription | Out-String).Replace("`$script:Question",'VERB-NOUN').Replace("`r`n`r`n","???").Replace("`r`n","").Trim("`r`n").Trim("?").Replace("???","`r`n`r`n     ")
            `$script:Question$($script:InCrementQ)Hint += `@"
    `$(`$CmdletDescription.trim("`r`n"))
`"@
            }
    
            # Adds Hint for VERB
            if ("`$script:Question" -match "\-"){
                `$script:Question$($script:InCrementQ)Hint += `@"
        Cmdlet Verb = `$((`$script:Question -split '-')[0])
`"@
            }
    
        # Adds Hint for examples - one hint for each example 
        `$CmdletExamples = `$CmdletHelp.Examples
        `$Separator = 'Example \d. '
        `$CmdletExamples = (`$CmdletExamples | Out-String) -split `$Separator
        `$ExampleCount = 1
        foreach (`$Example in `$(`$CmdletExamples | Select-Object -Skip 1) ){
            `$Example = (`$Example | Out-String).Replace("`$script:Question",'VERB-NOUN')
            `$script:Question$($script:InCrementQ)Hint += `@"
    Example: `$ExampleCount
    `$(`$Example.trim("`r`n").Replace("`$script:Question",'VERB-NOUN'))
`"@
            `$ExampleCount += 1
        }
    
        # Adds Hint for Parameters
        `$CmdletParameters = `$CmdletHelp.Parameters
        `$CmdletParameters = (`$CmdletParameters | Out-String).Replace("`$script:Question",'VERB-NOUN').Replace("`r`n`r`n","`r`n")
        `$script:Question$($script:InCrementQ)Hint += `@"
    `$(`$CmdletParameters.trim("`r`n"))
`"@


    # Unchecks all multiple choice radio buttons
    `$script:PopQuizMultipleChoice1RadioButton.Checked = `$False
    `$script:PopQuizMultipleChoice2RadioButton.Checked = `$False
    `$script:PopQuizMultipleChoice3RadioButton.Checked = `$False
    `$script:PopQuizMultipleChoice4RadioButton.Checked = `$False
    `$script:PopQuizMultipleChoice5RadioButton.Checked = `$False
    `$script:PopQuizMultipleChoice6RadioButton.Checked = `$False
    `$script:PopQuizMultipleChoice7RadioButton.Checked = `$False
    `$script:PopQuizMultipleChoice8RadioButton.Checked = `$False


    `$script:RandomQuestionPool = `$script:PopQuizPool
    function Generate-RandomQuestion {
        `$RandQues = `$(`$script:RandomQuestionPool[`$(Get-Random -Minimum 0 -Maximum `$(`$script:RandomQuestionPool.Count -1))])
        `$script:RandomQuestionPool = `$script:RandomQuestionPool | Where-Object {`$_ -ne `$RandQues} 
        return `$RandQues
    }

    `$Script:RandomQuestion$($script:InCrementQ)List = @(
        `$(Generate-RandomQuestion),
        `$(Generate-RandomQuestion),
        `$(Generate-RandomQuestion),
        `$(Generate-RandomQuestion),
        `$(Generate-RandomQuestion),
        `$(Generate-RandomQuestion),
        `$(Generate-RandomQuestion),
        `$(Generate-RandomQuestion)
    )

    # Reselected a random question if it happnes to match the answer, helps reduce the occurance of double 'correct answer' encounters
    foreach (`$RandomQuestion in `$Script:RandomQuestion$($script:InCrementQ)List){
        if (`$RandomQuestion -eq `$script:Question -or `$RandomQuestion -eq '' -or `$RandomQuestion -eq `$null) {
            `$RandomQuestion = `$script:PopQuizPool[`$(Get-Random -Minimum 0 -Maximum `$(`$script:PopQuizPool.Count - 1))] | Where-Object {`$_ -ne `$script:Question -and `$_ -ne `$Script:RandomQuestion$($script:InCrementQ)List[0] -and `$_ -ne `$Script:RandomQuestion$($script:InCrementQ)List[1] -and `$_ -ne `$Script:RandomQuestion$($script:InCrementQ)List[2] -and `$_ -ne `$Script:RandomQuestion$($script:InCrementQ)List[3] -and `$_ -ne `$Script:RandomQuestion$($script:InCrementQ)List[4] -and `$_ -ne `$Script:RandomQuestion$($script:InCrementQ)List[5] -and `$_ -ne `$Script:RandomQuestion$($script:InCrementQ)List[6] -and `$_ -ne `$Script:RandomQuestion$($script:InCrementQ)List[7] }
        }
    }

    `$script:PopQuizMultipleChoice1RadioButton.Text = "Question 1"
    `$script:PopQuizMultipleChoice2RadioButton.Text = "Question 2"
    `$script:PopQuizMultipleChoice3RadioButton.Text = "Question 3"
    `$script:PopQuizMultipleChoice4RadioButton.Text = "Question 4"
    `$script:PopQuizMultipleChoice5RadioButton.Text = "Question 5"
    `$script:PopQuizMultipleChoice6RadioButton.Text = "Question 6"
    `$script:PopQuizMultipleChoice7RadioButton.Text = "Question 7"
    `$script:PopQuizMultipleChoice8RadioButton.Text = "Question 8"

    `$PoShPopQuiz.Refresh()

        # Generates Question buttons
        `$script:Status$($script:InCrementQ)Button = New-Object -TypeName System.Windows.Forms.Button -Property @{
            Text = "$script:InCrementQ"
            Location = @{ X = `$(`$FormScale * 10) + `$script:IncrementX
                          Y = `$(`$FormScale * 20) + `$script:IncrementY }
            Size     = @{ Width  = `$FormScale * 27
                          Height = `$FormScale * 18 }
            Font = New-Object System.Drawing.Font("Courier New",`$(`$FormScale * 10),0,0,0)
            ForeColor = 'Blue'
            UseVisualStyleBackColor = `$true
            Add_Click = {

                # if the button is selected, it will be different than the others
                foreach (`$num in (1..50)) {
                    Invoke-Expression "try{```$script:Status`$(`$num)Button.ResetForeColor()} catch{}"
                }
                if (`$This.BackColor -eq 'GreenYellow' ) { `$This.ForeColor = 'Red' }
                elseif (`$This.BackColor -eq 'Red' ) { `$This.ForeColor = 'Yellow' }
                else { 
                    if (`$script:GradedTest -eq `$false) { `$This.ForeColor = 'Red' }
                    else { `$This.ForeColor = 'Yellow' }
                }

                `$script:PopQuizAnswerTextBox.focus()

                `$script:CurrentQuestion  = `$script:PopQuizPool[$script:InCrementQ - 1]
                `$script:CurrentAnswerNum = $script:InCrementQ
                
                `$script:CurrentButton    = `$This

                `$script:PopQuizAnswerSubmittedTextBox.Text = `$script:Answers[$($script:InCrementQ - 1)]
                `$script:QuestionPointValueLabel.Text = `$script:Points[$($script:InCrementQ - 1)]

                `$script:CurrentQuestionList = `$Script:RandomQuestion$($script:InCrementQ)List
                

                # Reselected a random question if it happnes to match the answer, helps reduce the occurance of double 'correct answer' encounters
                `$quesnum = 0
                foreach (`$RandomQuestion in `$script:CurrentQuestionList){
                    if (`$RandomQuestion -eq `$script:CurrentQuestion) {
                        `$script:CurrentQuestionList[`$quesnum] = `$script:PopQuizPool[`$(Get-Random -Minimum 0 -Maximum `$(`$script:PopQuizPool.Count - 1))] | Where-Object {`$_ -ne `$script:CurrentQuestion -and `$_ -ne `$script:CurrentQuestionList[0] -and `$_ -ne `$script:CurrentQuestionList[1] -and `$_ -ne `$script:CurrentQuestionList[2] -and `$_ -ne `$script:CurrentQuestionList[3] -and `$_ -ne `$script:CurrentQuestionList[4] -and `$_ -ne `$script:CurrentQuestionList[5] }
                    }
                    elseif (`$RandomQuestion -eq '' -or `$RandomQuestion -eq `$null) {
                        `$script:CurrentQuestionList[`$quesnum] = `$script:PopQuizPool[`$(Get-Random -Minimum 0 -Maximum `$(`$script:PopQuizPool.Count - 1))] | Where-Object {`$_ -ne `$script:CurrentQuestion -and `$_ -ne `$script:CurrentQuestionList[0] -and `$_ -ne `$script:CurrentQuestionList[1] -and `$_ -ne `$script:CurrentQuestionList[2] -and `$_ -ne `$script:CurrentQuestionList[3] -and `$_ -ne `$script:CurrentQuestionList[4] -and `$_ -ne `$script:CurrentQuestionList[5] }
                    }
                    `$quesnum += 1
                }
                # Assigns the correct answer to a random radio button
                `$script:CurrentQuestionList[$(Get-Random -Minimum 0 -Maximum 8)] = `$script:CurrentQuestion

                `$script:HintCount   = 0
                `$script:NoMoreHints = `$false
                `$script:CurrentHint = `$script:Question$($script:InCrementQ)Hint

                `$PopQuizQuestionGroupBox.Text = "Question: #$script:InCrementQ"
                `$PopQuizAnswerGroupBox.Text   = "Type In Command: #$script:InCrementQ"
                                
                `$script:PopQuizAnswerTextBox.text = ''
                `$PopQuizQuestion = `$script:PopQuizPool[$script:InCrementQ - 1]
                
                `$PopQuizSynopsis = `$(Get-Help "`$PopQuizQuestion" | Select-Object -ExpandProperty Synopsis).Replace("`$script:CurrentQuestion",'VERB-NOUN')
                `$PopQuizQuestionRichTextBox.Text = `@"

Which Cmdlet, Alias, Function, or Workflow does the following?

    `$PopQuizSynopsis
`"@

                `$script:PopQuizMultipleChoiceCheckBox.Text = "Multiple Choice: #$script:InCrementQ"
                if (`$PopQuizMultipleChoiceStayCheckCheckBox.checked) { `$script:PopQuizMultipleChoiceCheckBox.checked = `$true }
                else { `$script:PopQuizMultipleChoiceCheckBox.checked = `$false }
                `$script:PopQuizMultipleChoice1RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice2RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice3RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice4RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice5RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice6RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice7RadioButton.Checked = `$False
                `$script:PopQuizMultipleChoice8RadioButton.Checked = `$False

                if (-not `$script:GradedTest) { Update-MultipleChoice }

                # Highlights the correct answer within the multiple choice section
                if (`$script:GradedTest) {
                    `$script:PopQuizMultipleChoiceCheckBox.Enabled   = `$true
                    `$script:PopQuizMultipleChoiceCheckBox.checked   = `$true
                    #`$script:PopQuizMultipleChoiceCheckBox.ForeColor = 'red'
                    Update-MultipleChoice

                    `$script:PopQuizMultipleChoiceCheckBox.Enabled     = `$false
                    `$script:PopQuizMultipleChoice1RadioButton.Enabled = `$False
                    `$script:PopQuizMultipleChoice2RadioButton.Enabled = `$False
                    `$script:PopQuizMultipleChoice3RadioButton.Enabled = `$False
                    `$script:PopQuizMultipleChoice4RadioButton.Enabled = `$False
                    `$script:PopQuizMultipleChoice5RadioButton.Enabled = `$False
                    `$script:PopQuizMultipleChoice6RadioButton.Enabled = `$False
                    `$script:PopQuizMultipleChoice7RadioButton.Enabled = `$False
                    `$script:PopQuizMultipleChoice8RadioButton.Enabled = `$False
                        
                    `$script:CurrentQuestionList = `$Script:RandomQuestion$($script:InCrementQ)List
                    if (`$script:PopQuizMultipleChoice1RadioButton.text -eq "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){
                        `$script:PopQuizMultipleChoice1RadioButton.ForeColor = 'Black'
                        `$script:PopQuizMultipleChoice1RadioButton.BackColor = 'GreenYellow'
                    }
                    if (`$script:PopQuizMultipleChoice2RadioButton.text -eq "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){
                        `$script:PopQuizMultipleChoice2RadioButton.ForeColor = 'Black'
                        `$script:PopQuizMultipleChoice2RadioButton.BackColor = 'GreenYellow'
                    }
                    if (`$script:PopQuizMultipleChoice3RadioButton.text -eq "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){    
                        `$script:PopQuizMultipleChoice3RadioButton.ForeColor = 'Black'
                        `$script:PopQuizMultipleChoice3RadioButton.BackColor = 'GreenYellow'
                    }
                    if (`$script:PopQuizMultipleChoice4RadioButton.text -eq "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){
                        `$script:PopQuizMultipleChoice4RadioButton.ForeColor = 'Black'
                        `$script:PopQuizMultipleChoice4RadioButton.BackColor = 'GreenYellow'
                    }
                    if (`$script:PopQuizMultipleChoice5RadioButton.text -eq "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){
                        `$script:PopQuizMultipleChoice5RadioButton.ForeColor = 'Black'
                        `$script:PopQuizMultipleChoice5RadioButton.BackColor = 'GreenYellow'
                    }
                    if (`$script:PopQuizMultipleChoice6RadioButton.text -eq "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){
                        `$script:PopQuizMultipleChoice6RadioButton.ForeColor = 'Black'
                        `$script:PopQuizMultipleChoice6RadioButton.BackColor = 'GreenYellow'
                    }
                    if (`$script:PopQuizMultipleChoice7RadioButton.text -eq "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){
                        `$script:PopQuizMultipleChoice7RadioButton.ForeColor = 'Black'
                        `$script:PopQuizMultipleChoice7RadioButton.BackColor = 'GreenYellow'
                    }
                    if (`$script:PopQuizMultipleChoice8RadioButton.text -eq "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){
                        `$script:PopQuizMultipleChoice8RadioButton.ForeColor = 'Black'
                        `$script:PopQuizMultipleChoice8RadioButton.BackColor = 'GreenYellow'
                    }

                    if (`$script:PopQuizMultipleChoice1RadioButton.text -ne "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){`$script:PopQuizMultipleChoice1RadioButton.ResetBackColor()}
                    if (`$script:PopQuizMultipleChoice2RadioButton.text -ne "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){`$script:PopQuizMultipleChoice2RadioButton.ResetBackColor()}
                    if (`$script:PopQuizMultipleChoice3RadioButton.text -ne "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){`$script:PopQuizMultipleChoice3RadioButton.ResetBackColor()}
                    if (`$script:PopQuizMultipleChoice4RadioButton.text -ne "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){`$script:PopQuizMultipleChoice4RadioButton.ResetBackColor()}
                    if (`$script:PopQuizMultipleChoice5RadioButton.text -ne "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){`$script:PopQuizMultipleChoice5RadioButton.ResetBackColor()}
                    if (`$script:PopQuizMultipleChoice6RadioButton.text -ne "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){`$script:PopQuizMultipleChoice6RadioButton.ResetBackColor()}                                
                    if (`$script:PopQuizMultipleChoice7RadioButton.text -ne "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){`$script:PopQuizMultipleChoice7RadioButton.ResetBackColor()}
                    if (`$script:PopQuizMultipleChoice8RadioButton.text -ne "`$(`$script:PopQuizPool[$($script:InCrementQ - 1)].Name)"){`$script:PopQuizMultipleChoice8RadioButton.ResetBackColor()}                                
                }                
            }
        }
        `$StatusGroupBox.Controls.Remove(`$script:Status$($script:InCrementQ)Button)
        `$StatusGroupBox.Controls.Add(`$script:Status$($script:InCrementQ)Button)
        `$script:IncrementX += `$FormScale * 32

        CommonButtonSettings -Button `$script:Status$($script:InCrementQ)Button
"@
        # Counts 10 buttons per row, then starts a new one
        if ($script:InCrementQ % 10 -eq 0) {
            $script:IncrementX = $FormScale * 2
            $script:IncrementY += $FormScale * 28
        }
        # Sets the startup/initial questions as the first button/question
        $script:CurrentButton = $script:Status1Button
        $script:Status1Button.ForeColor = 'Red'
    }  
    
    $script:CurrentQuestion     = $script:PopQuizPool[0]
    $script:CurrentQuestionList = $Script:RandomQuestion1List

    $script:CurrentQuestionList[$(Get-Random -Minimum 0 -Maximum 6)] = $script:CurrentQuestion

    $script:HintCount           = 0
    $script:CurrentHint         = $script:Question1Hint
    $script:CurrentAnswerNum    = '1'
    $script:QuestionPointValueLabel.Text = $(2).ToString('0.0')
    $PopQuizQuestionGroupBox.Text = "Question: #1"
    $PopQuizAnswerGroupBox.Text   = "Type In Command: #1"
    $script:PopQuizMultipleChoiceCheckBox.Text = "Multiple Choice: #1"

   
    $PopQuizQuestionRichTextBox.Text = @"

Which Cmdlet, Alias, Function, or Workflow does the following?

    $(Get-Help "$script:CurrentQuestion" | Select-Object -ExpandProperty Synopsis)
"@

    $PopQuizManualEntrySubmitButton.Enabled = $True
    $script:PopQuizMultipleChoiceSubmitButton.Enabled = $True
    $script:PopQuizMultipleChoiceSubmitButton.BringToFront()
    $PopQuizHelpButton.Enabled = $true
    $script:PopQuizAnswerTextBox.Enabled = $true
    $PopQuizManualEntrySubmitButton.Enabled = $true
    $script:PopQuizAnswerSubmittedTextBox.Enabled = $true
    $PopQuizGradeButton.Enabled = $true
    $script:PopQuizMultipleChoiceCheckBox.Enabled = $true
    $PopQuizMultipleChoiceStayCheckCheckBox.Enabled = $true
    $PreviousQuestionButton.Enabled = $true
    $NextQuestionButton.Enabled = $true

    $script:PopQuizMultipleChoice1RadioButton.ResetBackColor()
    $script:PopQuizMultipleChoice2RadioButton.ResetBackColor()
    $script:PopQuizMultipleChoice3RadioButton.ResetBackColor()
    $script:PopQuizMultipleChoice4RadioButton.ResetBackColor()
    $script:PopQuizMultipleChoice5RadioButton.ResetBackColor()
    $script:PopQuizMultipleChoice6RadioButton.ResetBackColor()
    $script:PopQuizMultipleChoice7RadioButton.ResetBackColor()
    $script:PopQuizMultipleChoice8RadioButton.ResetBackColor()
}


function CommonButtonSettings {
    param($Button)
    $Button.Font      = New-Object System.Drawing.Font('Arial',$($FormScale * 11),0,0,0)
    $Button.ForeColor = "Black"
    $Button.Flatstyle = 'Flat'
    $Button.UseVisualStyleBackColor = $true
    #$Button.FlatAppearance.BorderSize        = 1
    $Button.BackColor = 'LightGray'
    $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray
}


function Count-Questions {
    $NumberChecked = 0
    foreach ($ModuleName in $ModuleCheckListBox.items){
        #$ModuleCheckListBox.SetItemChecked($ModuleLocation, $true) 
        if ($ModuleName.checked){$NumberChecked += 1}
    }
    $script:NumberOfQuestionPoolSizeLabel.text = "Questions Available Within Modules: $NumberChecked"

    $script:PopQuizPool = @()
    foreach ($ModuledChecked in $ModuleCheckListBox.CheckedItems){
        $script:PopQuizPool += $CommandsToBeQuestioned | Where-Object {$_.ModuleName -eq $ModuledChecked}
        $script:NumberOfQuestionPoolSizeLabel.text = "Questions Available Within Modules: $($script:PopQuizPool.count)"
        $script:NumberOfQuestionPoolSizeLabel.ForeColor = 'Red'
        $PoShPopQuiz.Refresh()
    }

    $script:NumberOfQuestionPoolSizeLabel.text = "Questions Available Within Modules: $($script:PopQuizPool.count)"
    $script:NumberOfQuestionPoolSizeLabel.ForeColor = 'Black'
}


$PoShPopQuiz = New-Object System.Windows.Forms.Form -Property @{
    Text          = "PoSh-PopQuiz   [$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)]"
    StartPosition = "CenterScreen"
    Size          = @{ Width  = $FormScale * 990
                       Height = $FormScale * 625 }
    AutoScroll    = $True
    FormBorderStyle =  'Sizable' #  Fixed3D, FixedDialog, FixedSingle, FixedToolWindow, None, Sizable, SizableToolWindow
    Font = New-Object System.Drawing.Font("Arial",$($FormScale * 11),0,0,0)
}



$PowerShellModulesGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "PowerShell Modules"
    Location = @{ X = $FormScale * 10
                  Y = $FormScale * 10 }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * 440 }
    ForeColor = 'Blue'
    Font = New-Object System.Drawing.Font("Arial",$($FormScale * 11),0,0,0)
}
$PoShPopQuiz.Controls.Add($PowerShellModulesGroupBox)



$ModuleCheckListBox = New-Object -TypeName System.Windows.Forms.CheckedListBox -Property @{
    Location = @{ X = $FormScale * 10
                  Y = $FormScale * 20 }
    Size     = @{ Width  = $FormScale * 230
                  Height = $FormScale * 410 }
    ScrollAlwaysVisible = $true
    CheckOnClick = $True
    #Add_Click = { Count-Questions }
}
        # Adds the modules to the checklistbox
        foreach ( $Module in $Modules ) { 
            $ModuleCheckListBox.Items.Add($Module.ModuleName)
        }
        # Finds the index location of the modules and adds them to the array
        $ModuleCheckLocation = 0
        $ModulesChecked = @()
        foreach ($ModuleName in $ModuleCheckListBox.items){
            if ($ModuleName -match 'Microsoft.Powershell'){
                #$ModuleName
                $ModulesChecked += $ModuleCheckLocation
            }
            $ModuleCheckLocation += $FormScale * 1
        }
        # Checks the modules that were added to the array
        foreach ($ModuleLocation in $ModulesChecked) { 
            $ModuleCheckListBox.SetItemChecked($ModuleLocation, $true) 
        }
$PowerShellModulesGroupBox.Controls.Add($ModuleCheckListBox)



$GenerateQuestionsControlGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Generate Questions Controls"
    Location = @{ X = $PowerShellModulesGroupBox.Location.X
                  Y = $PowerShellModulesGroupBox.Location.Y + $PowerShellModulesGroupBox.Size.Height + $($FormScale * 3) }
    Size     = @{ Width  = $FormScale * 250
                  Height = $FormScale * 128 }
    ForeColor = 'Blue'
}
$PoShPopQuiz.Controls.Add($GenerateQuestionsControlGroupBox)


$ModuleClearSelectionButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text     = "Clear Selection"
    Location = @{ X = $FormScale * 10
                  Y = $FormScale * 20 }
    Size     = @{ Width  = $FormScale * 110
                  Height = $FormScale * 22 }
    Add_Click = {
        (0..($ModuleCheckListBox.Items.Count -1)) | ForEach-Object { $ModuleCheckListBox.SetItemChecked($_,$false)}    
    }
}
$GenerateQuestionsControlGroupBox.Controls.Add($ModuleClearSelectionButton)
CommonButtonSettings -Button $ModuleClearSelectionButton



$ModuleSelectAllButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text     = "Select All"
    Location = @{ X = $ModuleClearSelectionButton.Location.X + $ModuleClearSelectionButton.Size.Width + $($FormScale * 9)
                  Y = $ModuleClearSelectionButton.Location.Y }
    Size     = @{ Width  = $FormScale * 110
                  Height = $FormScale * 22 }
    Add_Click = {
        (0..($ModuleCheckListBox.Items.Count -1)) | ForEach-Object { $ModuleCheckListBox.SetItemChecked($_,$true)}    
    }
}
$GenerateQuestionsControlGroupBox.Controls.Add($ModuleSelectAllButton)
CommonButtonSettings -Button $ModuleSelectAllButton



$NumberOfQuestionsLabel = New-Object -TypeName System.Windows.Forms.Label -Property @{
    Text     = "Number of Questions:"
    Location = @{ X = $ModuleClearSelectionButton.Location.X 
                  Y = $ModuleClearSelectionButton.Location.Y + $ModuleClearSelectionButton.Size.Height + $($FormScale * 9) }
    Size     = @{ Width  = $FormScale * 115
                  Height = $FormScale * 22 }
}
$GenerateQuestionsControlGroupBox.Controls.Add($NumberOfQuestionsLabel)



$script:NumberOfQuestionsComboBox = New-Object -TypeName System.Windows.Forms.ComboBox -Property @{
    Text     = 50
    Location = @{ X = $ModuleSelectAllButton.Location.X 
                  Y = $ModuleSelectAllButton.Location.Y + $ModuleSelectAllButton.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 112
                  Height = $FormScale * 22 }
}
$GenerateQuestionsControlGroupBox.Controls.Add($script:NumberOfQuestionsComboBox)
$NumberOfQuestionsList = @(50,25,20,10)
foreach ($num in $NumberOfQuestionsList) {$script:NumberOfQuestionsComboBox.Items.Add($num)}
$script:NumberOfQuestionsComboBox.SelectedIndex = 0



$script:NumberOfQuestionPoolSizeLabel = New-Object -TypeName System.Windows.Forms.Label -Property @{
    Text     = "Questions Available Within Modules:  0"
    Location = @{ X = $NumberOfQuestionsLabel.Location.X
                  Y = $NumberOfQuestionsLabel.Location.Y + $NumberOfQuestionsLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 230
                  Height = $FormScale * 22 }
}
$GenerateQuestionsControlGroupBox.Controls.Add($script:NumberOfQuestionPoolSizeLabel)



$PopQuizGenerateButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Generate Pop Quiz"
    Location = @{ X = $script:NumberOfQuestionPoolSizeLabel.Location.X
                  Y = $script:NumberOfQuestionPoolSizeLabel.Location.Y + $script:NumberOfQuestionPoolSizeLabel.Size.Height }
    Size     = @{ Width  = $FormScale * 230
                  Height = $FormScale * 22 }
    Add_Click = {
        $PopQuizQuestionRichTextBox.Text = 'Generating Pop Quiz...'
        foreach ($num in (0..50)) {
            Invoke-Expression @"
            `$StatusGroupBox.Controls.Remove(`$script:Status$($num)Button)
            Remove-Variable -Name Status$($num)Button -Scope script -ErrorAction 'SilentlyContinue'
"@
        }
        
        $ModulesSelectedCount = ($ModuleCheckListBox.CheckedItems).count
        if ($ModulesSelectedCount -gt 0){
            $ModulesSelected = @()
            foreach ($ModuledChecked in $ModuleCheckListBox.CheckedItems){
                $ModulesSelected += $ModuledChecked
            }
            Generate-PopQuiz -ModuleName $ModulesSelected -NumberofQuestions $script:NumberOfQuestionsComboBox.SelectedItem
        }
    }
}
$GenerateQuestionsControlGroupBox.Controls.Add($PopQuizGenerateButton)
CommonButtonSettings -Button $PopQuizGenerateButton
$PopQuizGenerateButton.BackColor = 'LightGreen'



$PopQuizQuestionGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Question: #0"
    Location = @{ X = $PowerShellModulesGroupBox.Location.X + $PowerShellModulesGroupBox.Size.Width + $($FormScale * 5)
                  Y = $PowerShellModulesGroupBox.Location.Y }
    Size     = @{ Width  = $FormScale * 700
                  Height = $FormScale * 300 }
    ForeColor = 'Blue'
}
$PoShPopQuiz.Controls.Add($PopQuizQuestionGroupBox)



$PopQuizQuestionRichTextBox = New-Object -TypeName System.Windows.Forms.RichTextBox -Property @{
    Location = @{ X = $FormScale * 10 
                  Y = $FormScale * 20 }
    Size     = @{ Width  = $FormScale * 680
                  Height = $FormScale * 270 }
    ReadOnly = $True
    WordWrap = $True
    Multiline = $True
    Font = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
}
$PopQuizQuestionGroupBox.Controls.Add($PopQuizQuestionRichTextBox)



$script:QuestionPointLabel = New-Object -TypeName System.Windows.Forms.Label -Property @{
    Text = "Value:"
    Location = @{ X = $PopQuizQuestionGroupBox.Location.X + $PopQuizQuestionGroupBox.Size.Width - $($FormScale * 80)
                  Y = $PopQuizQuestionGroupBox.Location.Y  }
    Size     = @{ Width  = $FormScale * 40
                  Height = $FormScale * 20 }
}
$PoShPopQuiz.Controls.Add($script:QuestionPointLabel)
$script:QuestionPointLabel.BringToFront()


$script:QuestionPointValueLabel = New-Object -TypeName System.Windows.Forms.Label -Property @{
    Text = "2.0"
    Location = @{ X = $script:QuestionPointLabel.Location.X + $script:QuestionPointLabel.Size.Width
                  Y = $script:QuestionPointLabel.Location.Y }
    Size     = @{ Width  = $FormScale * 20
                  Height = $FormScale * 20 }
}
$PoShPopQuiz.Controls.Add($script:QuestionPointValueLabel)
$script:QuestionPointValueLabel.BringToFront()



$PopQuizAnswerGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Type In Command: #0"
    Location = @{ X = $PopQuizQuestionGroupBox.Location.X
                  Y = $PopQuizQuestionGroupBox.Location.Y + $PopQuizQuestionGroupBox.Size.Height }
    Size     = @{ Width  = $FormScale * 350
                  Height = $FormScale * 50 }
    ForeColor = 'Blue'
}
$PoShPopQuiz.Controls.Add($PopQuizAnswerGroupBox)


function Previous-Question {
    $num = [int]$script:CurrentAnswerNum - 1
    if ($num -gt 0) {
        Invoke-Expression "`$script:Status$($num)Button.PerformClick()"
    }
}

function Next-Question {
    $num = [int]$script:CurrentAnswerNum + 1
    if ($num -le $($script:NumberOfQuestionsComboBox.SelectedItem)) {
        Invoke-Expression "`$script:Status$($num)Button.PerformClick()"
    }
}


function Submit-ManualEntryAnswer {
    if ($script:PopQuizAnswerTextBox.Text -eq ''){
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),'')
        $script:PopQuizAnswerSubmittedTextBox.Text = 'Nothing Entered - Answer Cleared'
        $script:CurrentButton.ResetBackColor()
    }
    elseif ($script:PopQuizAnswerTextBox.Text -in $CmdList) {
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizAnswerTextBox.text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
}


$script:PopQuizAnswerTextBox = New-Object -TypeName System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $FormScale * 10
                  Y = $FormScale * 20 }
    Size     = @{ Width  = $FormScale * 225
                  Height = $FormScale * 22 }
    BackColor = 'White'
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-ManualEntryAnswer } }
    AutoCompleteSource = "CustomSource"
    AutoCompleteMode   = "SuggestAppend"
}
$CmdList = (Get-Command -CommandType 'Alias', 'Cmdlet', 'Function', 'Workflow').Name
$script:PopQuizAnswerTextBox.AutoCompleteCustomSource.AddRange($cmdList)
$PopQuizAnswerGroupBox.Controls.Add($script:PopQuizAnswerTextBox)



$PopQuizManualEntrySubmitButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Submit"
    Location = @{ X = $script:PopQuizAnswerTextBox.Location.X + $script:PopQuizAnswerTextBox.Size.Width + $($FormScale * 5) 
                  Y = $script:PopQuizAnswerTextBox.Location.Y - $($FormScale * 2) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Enabled = $false
    ForeColor = 'Black'
    Add_Click = { Submit-ManualEntryAnswer }
}
$PopQuizAnswerGroupBox.Controls.Add($PopQuizManualEntrySubmitButton)
CommonButtonSettings -Button $PopQuizManualEntrySubmitButton



$PopQuizControlsGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Controls"
    Location = @{ X = $PopQuizAnswerGroupBox.Location.X + $PopQuizAnswerGroupBox.Size.Width + $($FormScale * 10)
                  Y = $PopQuizAnswerGroupBox.Location.Y }
    Size     = @{ Width  = $FormScale * 340
                  Height = $FormScale * 50 }
    ForeColor = 'Blue'
}
$PoShPopQuiz.Controls.Add($PopQuizControlsGroupBox)



$PreviousQuestionButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "<-- Previous Question"
    Location = @{ X = $FormScale * 10
                  Y = $FormScale * 18 }
    Size     = @{ Width  = $FormScale * 130
                  Height = $FormScale * 22 }
    Enabled = $false
    Add_Click = { Previous-Question }
}
$PopQuizControlsGroupBox.Controls.Add($PreviousQuestionButton)
CommonButtonSettings -Button $PreviousQuestionButton



$PopQuizHelpButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Hint"
    Location = @{ X = $PreviousQuestionButton.Location.X + $PreviousQuestionButton.Size.Width + $($FormScale * 5)
                  Y = $PreviousQuestionButton.Location.Y }
    Size     = @{ Width  = $FormScale * 50
                  Height = $FormScale * 22 }
    Enabled = $false
    Add_Click = {
        if ($script:HintCount -lt $script:CurrentHint.count -and -not $script:NoMoreHints) {
            if ($script:QuestionPointValueLabel.Text -eq ''){
                $script:QuestionPointValueLabel.Text = $(2).ToString('0.0')
            }
            else {
                $script:QuestionPointValueLabel.Text = $($script:QuestionPointValueLabel.Text - 0.1).ToString('0.0')
            }
            $PopQuizQuestionRichTextBox.Focus()
            $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
            $PopQuizQuestionRichTextBox.AppendText("`r`n`r`n=============================================================================================`r`n[Hint $($script:HintCount + 1):]`r`n$($script:CurrentHint[$script:HintCount])")
            $script:HintCount += 1
        }
        elseif (-not $script:NoMoreHints) {
            $PopQuizQuestionRichTextBox.Focus()
            $PopQuizQuestionRichTextBox.AppendText("`r`n`r`n=============================================================================================`r`n[Hint ?:]`r`n     There are no more hints available.")
            $script:NoMoreHints = $true
        }
    }
}
$PopQuizControlsGroupBox.Controls.Add($PopQuizHelpButton)
CommonButtonSettings -Button $PopQuizHelpButton



$NextQuestionButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Next Question -->"
    Location = @{ X = $PopQuizHelpButton.Location.X + $PopQuizHelpButton.Size.Width + $($FormScale * 5)
                  Y = $PopQuizHelpButton.Location.Y }
    Size     = @{ Width  = $FormScale * 130
                  Height = $FormScale * 22 }
    Enabled = $false
    Add_Click = { Next-Question }
}
$PopQuizControlsGroupBox.Controls.Add($NextQuestionButton)
CommonButtonSettings -Button $NextQuestionButton



$StatusGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Question Status"
    Location = @{ X = $PopQuizControlsGroupBox.Location.X
                  Y = $PopQuizControlsGroupBox.Location.Y + $PopQuizControlsGroupBox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 340
                  Height = $FormScale * 160 }
    ForeColor = 'Blue'

}
$PoShPopQuiz.Controls.Add($StatusGroupBox)



$PopQuizAnswerSubmittedGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Text = "Submitted Answer:"
    Location = @{ X = $StatusGroupBox.Location.X 
                  Y = $StatusGroupBox.Location.Y + $StatusGroupBox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 340
                  Height = $FormScale * 50 }
    ForeColor = 'Blue'
}
$PoShPopQuiz.Controls.Add($PopQuizAnswerSubmittedGroupBox)



$script:PopQuizAnswerSubmittedTextBox = New-Object -TypeName System.Windows.Forms.TextBox -Property @{
    Location = @{ X = $FormScale * 10
                  Y = $FormScale * 20 }
    Size     = @{ Width  = $FormScale * 215
                  Height = $FormScale * 22 }
    BackColor = 'White'
    Enabled = $false
    ReadOnly = $True
}
$PopQuizAnswerSubmittedGroupBox.Controls.Add($script:PopQuizAnswerSubmittedTextBox)


$PopQuizGradeButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Grade Quiz"
    Location = @{ X = $script:PopQuizAnswerSubmittedTextBox.Location.X + $script:PopQuizAnswerSubmittedTextBox.Size.Width + $($FormScale * 5) 
                  Y = $script:PopQuizAnswerSubmittedTextBox.Location.Y - $($FormScale * 2) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Enabled = $false
    Forecolor = 'Black'
    Add_Click = {         
        $CompletedQuiz = $true
        foreach ($i in (1..$($script:NumberOfQuestionsComboBox.SelectedItem))) { 
            $Button = Invoke-Expression "`$script:Status$($i)Button"
            if ( $Button.BackColor -ne 'LightBlue' -and $Button.BackColor -ne 'GreenYellow' -and $Button.BackColor -ne 'Red' ) {
                [System.Windows.MessageBox]::Show("You have unanswered questions...")
                $CompletedQuiz = $false
                break
            }
        }
        if ($CompletedQuiz) {
            $script:GradedTest = $true
            [double]$Grade = 0
            $NumberOfQ = $script:NumberOfQuestionsComboBox.SelectedItem - 1
            $NumberCorrect = 0
            foreach ($score in $script:Points.Values){
                if ("$($script:PopQuizPool[$NumberOfQ].Name)" -eq  "$($script:Answers[$NumberOfQ])") {
                    [double]$Grade += [double]$score
                    Invoke-Expression @"
                       `$script:Status$($NumberOfQ+1)Button.BackColor = 'GreenYellow'
"@
                    $NumberCorrect += 1
                }
                else {
                    Invoke-Expression @"
                       `$script:Status$($NumberOfQ+1)Button.BackColor = 'Red'
"@
                }
                $NumberOfQ -= 1
            } 
            [System.Windows.MessageBox]::Show("Final Score:  $([double]([double]$Grade / $($script:NumberOfQuestionsComboBox.SelectedItem * 2)) * 100)%`r`nCorrect:  $NumberCorrect/$($script:NumberOfQuestionsComboBox.SelectedItem)`r`n`r`nClick on each question button to`r`nview the correct answers.",'PoSh-PoPQuiz')

            $PopQuizManualEntrySubmitButton.Enabled = $False
            $script:PopQuizMultipleChoiceSubmitButton.Enabled = $False        
            $PopQuizHelpButton.Enabled = $false
            $script:PopQuizAnswerTextBox.Enabled = $false
            $PopQuizManualEntrySubmitButton.Enabled = $false
            $script:PopQuizMultipleChoiceSubmitButton.Enabled = $false
            $script:PopQuizAnswerSubmittedTextBox.Enabled = $false
            $PopQuizGradeButton.Enabled = $true
            $PopQuizMultipleChoiceStayCheckCheckBox.Enabled = $false
        
            Invoke-Expression "`$script:Status1Button.PerformClick()"
        }
    }
}
$PopQuizAnswerSubmittedGroupBox.Controls.Add($PopQuizGradeButton)
CommonButtonSettings -Button $PopQuizGradeButton


function Update-MultipleChoice {
    if ($script:PopQuizMultipleChoiceCheckBox.checked){
        if ($script:GradedTest -eq $false){
            $script:PopQuizMultipleChoiceSubmitButton.Enabled = $True
        }
        $script:PopQuizMultipleChoice1RadioButton.Enabled = $True
        $script:PopQuizMultipleChoice2RadioButton.Enabled = $True
        $script:PopQuizMultipleChoice3RadioButton.Enabled = $True
        $script:PopQuizMultipleChoice4RadioButton.Enabled = $True
        $script:PopQuizMultipleChoice5RadioButton.Enabled = $True
        $script:PopQuizMultipleChoice6RadioButton.Enabled = $True
        $script:PopQuizMultipleChoice7RadioButton.Enabled = $True
        $script:PopQuizMultipleChoice8RadioButton.Enabled = $True

        $script:PopQuizMultipleChoice1RadioButton.Text = $script:CurrentQuestionList[0]
        $script:PopQuizMultipleChoice2RadioButton.Text = $script:CurrentQuestionList[1]
        $script:PopQuizMultipleChoice3RadioButton.Text = $script:CurrentQuestionList[2]
        $script:PopQuizMultipleChoice4RadioButton.Text = $script:CurrentQuestionList[3]
        $script:PopQuizMultipleChoice5RadioButton.Text = $script:CurrentQuestionList[4]
        $script:PopQuizMultipleChoice6RadioButton.Text = $script:CurrentQuestionList[5]
        $script:PopQuizMultipleChoice7RadioButton.Text = $script:CurrentQuestionList[6]
        $script:PopQuizMultipleChoice8RadioButton.Text = $script:CurrentQuestionList[7]
    }
    else {
        $script:PopQuizMultipleChoiceSubmitButton.Enabled = $False

        $script:PopQuizMultipleChoice1RadioButton.Enabled = $False
        $script:PopQuizMultipleChoice2RadioButton.Enabled = $False
        $script:PopQuizMultipleChoice3RadioButton.Enabled = $False
        $script:PopQuizMultipleChoice4RadioButton.Enabled = $False
        $script:PopQuizMultipleChoice5RadioButton.Enabled = $False
        $script:PopQuizMultipleChoice6RadioButton.Enabled = $False
        $script:PopQuizMultipleChoice7RadioButton.Enabled = $False
        $script:PopQuizMultipleChoice8RadioButton.Enabled = $False

        $script:PopQuizMultipleChoice1RadioButton.Checked = $False
        $script:PopQuizMultipleChoice2RadioButton.Checked = $False
        $script:PopQuizMultipleChoice3RadioButton.Checked = $False
        $script:PopQuizMultipleChoice4RadioButton.Checked = $False
        $script:PopQuizMultipleChoice5RadioButton.Checked = $False
        $script:PopQuizMultipleChoice6RadioButton.Checked = $False    
        $script:PopQuizMultipleChoice7RadioButton.Checked = $False
        $script:PopQuizMultipleChoice8RadioButton.Checked = $False    

        $script:PopQuizMultipleChoice1RadioButton.Text = 'Question 1'
        $script:PopQuizMultipleChoice2RadioButton.Text = 'Question 2'
        $script:PopQuizMultipleChoice3RadioButton.Text = 'Question 3'
        $script:PopQuizMultipleChoice4RadioButton.Text = 'Question 4'
        $script:PopQuizMultipleChoice5RadioButton.Text = 'Question 5'
        $script:PopQuizMultipleChoice6RadioButton.Text = 'Question 6'
        $script:PopQuizMultipleChoice7RadioButton.Text = 'Question 7'
        $script:PopQuizMultipleChoice8RadioButton.Text = 'Question 8'
    }
}


$script:PopQuizMultipleChoiceCheckBox = New-Object -TypeName System.Windows.Forms.CheckBox -Property @{
    Text = "Multiple Choice: #0"
    Location = @{ X = $PopQuizAnswerGroupBox.Location.X + $($FormScale * 10)
                  Y = $PopQuizAnswerGroupBox.Location.Y + $PopQuizAnswerGroupBox.Size.Height + $($FormScale * 1) }
    Size     = @{ Width  = $FormScale * 130
                  Height = $FormScale * 22 }
    Enabled = $false
    ForeColor = 'Blue'
    Add_Click = { 
        if ($This.Checked -eq $false) { $PopQuizMultipleChoiceStayCheckCheckBox.checked = $false }
        Update-MultipleChoice 
    }
}
$PoShPopQuiz.Controls.Add($script:PopQuizMultipleChoiceCheckBox)


$PopQuizMultipleChoiceStayCheckCheckBox = New-Object -TypeName System.Windows.Forms.CheckBox -Property @{
    Text = "Stay Checked"
    Location = @{ X = $PopQuizMultipleChoiceCheckBox.Location.X + $PopQuizMultipleChoiceCheckBox.Size.Width + $FormScale * (100)
                  Y = $PopQuizMultipleChoiceCheckBox.Location.Y }
    Size     = @{ Width  = $FormScale * 95
                  Height = $FormScale * 22 }
    Enabled = $false
    Add_Click = { 
        if ($This.checked) {$script:PopQuizMultipleChoiceCheckBox.checked = $true}
        Update-MultipleChoice 
    }
}
$PoShPopQuiz.Controls.Add($PopQuizMultipleChoiceStayCheckCheckBox)



$script:PopQuizMultipleChoiceGroupBox = New-Object -TypeName System.Windows.Forms.GroupBox -Property @{
    Location = @{ X = $PopQuizAnswerGroupBox.Location.X
                  Y = $PopQuizAnswerGroupBox.Location.Y + $PopQuizAnswerGroupBox.Size.Height + $($FormScale * 5) }
    Size     = @{ Width  = $FormScale * 350
                  Height = $FormScale * 215 }
}
$PoShPopQuiz.Controls.Add($script:PopQuizMultipleChoiceGroupBox)


function Submit-MultipleChoiceAnswer {
    if     ( $script:PopQuizMultipleChoice1RadioButton.checked) {
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizMultipleChoice1RadioButton.Text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
    elseif ( $script:PopQuizMultipleChoice2RadioButton.checked) { 
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizMultipleChoice2RadioButton.Text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
    elseif ( $script:PopQuizMultipleChoice3RadioButton.checked) { 
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizMultipleChoice3RadioButton.Text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
    elseif ( $script:PopQuizMultipleChoice4RadioButton.checked) { 
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizMultipleChoice4RadioButton.Text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
    elseif ( $script:PopQuizMultipleChoice5RadioButton.checked) { 
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizMultipleChoice5RadioButton.Text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
    elseif ( $script:PopQuizMultipleChoice6RadioButton.checked) { 
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizMultipleChoice6RadioButton.Text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
    elseif ( $script:PopQuizMultipleChoice7RadioButton.checked) { 
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizMultipleChoice7RadioButton.Text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
    elseif ( $script:PopQuizMultipleChoice8RadioButton.checked) { 
        $script:Answers.Set_Item($($script:CurrentAnswerNum-1),$script:PopQuizMultipleChoice8RadioButton.Text)
        $script:PopQuizAnswerSubmittedTextBox.Text = $script:Answers[$($script:CurrentAnswerNum-1)]
        $script:Points.Set_Item($($script:CurrentAnswerNum-1),$script:QuestionPointValueLabel.Text)
        $script:CurrentButton.BackColor = 'LightBlue'
        Next-Question
    }
    elseif (!$script:PopQuizMultipleChoice1RadioButton.checked -and 
            !$script:PopQuizMultipleChoice2RadioButton.checked -and 
            !$script:PopQuizMultipleChoice3RadioButton.checked -and 
            !$script:PopQuizMultipleChoice4RadioButton.checked -and 
            !$script:PopQuizMultipleChoice5RadioButton.checked -and 
            !$script:PopQuizMultipleChoice6RadioButton.checked -and
            !$script:PopQuizMultipleChoice7RadioButton.checked -and 
            !$script:PopQuizMultipleChoice8RadioButton.checked ) { 
        $script:PopQuizAnswerSubmittedTextBox.Text = 'Nothing Selected - Answer Cleared'
        $script:CurrentButton.ResetBackColor()
    }
}


$script:PopQuizMultipleChoiceSubmitButton = New-Object -TypeName System.Windows.Forms.Button -Property @{
    Text = "Submit"
    Location = @{ X = $script:PopQuizAnswerTextBox.Location.X + $script:PopQuizAnswerTextBox.Size.Width + $($FormScale * 5) 
                  Y = $($FormScale * 183) }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Enabled = $false
    Add_Click = { Submit-MultipleChoiceAnswer }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoiceSubmitButton)
CommonButtonSettings -Button $script:PopQuizMultipleChoiceSubmitButton



$script:PopQuizMultipleChoice1RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 1"
    Location = @{ X = $FormScale * 29
                  Y = $FormScale * 17 }
    Size     = @{ Width  = $FormScale * 311
                  Height = $FormScale * 24 }    
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice1RadioButton)


$script:PopQuizMultipleChoice2RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 2"
    Location = @{ X = $script:PopQuizMultipleChoice1RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice1RadioButton.Location.Y + $script:PopQuizMultipleChoice1RadioButton.Size.Height }
    Size     = @{ Width  = $FormScale * 311
                  Height = $FormScale * 24 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice2RadioButton)


$script:PopQuizMultipleChoice3RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 3"
    Location = @{ X = $script:PopQuizMultipleChoice2RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice2RadioButton.Location.Y + $script:PopQuizMultipleChoice2RadioButton.Size.Height }
    Size     = @{ Width  = $FormScale * 311
                  Height = $FormScale * 24 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice3RadioButton)


$script:PopQuizMultipleChoice4RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 4"
    Location = @{ X = $script:PopQuizMultipleChoice3RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice3RadioButton.Location.Y + $script:PopQuizMultipleChoice3RadioButton.Size.Height }
    Size     = @{ Width  = $FormScale * 311
                  Height = $FormScale * 24 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice4RadioButton)


$script:PopQuizMultipleChoice5RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 5"
    Location = @{ X = $script:PopQuizMultipleChoice4RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice4RadioButton.Location.Y + $script:PopQuizMultipleChoice4RadioButton.Size.Height }
    Size     = @{ Width  = $FormScale * 311
                  Height = $FormScale * 24 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice5RadioButton)


$script:PopQuizMultipleChoice6RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 6"
    Location = @{ X = $script:PopQuizMultipleChoice5RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice5RadioButton.Location.Y + $script:PopQuizMultipleChoice5RadioButton.Size.Height }
    Size     = @{ Width  = $FormScale * 311
                  Height = $FormScale * 24 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice6RadioButton)


$script:PopQuizMultipleChoice7RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 7"
    Location = @{ X = $script:PopQuizMultipleChoice6RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice6RadioButton.Location.Y + $script:PopQuizMultipleChoice6RadioButton.Size.Height }
    Size     = @{ Width  = $FormScale * 311
                  Height = $FormScale * 24 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice7RadioButton)


$script:PopQuizMultipleChoice8RadioButton = New-Object -TypeName System.Windows.Forms.RadioButton -Property @{
    Text = "Question 8"
    Location = @{ X = $script:PopQuizMultipleChoice7RadioButton.Location.X
                  Y = $script:PopQuizMultipleChoice7RadioButton.Location.Y + $script:PopQuizMultipleChoice7RadioButton.Size.Height }
    Size     = @{ Width  = $FormScale * 311
                  Height = $FormScale * 24 }
    Enabled = $false
    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { Submit-MultipleChoiceAnswer } }
}
$script:PopQuizMultipleChoiceGroupBox.Controls.Add($script:PopQuizMultipleChoice8RadioButton)


$PoShPopQuiz.ShowDialog()