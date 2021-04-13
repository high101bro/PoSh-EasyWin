Function Verify-Action {
    param($Title,$Question,$Computer)
    #[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
    #$Verify = [Microsoft.VisualBasic.Interaction]::MsgBox(`
    #    "$Question`n$Computer",
    #    'YesNo,Question',`
    #    #'YesNoCancel,Question',`
    #    "$Title")
    #    $Decision = switch ($Verify) {
    #    'Yes' {return $true}
    #    'No'  {return $false}
    #    #'Cancel' {exit}
    #}
    #return $Decision
    $Verify = [System.Windows.Forms.MessageBox]::Show(
        "$Question`n$Computer",
        "PoSh-EasyWin - $Title",
        'YesNo',
        "Warning")
    $Decision = switch ($Verify) {
        'Yes'{return $true}
        'No' {return $false}
    }
    return $Decision
}
