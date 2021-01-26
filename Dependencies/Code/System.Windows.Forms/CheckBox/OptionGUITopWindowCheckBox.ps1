$OptionGUITopWindowCheckBoxAdd_Click = {
    $This.checked | Set-Content "$PoShHome\Settings\GUI Top Most Window.txt" -Force

    # Option to toggle if the Windows is not the top most
    if   ( $OptionGUITopWindowCheckBox.checked ) {
        $PoShEasyWin.Topmost = $true
    }
    else {
        $PoShEasyWin.Topmost = $false
    }
}


