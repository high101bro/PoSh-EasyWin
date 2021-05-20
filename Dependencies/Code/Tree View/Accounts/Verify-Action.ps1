Function Verify-Action {
    param($Title,$Question,$Computer)
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
