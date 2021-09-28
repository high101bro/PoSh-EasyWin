function Show-ToolTip {
    param (
        $Title   = 'No Title Specified',
        $Message = 'No Message Specified',
        $Icon    = 'Warning'
    )
    $ToolTip = New-Object System.Windows.Forms.ToolTip
    if ($script:OptionShowToolTipCheckBox.Checked){
        $ToolTipMessage1   = "`n`n+  ToolTips can be disabled in the Options Tab."
        $ToolTip.SetToolTip($this,$($Message + $ToolTipMessage1))
        $ToolTip.Active         = $true
        $ToolTip.UseAnimation   = $true
        $ToolTip.UseFading      = $true
        $ToolTip.IsBalloon      = $true
        $ToolTip.ToolTipIcon    = $Icon  #Error, Info, Warning, None
        $ToolTip.ToolTipTitle   = $Title
    }
}

