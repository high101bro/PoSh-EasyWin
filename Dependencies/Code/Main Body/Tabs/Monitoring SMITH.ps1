
$SmithSMITHTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text   = "SMTIH"
    Left   = $FormScale * $Column1RightPosition
    Top    = $FormScale * $Column1DownPosition
    Width  = $FormScale * $Column1BoxWidth
    Height = $FormScale * 800
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
$MainLeftSMITHTabControl.Controls.Add($SmithSMITHTab)


$SmithSMITHGroupbox = New-Object System.Windows.Forms.Groupbox -Property @{
    Text   = "Agentless S.M.I.T.H."
    Left   = $FormScale * 10
    Top    = $FormScale * 5
    Width  = $FormScale * 610
    Height = $FormScale * 600
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 12),1,2,1)
    ForeColor = "Blue"
}
$SmithSMITHTab.Controls.Add($SmithSMITHGroupbox)


$SmithSMITHAgentlessLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Agentless"
    Left   = $FormScale * 10
    Top    = $FormScale * 50
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 14),1,2,1)
    ForeColor = "Black"
    Add_MouseHover = {
        Show-ToolTip -Title "Agentless" -Icon "Info" -Message @"
        "There is not a PoSh-EasyWin specific service, daemon, or process (AKA an agent) that is intalled on endpoints for monitoring. Rather this tool leverages existing endoint technologies - Windows PowerShell and Windows Remote Management (WinRM)."
"@
    }
}
$SmithSMITHGroupbox.Controls.Add($SmithSMITHAgentlessLabel)


$SmithSMITHAgentlessNoteLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "`tThere are no services, daemons, or processes intalled on endpoints.
Rather, this tool leverages existing endoint technologies: PowerShell and WinRM."
    Left   = $FormScale * 10
    Top    = $SmithSMITHAgentlessLabel.Top + $SmithSMITHAgentlessLabel.Height
    Width  = $FormScale * 610
    Height = $FormScale * 44
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithSMITHGroupbox.Controls.Add($SmithSMITHAgentlessNoteLabel)


$SmithSMITHSystemMonitoringLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "[S]ystem  [M]onitoring"
    Left   = $FormScale * 10
    Top    = $SmithSMITHAgentlessNoteLabel.Top + $SmithSMITHAgentlessNoteLabel.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 14),1,2,1)
    ForeColor = "Black"
}
$SmithSMITHGroupbox.Controls.Add($SmithSMITHSystemMonitoringLabel)


$SmithSMITHSystemMonitoringNoteLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "`tEndpoints are continuously queried at designated time intervals against user 
specified queries such as registry keys/values, and files/hashes."
    Left   = $FormScale * 10
    Top    = $SmithSMITHSystemMonitoringLabel.Top + $SmithSMITHSystemMonitoringLabel.Height
    Width  = $FormScale * 610
    Height = $FormScale * 44
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithSMITHGroupbox.Controls.Add($SmithSMITHSystemMonitoringNoteLabel)


$SmithSMITHIntenDrivenLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "[I]ntel-driven"
    Left   = $FormScale * 10
    Top    = $SmithSMITHSystemMonitoringNoteLabel.Top + $SmithSMITHSystemMonitoringNoteLabel.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 14),1,2,1)
    ForeColor = "Black"
}
$SmithSMITHGroupbox.Controls.Add($SmithSMITHIntenDrivenLabel)


$SmithSMITHIntenDrivenNoteLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Analyst specifies Intel-driven Indicators of Compromise (IOCs)
in order to alert then of endpoint activity to investigate."
    Left   = $FormScale * 10
    Top    = $SmithSMITHIntenDrivenLabel.Top + $SmithSMITHIntenDrivenLabel.Height
    Width  = $FormScale * 610
    Height = $FormScale * 44
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithSMITHGroupbox.Controls.Add($SmithSMITHIntenDrivenNoteLabel)


$SmithSMITHThreatHuntingLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "[T]hreat  [H]unting"
    Left   = $FormScale * 10
    Top    = $SmithSMITHIntenDrivenNoteLabel.Top + $SmithSMITHIntenDrivenNoteLabel.Height
    Width  = $FormScale * 200
    Height = $FormScale * 22
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 14),1,2,1)
    ForeColor = "Black"
}
$SmithSMITHGroupbox.Controls.Add($SmithSMITHThreatHuntingLabel)


$SmithSMITHThreatHuntingNoteLabel = New-Object System.Windows.Forms.Label -Property @{
    Text   = "Identifying endpoints with potential malicious activity is accompished through
continuous monitoring of systems against indicators of compromise."
    Left   = $FormScale * 10
    Top    = $SmithSMITHThreatHuntingLabel.Top + $SmithSMITHThreatHuntingLabel.Height
    Width  = $FormScale * 610
    Height = $FormScale * 44
    Font   = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = "Black"
}
$SmithSMITHGroupbox.Controls.Add($SmithSMITHThreatHuntingNoteLabel)

