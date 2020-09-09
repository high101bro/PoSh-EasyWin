<#
    .Description
    Scriptblock that is executed to manage the Query Build features such as the interactions between 
    the textbox and button, launching Show-Command, variable manipulation, and message prompts
#>

$CustomQueryScriptBlock = {
    $CustomQueryCheck = $true
    if ($script:CustomQueryScriptBlockTextbox.text -eq 'Enter A Get Cmdlet (ex: Get-Process)') {
        [System.Windows.Forms.MessageBox]::Show("Error: Enter A Valid Get Cmdlet (ex: Get-Process)","PoSh-EasyWin Query Builder",'Ok','Error')        
        $CustomQueryCheck = $false
        $CustomQueryScriptBlockCheckBox.checked = $false
        $CustomQueryScriptBlockCheckBox.enabled = $false
    }
    elseif ($script:CustomQueryScriptBlockTextbox.text -eq 'Enter Any Cmdlet') {
        [System.Windows.Forms.MessageBox]::Show("Error: Enter Any Cmdlet that is avaible on this endpoint.","PoSh-EasyWin Query Builder",'Ok','Error')        
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
    }

    if ($CustomQueryCheck -eq $true) {
        if (($script:CustomQueryScriptBlockTextbox.text -split ' ').count -eq 1){
            Show-Command -Name $script:CustomQueryScriptBlockTextbox.text -NoCommonParameter -PassThru | Set-Variable ShowCommandQueryBuild -scope Script
            if ($script:ShowCommandQueryBuild -eq $null -and -not $CustomQueryScriptBlockOverrideCheckBox.checked) {
                $script:CustomQueryScriptBlockTextbox.text = 'Enter A Get Cmdlet (ex: Get-Process)'
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
            }
            elseif ($script:ShowCommandQueryBuild -eq $null -and $CustomQueryScriptBlockOverrideCheckBox.checked) {
                $script:CustomQueryScriptBlockTextbox.text = 'Enter Any Cmdlet'
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
            }
            else {
                $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild    
                $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
                $CustomQueryScriptBlockCheckBox.enabled = $true
            }
        }
        elseif (($script:CustomQueryScriptBlockTextbox.text -split ' ').count -gt 1){
            Show-Command -Name $($script:CustomQueryScriptBlockTextbox.text -split ' ')[0] -NoCommonParameter -PassThru | Set-Variable ShowCommandQueryBuild -scope Script
            if ($script:ShowCommandQueryBuild -eq $null -and -not $CustomQueryScriptBlockOverrideCheckBox.checked) {
                $script:CustomQueryScriptBlockTextbox.text = 'Enter A Get Cmdlet (ex: Get-Process)'
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
            }
            elseif ($script:ShowCommandQueryBuild -eq $null -and $CustomQueryScriptBlockOverrideCheckBox.checked) {
                $script:CustomQueryScriptBlockTextbox.text = 'Enter Any Cmdlet'
                $CustomQueryScriptBlockCheckBox.checked = $false
                $CustomQueryScriptBlockCheckBox.enabled = $false
            }
            else {
                $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild
                $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
                $CustomQueryScriptBlockCheckBox.enabled = $true
            }
        }

        if ($script:ShowCommandQueryBuild -notlike "Get-*" -and -not $CustomQueryScriptBlockOverrideCheckBox.checked) {
            [System.Windows.Forms.MessageBox]::Show("Error: You are Restricted from using cmdlets with Verbs other than 'Get'","PoSh-EasyWin Query Builder",'Ok','Error')
            $script:CustomQueryScriptBlockTextbox.text = ''
            $CustomQueryScriptBlockCheckBox.checked = $false
            $CustomQueryScriptBlockCheckBox.enabled = $false
        }
        elseif ($script:ShowCommandQueryBuild -match '-ComputerName' -and -not $CustomQueryScriptBlockOverrideCheckBox.checked) {
            [System.Windows.Forms.MessageBox]::Show("Error: Do not include the -ComputerName parameter.`nRather, make a selection from the Computer Treeview.","PoSh-EasyWin Query Builder",'Ok','Error')
            
            $script:ShowCommandQueryBuild = $script:ShowCommandQueryBuild -replace "-ComputerName\s(')?(\w|[0-9a-z_-])*(')?\s?",""  
            $script:CustomQueryScriptBlockTextbox.text = $script:ShowCommandQueryBuild 
            $script:CustomQueryScriptBlockSaved = $script:ShowCommandQueryBuild
            $CustomQueryScriptBlockCheckBox.enabled = $true
        }
        elseif ($script:ShowCommandQueryBuild -eq $null) {
            continue
            $CustomQueryScriptBlockCheckBox.enabled = $true
            $script:CustomQueryScriptBlockSaved =  $script:CustomQueryScriptBlockTextbox.text
        }
    }
}