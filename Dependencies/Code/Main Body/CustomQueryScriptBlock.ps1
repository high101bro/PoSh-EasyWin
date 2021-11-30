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


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3Q81UtGef222X+VkFXsa5QeL
# F0GgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU+iymfNAXmiZxxF8Z6Tyk2T44dtUwDQYJKoZI
# hvcNAQEBBQAEggEAgTQVTUXU1kJRoeSnX1WF1XW0PdjZyCfj+6cJVFHsXWjxz+7h
# ZHqOR/lCFkz8k0AJooroZBOuCpZux98rJ6XRFOdhboaepcU5CXSeHV/G9WpBbeFK
# Pw7F3x5npgoygmm5UI9zI2i2HchNXcosxsoXlqn34MHn8+K70+yGrRQv0p1zknF0
# OIHzmbYG+/FmlfcSkIgR6mFvkacNZ0FtOYY7pWAcr4m7/+eZhJhwdHizIEwOOwrN
# 8S9iVNvJmwYTtXOLuM2+i/qrktMqBYOEShmMYvOXLtLib9h5MGPm99DH91WP4bQM
# DksC0ZndVwcIshjHsJ9tuEW5hIfzaG+8QMGnzA==
# SIG # End signature block
