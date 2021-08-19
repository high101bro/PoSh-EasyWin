<#
    .Description
    Scriptblock that is executed to manage the Query Build features such as the interactions between
    the textbox and button, launching Show-Command, variable manipulation, and message prompts
#>

function CustomQueryScriptBlock {
    param(
        [switch]$Build
    )

    $PSDefaultParameterValues = @{
        "Show-Command:Height" = 700
        "Show-Command:Width" = 1000
#        "Show-Command:ErrorPopup" = $True
    }
    if ($script:CustomQueryScriptBlockDisableSyntaxCheckbox.checked) {
        $script:ShowCommandQueryBuild = $script:CustomQueryScriptBlockTextbox.text
        if ($script:ShowCommandQueryBuild -eq $null) {
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $CustomQueryScriptBlockAddCommandButton.Enabled = $true
            $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightBlue'
        }
        if ($script:ShowCommandQueryBuild -match '-ComputerName') {
            [System.Windows.Forms.MessageBox]::Show("Error: Do not include the -ComputerName parameter.`nRather, make a selection from the Computer Treeview.","PoSh-EasyWin Query Builder",'Ok','Error')

            $script:ShowCommandQueryBuild = $script:ShowCommandQueryBuild -replace "-ComputerName\s(')?(\w|[0-9a-z_-])*(')?\s?",""
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
        }
        elseif ($script:ShowCommandQueryBuild -eq $null) {
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $script:CustomQueryScriptBlockSaved =  $script:CustomQueryScriptBlockTextbox.text
        }
    }
    elseif ($Build){
        $script:ShowCommandQueryBuild = Show-Command -PassThru

        if ($script:ShowCommandQueryBuild -eq $null) {
            $script:CustomQueryScriptBlockTextbox.text = 'Enter a cmdlet'
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $CustomQueryScriptBlockCheckBox.checked = $false
            $CustomQueryScriptBlockCheckBox.enabled = $false
            $CustomQueryScriptBlockAddCommandButton.Enabled = $false
            $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightGray'
        }
        else {
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $CustomQueryScriptBlockAddCommandButton.Enabled = $true
            $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightBlue'
        }

        if ($script:ShowCommandQueryBuild -match '-ComputerName') {
            [System.Windows.Forms.MessageBox]::Show("Error: Do not include the -ComputerName parameter.`nRather, make a selection from the Computer Treeview.","PoSh-EasyWin Query Builder",'Ok','Error')

            $script:ShowCommandQueryBuild = $script:ShowCommandQueryBuild -replace "-ComputerName\s(')?(\w|[0-9a-z_-])*(')?\s?",""
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
            $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
        }
        elseif ($script:ShowCommandQueryBuild -eq $null) {
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $script:CustomQueryScriptBlockSaved =  $script:CustomQueryScriptBlockTextbox.text
        }

    }
    else {
        $CustomQueryCheck = $true
        if ($CustomQueryCheck -eq $true) {
            if ($script:CustomQueryScriptBlockTextbox.text -eq 'Enter a cmdlet') {
                [System.Windows.Forms.MessageBox]::Show("Error: Enter a cmdlet that is avaible within a module on this endpoint.","PoSh-EasyWin Query Builder",'Ok','Error')
                $CustomQueryCheck = $false
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
            }
            elseif ($(($script:CustomQueryScriptBlockTextbox.text -split ' ')[0]) -in $script:CmdletList -and $script:CustomQueryScriptBlockTextbox.text -notin $script:CmdletList) {
                [System.Windows.Forms.MessageBox]::Show("The entered cmdlet and any parameters will be updated.","PoSh-EasyWin Query Builder",'Ok','Info')
                $CustomQueryCheck = $true
            }
            elseif ($script:CustomQueryScriptBlockTextbox.text -notin $script:CmdletList) {
                [System.Windows.Forms.MessageBox]::Show("Error: The following is not an available command:`n`n$($script:CustomQueryScriptBlockTextbox.text)","PoSh-EasyWin Query Builder",'Ok','Error')
                $CustomQueryCheck = $false
                $CustomQueryScriptBlockCheckBox.checked = $false                
                $CustomQueryScriptBlockCheckBox.enabled = $false
            }
        
            if (($script:CustomQueryScriptBlockTextbox.text -split ' ').count -eq 1){
                $script:ShowCommandQueryBuild = Show-Command -Name $script:CustomQueryScriptBlockTextbox.text -PassThru
            }
            elseif (($script:CustomQueryScriptBlockTextbox.text -split ' ').count -gt 1){
                $script:ShowCommandQueryBuild = Show-Command -Name $($script:CustomQueryScriptBlockTextbox.text -split ' ')[0] -PassThru
            }

            if ($script:ShowCommandQueryBuild -eq $null) {
                $script:CustomQueryScriptBlockTextbox.text = 'Enter a cmdlet'
                $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
                $CustomQueryScriptBlockAddCommandButton.Enabled = $false
                $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightGray'
            }
            else {
                $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
                $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
                $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
                $CustomQueryScriptBlockCheckBox.enabled = $true
                $CustomQueryScriptBlockAddCommandButton.Enabled = $true
                $CustomQueryScriptBlockAddCommandButton.BackColor = 'LightBlue'
            }

            if ($script:ShowCommandQueryBuild -match '-ComputerName') {
                [System.Windows.Forms.MessageBox]::Show("Error: Do not include the -ComputerName parameter.`nRather, make a selection from the Computer Treeview.","PoSh-EasyWin Query Builder",'Ok','Error')

                $script:ShowCommandQueryBuild = $script:ShowCommandQueryBuild -replace "-ComputerName\s(')?(\w|[0-9a-z_-])*(')?\s?",""
                $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
                $script:CustomQueryScriptBlockTextbox.forecolor = 'black'
                $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
                $CustomQueryScriptBlockCheckBox.enabled = $true
            }
            elseif ($script:ShowCommandQueryBuild -eq $null) {
                $CustomQueryScriptBlockCheckBox.enabled = $true
                $script:CustomQueryScriptBlockSaved =  $script:CustomQueryScriptBlockTextbox.text
            }
        }
    }
}

